//
//  RMSession.m
//  roommates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMSession.h"

@implementation RMSession

+ (RKRequestDidFailLoadWithErrorBlock) objectLoadErrorBlock
{
    return ^(NSError *error) {
        NSMutableString *feedback = [NSMutableString stringWithCapacity:50];
        for (NSString *field in [error userInfo]) {
            [feedback appendFormat:@"%@ %@", field, [[[error userInfo] objectForKey: field] lastObject]];
        }

        [SVProgressHUD showErrorWithStatus:@"Can't connect"];
        NSLog(@"%@", [error description]);
    };
}

+ (RKRequestDidFailLoadWithErrorBlock) objectValidationErrorBlock
{
    return ^(NSError *error) {
        NSMutableString *feedback = [NSMutableString stringWithCapacity:50];
        for (NSString *field in [error userInfo]) {
            [feedback appendFormat:@"%@ %@", field, [[[error userInfo] objectForKey: field] lastObject]];
        }
        
        [SVProgressHUD showErrorWithStatus:feedback];
        NSLog(@"%@", [error description]);
    };
}



// FIXME: this probably isn't the best way to handle this since they
// need to call startSessionEmail:... before this is initialized but
// I just need to get this working so I can have access to it. I'll
// circle back later and fix this.
static RMSession *gInstance = nil;
+ (RMSession *)instance
{
    @synchronized(self) {
        return gInstance;
    }
}

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/sessions"];
    [provider addObjectMapping:mapping];
}

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [mapping mapKeyPath:@"id" toAttribute:@"userId"];
    [mapping mapKeyPath:@"first_name" toAttribute:@"firstName"];
    [mapping mapKeyPath:@"last_name" toAttribute:@"lastName"];
    [mapping mapKeyPath:@"display_name" toAttribute:@"displayName"];
    [mapping mapKeyPath:@"full_name" toAttribute:@"fullName"];
    [mapping mapKeyPath:@"avatar" toAttribute:@"avatar"];
    [mapping mapKeyPath:@"api_token" toAttribute:@"apiToken"];
    return mapping;
}

+ (void)startSessionEmail:(NSString*) email Password:(NSString*) password
                OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success
                    OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure {
    RKObjectManager *mgr = [RKObjectManager sharedManager];
    
    // I'm not sure we need to call endSession and wait for the DELETE but we
    // should at least clear out the cached data and the HTTP header.
    [mgr.client setValue:nil forHTTPHeaderField:@"Authorization"];
    [mgr.objectStore deletePersistentStore];

    [mgr loadObjectsAtResourcePath:@"/api/sessions" usingBlock:^(RKObjectLoader *loader) {
        loader.method = RKRequestMethodPOST;
        loader.params = [NSDictionary dictionaryWithObjectsAndKeys:
                         email, @"email",
                         password, @"password",
                         nil];
        RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[self class]];
        loader.objectMapping = [[self class] addMappingsTo:objectMapping];
        loader.onDidLoadObject = ^(RMSession *session) {
            // Store it into our singleton... It'd be better if we could just
            // have them overwrite our existing object.
            @synchronized(self)
            {
                gInstance = session;
            }

            // Put our auth token into the parameter list for future requests.
            NSString *apiToken = [NSString stringWithFormat:@"Token token=\"%@\"", session.apiToken];
            [[RKObjectManager sharedManager].client setValue:apiToken forHTTPHeaderField:@"Authorization"];
            // Store a copy for loading.
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:apiToken forKey:@"apiToken"];
            [defaults setObject:email forKey:@"email"];
            [defaults setObject:password forKey:@"password"];

            success(session);

            // TODO Should probably change this to send off a NSNotification 
            // so that everything knows we've got a new session.
            [[NSNotificationCenter defaultCenter] 
             postNotificationName:@"RMSessionStarted" object:self];
        };
        loader.onDidFailWithError = ^(NSError *error) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults removeObjectForKey:@"apiToken"];
            [defaults removeObjectForKey:@"password"];

            failure(error);
        };
    }];
}

+ (void)endSession
{
    @synchronized(self)
    {
        gInstance = nil;
        // Remove the HTTP header...
        [[RKObjectManager sharedManager].client setValue:nil forHTTPHeaderField:@"Authorization"];
        // ...clear out stored data...
        [[RKObjectManager sharedManager].objectStore deletePersistentStore];
        // ...delete save credentials...
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"apiToken"];
        [defaults removeObjectForKey:@"password"];
        // ...DELETE the session and let them know when we've finished.
        [[RKObjectManager sharedManager].client delete:@"/api/session" usingBlock:^(RKRequest *request) {
            request.onDidLoadResponse = ^(RKResponse *response) {
                // Send notice...
                [[NSNotificationCenter defaultCenter] 
                 postNotificationName:@"RMSessionEnded" object:self];
            };
            request.onDidFailLoadWithError = ^(NSError *error) {
                // Send notice...
                [[NSNotificationCenter defaultCenter] 
                 postNotificationName:@"RMSessionEnded" object:self];
            };
        }];
    }
}


@synthesize userId,
    firstName,
    lastName,
    displayName,
    fullName,
    avatar, 
    apiToken;

- (NSString*)description {
	return [NSString stringWithFormat:@"RMSession (id: %@, apiToken: %@)", self.userId, self.apiToken];
}
@end
