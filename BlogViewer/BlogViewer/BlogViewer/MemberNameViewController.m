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

#define OWN_HTML @"http://akbdata.com/json/i/v2/id/blog/%@/200/0"

@interface MemberNameViewController ()

@end

@implementation MemberNameViewController {
    AppDelegate *_appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _appDelegate = [UIApplication sharedApplication].delegate;
    
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
        cell.memberName.text = [_appDelegate.memberNameFromPlist objectAtIndex:row];
        
        //设置成员头像
        NSString *imagePath = [_appDelegate.memberIconFromPlist objectAtIndex:row];
        imagePath = [imagePath stringByAppendingString:@".JPG"];
        cell.memberIcon.image = [UIImage imageNamed:imagePath];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {

    if ([segue.identifier isEqualToString:@"toTableView"]) {
        MemberBlogTableViewController *blogTableViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        NSString *ownID = [_appDelegate.memberIDFromPlist objectAtIndex:selectedIndex];
        blogTableViewController.toBeCatchedblogURL = [NSString stringWithFormat:OWN_HTML, ownID];
        blogTableViewController.title = [_appDelegate.memberNameFromPlist objectAtIndex:selectedIndex];
    }
}


@end
