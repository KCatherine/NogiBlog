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

#define blogCatchPattern @"<td class=\"heading\"><span class=\"author\">(.*?)</span> <span class=\"entrytitle\"><a href=\"(.*?)\" rel=\"bookmark\">(.*?)</a></span></td>.*?<div class=\"kijifoot\">(.*?)｜.*?</div>"

@interface MemberBlogTableViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (assign, nonatomic) NSInteger blogPageIndex;
@property (copy, nonatomic) NSString *urlString;
@property (copy, nonatomic) NSString *htmlCache;
@property (strong, nonatomic) NSArray *catchedBlogs;
@property (strong, nonatomic) NSMutableArray *blogModelArray;

@end

@implementation MemberBlogTableViewController {
    AppDelegate *_appDelegate;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    _appDelegate = [UIApplication sharedApplication].delegate;
    
    self.blogPageIndex = 1;
    [self creatEditableCopyOfDatabaseIfNeed];
    
    [self goToPage:self.blogPageIndex];
    
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        self.blogPageIndex++;
        if (self.blogPageIndex <= 10) {
            [self goToPage:self.blogPageIndex];
        }
    }];
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 5, 0);
    // 忽略掉底部inset
    self.tableView.footer.ignoredScrollViewContentInsetBottom = 20;
    
    //设置NavigationBar字体的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置NavigationBar的颜色
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithRed:108/255.0 green:19/255.0 blue:126/255.0 alpha:1.0]];
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    //设置返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    
}

- (void)viewWillAppear:(BOOL)animated {
    //[self showTabBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)goToPage:(int)Index {
    if ([self isConnectionAvailable]) {
        
        [self catchHTMLBlogs:Index];
    }
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

- (IBAction)RefreshBlog:(id)sender {
    [self applicationDocumentsDirectoryEmptyFile];
    [self goToPage:1];
}
/*
 - (IBAction)jumpToBlog:(id)sender {
 
 UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择你想查看的页面"
 message:nil
 preferredStyle:UIAlertControllerStyleActionSheet];
 UIAlertAction *pageOne = [UIAlertAction actionWithTitle:@"第一页"
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction *action) {
 [self goToPage:1];
 }];
 UIAlertAction *pageTwo = [UIAlertAction actionWithTitle:@"第二页"
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction *action) {
 [self goToPage:2];
 }];
 UIAlertAction *pageThree = [UIAlertAction actionWithTitle:@"第三页"
 style:UIAlertActionStyleDefault
 handler:^(UIAlertAction *action) {
 [self goToPage:3];
 }];
 UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消"
 style:UIAlertActionStyleCancel
 handler:nil];
 [sheet addAction:pageOne];
 [sheet addAction:pageTwo];
 [sheet addAction:pageThree];
 [sheet addAction:cancelAction];
 if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
 sheet.modalPresentationStyle = UIModalPresentationPopover;
 UIPopoverPresentationController *popPC = sheet.popoverPresentationController;
 popPC.barButtonItem = self.BookMark;
 popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
 }
 [self presentViewController:sheet animated:YES completion:nil];
 
 }
 */

#pragma mark - 持久化相关代码
- (void)creatEditableCopyOfDatabaseIfNeed {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableDBPath = [self applicationDocumentsDirectoryEmptyFile];
    
    BOOL dbexits = [fileManager fileExistsAtPath:writableDBPath];
    if (!dbexits) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"MemberBlogList.plist"];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        NSAssert(success, @"错误写入文件");
    }
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"MemberBlogList.plist"];
    return path;
}

- (NSString *)applicationDocumentsDirectoryEmptyFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"MemberBlogList.plist"];
    self.blogModelArray = [[NSMutableArray alloc] initWithContentsOfFile:path];
    [self.blogModelArray removeAllObjects];
    [self.blogModelArray writeToFile:path atomically:YES];
    return path;
}

- (void)writeIntoBlogPlist:(NSArray *)blogDetailArray {
    
    NSString *path = [self applicationDocumentsDirectoryFile];
    
    //进行持久化
    for (int i = 0; i < 5; i++) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[[self.htmlCache substringWithRange:[[blogDetailArray objectAtIndex:i] rangeAtIndex:1]],
                                                                   [self.htmlCache substringWithRange:[[blogDetailArray objectAtIndex:i] rangeAtIndex:2]],
                                                                   [self.htmlCache substringWithRange:[[blogDetailArray objectAtIndex:i] rangeAtIndex:3]],
                                                                   [self.htmlCache substringWithRange:[[blogDetailArray objectAtIndex:i] rangeAtIndex:4]]]
                                                         forKeys:@[@"memberName",
                                                                   @"blogURL",
                                                                   @"blogTitle",
                                                                   @"releaseTime"]];
        //将字典转换成模型数据
        BlogModel *blog = [BlogModel blogWithDict:dict];
        [self.blogModelArray addObject:blog];
    }
    
    [self.blogModelArray writeToFile:path atomically:YES];
    
}

#pragma mark - 抓取博客代码
- (void)catchHTMLBlogs:(int)pageIndex {
    NSString *blogIndex = [NSString stringWithFormat:self.toBeCatchedblogURL, pageIndex];
    NSURL *blogURL = [NSURL URLWithString:blogIndex];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:blogURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0f];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (data) {
                                   self.htmlCache = [[NSString alloc] initWithData:data
                                                                          encoding:NSUTF8StringEncoding];
                                   self.catchedBlogs = [self findedResults:self.htmlCache];
                                   
                                   [self writeIntoBlogPlist:self.catchedBlogs];
                                   
                                   [self.tableView reloadData];
                                   [self reloadView:connectionError];
                               } else {
                                   [self reloadView:connectionError];
                               }
                           }];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
}

- (NSArray *)findedResults:(NSString *)html {
    
    NSRegularExpression *regexOfBlogCatch = [[NSRegularExpression alloc] initWithPattern:blogCatchPattern
                                                                                 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                   error:nil];
    
    NSArray *detailsOfBlog = [regexOfBlogCatch matchesInString:html
                                                       options:NSMatchingReportCompletion
                                                         range:NSMakeRange(0, html.length)];
    
    return detailsOfBlog;
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

#pragma mark - TabBar操作代码
- (void)showTabBar {
    if (self.tabBarController.tabBar.hidden == NO) {
        return;
    }
    UIView *contentView;
    if ([[self.tabBarController.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]]) {
        contentView = [self.tabBarController.view.subviews objectAtIndex:1];
    } else {
        contentView = [self.tabBarController.view.subviews objectAtIndex:0];
    }
    contentView.frame = CGRectMake(contentView.bounds.origin.x, contentView.bounds.origin.y,  contentView.bounds.size.width, contentView.bounds.size.height - self.tabBarController.tabBar.frame.size.height);
    self.tabBarController.tabBar.hidden = NO;
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
