//
//  LeftViewController.m
//  BlogViewer
//
//  Created by 杨璟 on 15/11/29.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import "AppDelegate.h"
#import "LeftViewController.h"
#import "ViewController.h"
#import "MemberNameViewController.h"

@interface LeftViewController ()

@end

@implementation LeftViewController {
    AppDelegate *_appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)controllerForIndex:(int)index {
    
    switch (index) {
        case 0:
            if (self.viewDeckController.centerController != _appDelegate.centerViewController) {
                NSLog(@"Top 5");
                NSLog(@"%@",self.viewDeckController.centerController);
                return _appDelegate.centerViewController;
            } else {
                return self.viewDeckController.centerController;
            }
        case 1:
            if (self.viewDeckController.centerController != _appDelegate.nameViewController) {
                NSLog(@"Name");
                NSLog(@"%@",self.viewDeckController.centerController);
                return _appDelegate.nameViewController;
            } else {
                return self.viewDeckController.centerController;
            }
        case 2:
            if (self.viewDeckController.centerController != _appDelegate.nameViewController) {
                NSLog(@"Name");
                NSLog(@"%@",self.viewDeckController.centerController);
                return _appDelegate.nameViewController;
            } else {
                return self.viewDeckController.centerController;
            }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 2;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        NSLog(@"before click delegate center = %@", _appDelegate.centerViewController);
        controller.centerController = [self controllerForIndex:indexPath.row];
    }];
}

@end
