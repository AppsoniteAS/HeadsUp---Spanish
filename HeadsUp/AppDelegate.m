//
//  AppDelegate.m
//  HeadsUp
//
//  Created by Zeeshan Ahmed on 2/4/14.
//  Copyright (c) 2014 RobinGronvold. All rights reserved.
//

#import "AppDelegate.h"
#import "ShelfViewController.h"
#import "CustomNavPortraitViewController.h"
#import "Flurry.h"
#import <RevMobAds/RevMobAds.h>

@implementation AppDelegate
@synthesize shlfVw = _shlfVw;
@synthesize arryAnswers;
@synthesize arryCardsAnswered;
@synthesize videoUrl;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [MKStoreManager sharedManager];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [Flurry setCrashReportingEnabled:YES];
    
    // Replace YOUR_API_KEY with the api key in the downloaded package
    [Flurry startSession:@"S4RNTZQ42SD2NGRBFDZD"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    //[RevMobAds startSessionWithAppID:@"534eef383347940c07152bad"];
    
    NSString *nibName = nil;
    
    if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone)
    {
        nibName = @"ShelfViewController_iPhone";
    }
    else
    {
        nibName = @"ShelfViewController_iPad";
    }
    
    self.shlfVw = [[ShelfViewController alloc] initWithNibName:nibName
                                                        bundle:[NSBundle mainBundle]];
    CustomNavPortraitViewController *rootNavCtrl = [[CustomNavPortraitViewController alloc]
                                                    initWithRootViewController:self.shlfVw];
    rootNavCtrl.navigationBarHidden = YES;
    
    [self.window setRootViewController:rootNavCtrl];
    [self.window makeKeyAndVisible];
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
    [[RevMobAds session] showFullscreen];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
