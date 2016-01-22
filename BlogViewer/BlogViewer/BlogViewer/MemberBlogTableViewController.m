//
//  MemberBlogTableViewController.m
//  BlogViewer
//
//  Created by 杨璟 on 15/12/23.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import "BlogModel.h"
#import "AppDelegate.h"
#import "MemberBlogTableViewController.h"
#import "BlogTitleTableViewCell.h"
#import "DetailViewController.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"

@interface MemberBlogTableViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) NSMutableArray *blogModelArray;
@property (nonatomic, strong) NSMutableArray *blogDictArray;

@end

@implementation MemberBlogTableViewController {
    AppDelegate *_appDelegate;
}

- (NSMutableArray *)blogModelArray {
    if (!_blogModelArray) {
        _blogModelArray = [NSMutableArray array];
    }
    return _blogModelArray;
}

- (NSMutableArray *)blogDictArray {
    if (!_blogDictArray) {
        _blogDictArray = [NSMutableArray array];
    }
    return _blogDictArray;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    _appDelegate = [UIApplication sharedApplication].delegate;
    
    [self startRequest];
#warning 未完成的下拉刷新
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
    }];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    // 忽略掉底部inset
    self.tableView.footer.ignoredScrollViewContentInsetBottom = 20;
    
    //设置返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
}

- (BOOL)isConnectionAvailable {
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"www.nogizaka46.com"];
    switch ([reach currentReachabilityStatus]) {
        case NotReachable:
            isExistenceNetwork = NO;
            break;
        case ReachableViaWiFi:
            isExistenceNetwork = YES;
            break;
        case ReachableViaWWAN:
            isExistenceNetwork = YES;
            break;
    }
    
    if (!isExistenceNetwork) {
        
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"无法连接到服务器";
        HUD.margin = 10.f;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hide:YES afterDelay:5];
        
        return NO;
    }
    
    return isExistenceNetwork;
}

#pragma mark - 抓取博客代码
- (void)startRequest {
    NSURL *url = [NSURL URLWithString:self.toBeCatchedblogURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
        if (data == nil || connectionError) {
            [self reloadView:connectionError];
        } else {
            NSArray *allData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            for (NSDictionary *dict in allData) {
                BlogModel *oneBlog = [BlogModel blogWithDict:dict];
                [self.blogModelArray addObject:oneBlog];
                [self reloadView:connectionError];
            }
        }
        [self.tableView reloadData];
// 不必要写入文件中
//        for (BlogModel *model in self.blogModelArray) {
//            NSDictionary *dict = [BlogModel dictionaryWithModel:model];
//            [self.blogDictArray addObject:dict];
//        }
//        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"MemberBlogList.plist"];
//        [self.blogDictArray writeToFile:path atomically:YES];
    }];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
}

#pragma mark - reloadView
- (void)reloadView:(NSError *)connectionError {
    if (!connectionError) {
        [self.tableView.footer endRefreshing];
        [HUD hide:YES];
    } else {
        
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"请求超时";
        HUD.margin = 10.f;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hide:YES afterDelay:2];
        
        [self.tableView.footer endRefreshing];
        
    }
    
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

#pragma mark - TableView代理方法

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.blogModelArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *cellIdentifier = @"BlogTitleCell";
    BlogTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger row = [indexPath row];
    
    //将模型传给Cell
    BlogModel *blog = self.blogModelArray[row];
    cell.blog = blog;
    
    // /*设置表格中成员图片代码
    NSUInteger nameAtRow = [_appDelegate.memberNameFromPlist indexOfObject:blog.memberName];
    NSString *imagePath = [_appDelegate.memberIconFromPlist objectAtIndex:nameAtRow];
    imagePath = [imagePath stringByAppendingString:@".JPG"];
    cell.memberIcon.image = [UIImage imageNamed:imagePath];
    // */
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}

#pragma mark - 控制器跳转代理
- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"fromMemberToWebView"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        BlogModel *blog = self.blogModelArray[selectedIndex];
        
        detailViewController.blogURL = blog.blogURL;
        
        detailViewController.title = blog.memberName;
        
    }
}

@end
