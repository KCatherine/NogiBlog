//
//  MemberNameViewController.m
//  BlogViewer
//
//  Created by 杨璟 on 15/11/30.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import "AppDelegate.h"
#import "MemberNameViewController.h"
#import "MemberBlogTableViewController.h"
#import "MemberNameTableViewCell.h"

@interface MemberNameViewController ()

@end

@implementation MemberNameViewController {
    AppDelegate *_appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [UIApplication sharedApplication].delegate;

    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:108/255.0 green:19/255.0 blue:126/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return [_appDelegate.memberNameFromPlist count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MemberNameTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"memberNameCell"];
    NSUInteger row = [indexPath row];
    for (int i = 0; i <= row; i++) {
        cell.memberName.text = [_appDelegate.memberNameFromPlist objectAtIndex:i];
        
        //设置成员头像
        NSString *imagePath = [_appDelegate.memberIconFromPlist objectAtIndex:i];
        imagePath = [imagePath stringByAppendingString:@".JPG"];
        cell.memberIcon.image = [UIImage imageNamed:imagePath];
    }
    
    return cell;
}


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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"toTableView"]) {
        MemberBlogTableViewController *blogTableViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        blogTableViewController.toBeCatchedblogURL = [_appDelegate.ownBlogURLFromPlist objectAtIndex:selectedIndex];
        blogTableViewController.title = [_appDelegate.memberNameFromPlist objectAtIndex:selectedIndex];
    }
}


@end
