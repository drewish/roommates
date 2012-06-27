//
//  AppDelegate.m
//  roomates
//
//  Created by andrew morton on 6/25/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "AppDelegate.h"
#import "RMSession.h"
#import "RMHousehold.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    RKLogConfigureByName("RestKit", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
    
    NSString *url = @"http://roommates-staging.herokuapp.com/";
    
    RKObjectManager* mgr = [RKObjectManager managerWithBaseURLString:url];
    mgr.serializationMIMEType = RKMIMETypeJSON;
    [mgr.client setValue:@"application/roommates.v1" forHTTPHeaderField:@"Accept"];
    
    [mgr loadObjectsAtResourcePath:@"/api/sessions" usingBlock:^(RKObjectLoader *loader) {
        RKObjectMapping *objectMapping = [RKObjectMapping mappingForClass:[RMSession class]];

        loader.method = RKRequestMethodPOST;
        loader.params = [NSDictionary dictionaryWithObjectsAndKeys:
                         @"delany@gmail.com", @"email", 
                         @"123456", @"password", 
                         nil];
        loader.objectMapping = [RMSession addMappingsTo:objectMapping];
        loader.onDidLoadObject = ^(RMSession *session){
            NSString *val = [NSString stringWithFormat:@"Token token=\"%@\"", session.apiToken];
            [mgr.client setValue:val forHTTPHeaderField:@"Authorization"];
            
            // TODO: this currently fails because it can't seem to figure out 
            // the right class mappings for the path.
            [mgr loadObjectsAtResourcePath:@"/api/households" usingBlock:^(RKObjectLoader *sub) {
                sub.onDidLoadObject = ^(id object) {
                    NSLog(@"households %@", object);
                };
                sub.onDidFailWithError = ^(NSError *error) {
                    NSLog(@"Errored... %@", error);
                };
            }];
        };
    }];
    
    
    // Setup our mappings.
    RKObjectMapping* mapping;
    // TODO this seems like it should be pushed into the data classes.
    mapping = [RKObjectMapping mappingForClass:[RMUser class]];
    [RMUser addMappingsTo:mapping];
    [mgr.mappingProvider addObjectMapping:mapping];

    mapping = [RKObjectMapping mappingForClass:[RMHousehold class]];
    [RMHousehold addMappingsTo:mapping];
    [mgr.mappingProvider addObjectMapping:mapping];

    
    // Setup out class routes.
    RKObjectRouter *router = mgr.router;
    [router routeClass:[RMUser class] toResourcePath:@"/api/users" forMethod:RKRequestMethodGET];
    [router routeClass:[RMHousehold class] toResourcePath:@"/api/households" forMethod:RKRequestMethodGET];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects {
    RMSession *user = [objects objectAtIndex:0];
    NSLog(@"Loaded User ID #%@ -> Name: %@, token: %@", user.userId, user.fullName, user.apiToken);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error {
    NSLog(@"Encountered an error: %@", error);
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
