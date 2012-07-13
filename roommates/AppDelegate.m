//
//  AppDelegate.m
//  roommates
//
//  Created by andrew morton on 6/25/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "AppDelegate.h"
#import "TestFlight.h"
#import "LoginViewController.h"
#import "RMData.h"

#define TESTING 1

@implementation AppDelegate

@synthesize window = _window;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    [TestFlight takeOff:@"2e02edf6518d53ca4dc674538c2eb799_MTA1NTQ3MjAxMi0wNi0yOSAyMzozNTozMi4wOTkxNDE"];
#ifdef TESTING
    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];

//    RKLogConfigureByName("RestKit", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);
#endif

    NSString *url = @"http://roommates-staging.herokuapp.com";

    RKObjectManager* mgr = [RKObjectManager managerWithBaseURLString:url];
    mgr.serializationMIMEType = RKMIMETypeJSON;
    mgr.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    [mgr.client setValue:@"application/roommates.v1" forHTTPHeaderField:@"Accept"];

    RKManagedObjectStore* objectStore = [RKManagedObjectStore objectStoreWithStoreFilename:@"RMData.sqlite"];
    mgr.objectStore = objectStore;

    // Setup our mappings.
    [RMUser registerMappingsWith:mgr.mappingProvider inManagedObjectStore:objectStore];
    [RMHousehold registerMappingsWith:mgr.mappingProvider inManagedObjectStore:objectStore];
    [RMComment registerMappingsWith:mgr.mappingProvider];
    [RMLogEntry registerMappingsWith:mgr.mappingProvider];
    [RMNote registerMappingsWith:mgr.mappingProvider];

    
    //TODO: these might be useful later when I'm uploading
    //    // Setup out class routes.
    //    [mgr.router routeClass:[RMUser class] toResourcePath:@"/api/users" forMethod:RKRequestMethodGET];
    //    [mgr.router routeClass:[RMHousehold class] toResourcePath:@"/api/households" forMethod:RKRequestMethodGET];


    // TODO Need to get the actual RGB value.
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.706 green:0.196 blue:0.086 alpha:1.000]];
    // Lets darken up the buttons for now.
    [[UIToolbar appearance] setTintColor:[UIColor blackColor]];

	self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self.window makeKeyAndVisible];

    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginViewController* loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    self.window.rootViewController = loginViewController;
    
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
