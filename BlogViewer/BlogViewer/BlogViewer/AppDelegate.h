//
//  AppDelegate.h
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IIViewDeckController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

// /*图片与名称对应代码
@property (strong, nonatomic) NSDictionary *nameWithIcon;
@property (strong, nonatomic) NSArray *memberNameFromPlist;
@property (strong, nonatomic) NSArray *memberIconFromPlist;
@property (nonatomic, strong) NSArray *memberIDFromPlist;
// */

@property (strong, nonatomic) UIViewController *centerViewController;
@property (strong, nonatomic) UIViewController *nameViewController;

@end

