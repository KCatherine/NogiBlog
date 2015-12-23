//
//  AppDelegate.m
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "ViewController.h"
#import "MemberNameViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // /*设置图片与名称对称的代码
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"nameWithIcon" ofType:@"plist"];
    self.nameWithIcon = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    self.memberNameFromPlist = [self.nameWithIcon objectForKey:@"name"];
    self.memberIconFromPlist = [self.nameWithIcon objectForKey:@"icon"];
    // */
    
    IIViewDeckController* deckController = [self generateControllerStack];
    self.centerViewController = deckController.centerController;
    
    NSLog(@"init APP delegate = %@",self.centerViewController);
    
    /* To adjust speed of open/close animations, set either of these two properties. */
    deckController.openSlideAnimationDuration = 0.15f;
    deckController.closeSlideAnimationDuration = 0.3f;
    
    self.window.rootViewController = deckController;
    [self.window makeKeyAndVisible];

    return YES;
}

- (IIViewDeckController *)generateControllerStack {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LeftViewController *leftController = [storyboard instantiateViewControllerWithIdentifier:@"LeftVC"];
    ViewController *centerController = [storyboard instantiateViewControllerWithIdentifier:@"CenterVC"];
    MemberNameViewController *nameController = [storyboard instantiateViewControllerWithIdentifier:@"MemberNameNV"];
    
    self.nameViewController = nameController;
    
    IIViewDeckController *deckController =  [[IIViewDeckController alloc] initWithCenterViewController:centerController
                                                                                    leftViewController:leftController];
    deckController.leftSize = 88;
    
    return deckController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"BlogList.plist"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    [array removeAllObjects];
    [array writeToFile:path atomically:YES];
}

@end
