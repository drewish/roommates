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
#import "RMLogEntry.h"

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{   
    RKLogConfigureByName("RestKit", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
    
    NSString *url = @"http://roommates-staging.herokuapp.com";
    
    RKObjectManager* mgr = [RKObjectManager managerWithBaseURLString:url];
    mgr.serializationMIMEType = RKMIMETypeJSON;
    [mgr.client setValue:@"application/roommates.v1" forHTTPHeaderField:@"Accept"];

    // Setup our mappings.
    [RMUser registerMappingsWith:mgr.mappingProvider];
    [RMHousehold registerMappingsWith:mgr.mappingProvider];
    [RMLogEntry registerMappingsWith:mgr.mappingProvider];
    
    //TODO: these might be useful later when I'm uploading
//    // Setup out class routes.
//    [mgr.router routeClass:[RMUser class] toResourcePath:@"/api/users" forMethod:RKRequestMethodGET];
//    [mgr.router routeClass:[RMHousehold class] toResourcePath:@"/api/households" forMethod:RKRequestMethodGET];


    [RMSession startSessionEmail:@"delany@gmail.com" Password:@"123456" OnSuccess:^(RMSession *session) {
        NSLog(@"Loaded User ID #%@ -> Name: %@, token: %@", session.userId, session.fullName, session.apiToken);
        [RMHousehold getHouseholdsOnSuccess:^(NSArray *households) {
            NSLog(@"Households: %@", households);
            RMHousehold *first = [households objectAtIndex:0];
            [RMLogEntry getLogEntriesForHousehold:first.householdId OnSuccess:^(NSArray *logEntries) {
                for (RMLogEntry *entry in logEntries) {
                    NSLog(@"%@", entry);
                }
            } OnFailure:^(NSError *error) {
                NSLog(@"Couldn't fetch feeds: %@", error);
            }];
        } OnFailure:^(NSError *error) {
            NSLog(@"Couldn't fetch households: %@", error);
        }];
    } OnFailure:^(NSError *error) {
        NSLog(@"Encountered an error: %@", error);
    }];

    // Override point for customization after application launch.
    return YES;
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
