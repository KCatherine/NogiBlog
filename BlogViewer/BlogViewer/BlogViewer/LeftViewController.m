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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:108/255.0 green:19/255.0 blue:126/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
   //[self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIViewController *)controllerForIndex:(int)index {

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    ViewController *centerController = [storyboard instantiateViewControllerWithIdentifier:@"CenterVC"];
    
    switch (index) {
        case 0:
            if (self.viewDeckController.centerController == _appDelegate.centerViewController) {
                NSLog(@"Top 5");
                return self.viewDeckController.centerController;
            } else {
                _appDelegate.centerViewController = centerController;
                NSLog(@"now = %@",self.viewDeckController.centerController);
                NSLog(@"center = %@",centerController);
                NSLog(@"return new center");
                return centerController;
            }
        case 1:
            if (self.viewDeckController.centerController == _appDelegate.nameViewController) {
                NSLog(@"Name");
                return self.viewDeckController.centerController;
            } else {
                _appDelegate.centerViewController = _appDelegate.nameViewController;
                return _appDelegate.nameViewController;
            }
        case 2:
            if (self.viewDeckController.centerController == _appDelegate.nameViewController) {
                NSLog(@"Name");
                return self.viewDeckController.centerController;
            } else {
                _appDelegate.centerViewController = _appDelegate.nameViewController;
                return _appDelegate.nameViewController;
            }
    }
    return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [self.viewDeckController closeLeftViewBouncing:^(IIViewDeckController *controller) {
        controller.centerController = [self controllerForIndex:indexPath.row];
    }];
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
