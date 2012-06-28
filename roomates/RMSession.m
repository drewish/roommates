//
//  RMSession.m
//  roomates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMSession.h"

@implementation RMSession
@synthesize avatar, apiToken;

+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider 
{
    RKObjectMapping* mapping = [self addMappingsTo:[RKObjectMapping mappingForClass:[self class]]];
    [provider setObjectMapping:mapping forResourcePathPattern:@"/api/sessions"];
}

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [super addMappingsTo:mapping];
    [mapping mapKeyPath:@"avatar" toAttribute:@"avatar"];
    [mapping mapKeyPath:@"api_token" toAttribute:@"apiToken"];
    return mapping;
}
+ (void)startSessionEmail:(NSString*) email Password:(NSString*) password
                OnSuccess:(RKObjectLoaderDidLoadObjectBlock) success 
                    OnFailure:(RKObjectLoaderDidFailWithErrorBlock) failure {
    [[RKObjectManager sharedManager] loadObjectsAtResourcePath:@"/api/sessions" usingBlock:^(RKObjectLoader *loader) {
        loader.method = RKRequestMethodPOST;
        loader.params = [NSDictionary dictionaryWithObjectsAndKeys:
                         email, @"email", 
                         password, @"password", 
                         nil];
        RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[RMSession class]];        
        loader.objectMapping = [RMSession addMappingsTo:objectMapping];
        loader.onDidLoadObject = ^(RMSession *session) {
            // Put our auth token into the parameter list for future requests.
            NSString *val = [NSString stringWithFormat:@"Token token=\"%@\"", session.apiToken];
            [[RKObjectManager sharedManager].client setValue:val forHTTPHeaderField:@"Authorization"];
            
            success(session);
        };
        loader.onDidFailWithError = failure;
    }];
}
@end
