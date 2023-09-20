//
//  DSAppDelegate.m
//  DesuDBEncryption
//
//  Created by 48179357 on 09/20/2023.
//  Copyright (c) 2023 48179357. All rights reserved.
//

#import "DSAppDelegate.h"
#import <Rudder/Rudder.h>
#import "EncryptedDatabaseProvider.h"

@implementation DSAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    RSConfigBuilder *builder = [[RSConfigBuilder alloc] init];
                [builder withLoglevel:RSLogLevelVerbose];
                [builder withTrackLifecycleEvens:YES];
                [builder withRecordScreenViews:YES];
                [builder withDataPlaneUrl:@"https://rudderstachvf.dataplane.rudderstack.com"];
                [builder withSleepTimeOut:3000];
                [builder withDBEncryption:[[RSDBEncryption alloc] initWithKey:@"test1234" enable:YES databaseProvider:[EncryptedDatabaseProvider new]]];
                [RSClient getInstance:@"1pTxG1Tqxr7FCrqIy7j0p28AENV" config:[builder build]];
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
