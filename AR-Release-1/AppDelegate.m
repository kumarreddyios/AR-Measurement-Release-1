//
//  AppDelegate.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

#define KEY_IS_FIRST_LAUNCH @"key_is_first_launch"

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //Check if first launch
//    BOOL isFirstLaunch = [[NSUserDefaults standardUserDefaults] boolForKey:KEY_IS_FIRST_LAUNCH];
//    if (isFirstLaunch) {
//        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:KEY_IS_FIRST_LAUNCH];
//        //Load permission view controller.
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ARKit" bundle:nil];
//        UINavigationController *primaryNavController = [storyboard instantiateInitialViewController];
//        UIViewController *permissionVC = [storyboard instantiateViewControllerWithIdentifier:@"ARPermissionViewController"];
//        primaryNavController.viewControllers = [NSArray arrayWithObject:permissionVC];
//    }
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
