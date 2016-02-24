//
//  ViewController.m
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import "BlogModel.h"
#import "AppDelegate.h"
#import "ViewController.h"
#import "DetailViewController.h"
#import "BlogTitleTableViewCell.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"
#import "AFNetworking.h"

#define REQUEST_HTML @"http://akbdata.com/json/i/v2/blog/5/200/0"

@interface ViewController () <MBProgressHUDDelegate, NSURLSessionDataDelegate> {
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) NSMutableArray *blogModelArray;
@property (nonatomic, strong) NSMutableArray *blogDictArray;
@property (nonatomic, assign) long long expectedLength;
@property (nonatomic, assign) long long currentLength;



@end

@implementation ViewController {
    AppDelegate *_appDelegate;
}

- (NSMutableArray *)blogModelArray {
    if (!_blogModelArray) {
        NSMutableArray *Array = [NSMutableArray arrayWithContentsOfFile:[self applicationDocumentsDirectoryEmptyFile]];
        _blogModelArray = Array;
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
    
    [self refreshBlogs:nil];
    
#warning unfinished 未完成的下拉刷新
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        
    }];
    
    // 设置了底部inset
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
    // 忽略掉底部inset
    self.tableView.footer.ignoredScrollViewContentInsetBottom = 20;
    
    //设置NavigationBar字体的颜色
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    //设置返回按钮
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@""
                                                             style:UIBarButtonItemStylePlain
                                                            target:nil
                                                            action:nil];
    self.navigationItem.backBarButtonItem = item;
    
}

- (void)dealloc {
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

#pragma mark - 判断设备网络状态

- (BOOL)isConnectionAvailable {
    
    BOOL isExistenceNetwork = YES;
    Reachability *reach = [Reachability reachabilityWithHostName:@"http://akbdata.com"];
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

#warning don't effective now
#pragma mark - AFN判断网络状态

- (void)networkReachability {
    
    SCNetworkReachabilityRef ref = SCNetworkReachabilityCreateWithName(NULL, [@"http://akbdata.com" UTF8String]);
    
    AFNetworkReachabilityManager *mgr = [[AFNetworkReachabilityManager alloc] initWithReachability:ref];
    [mgr setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = @"正在使用WiFi";
                HUD.margin = 10.f;
                HUD.removeFromSuperViewOnHide = YES;
                [HUD hide:YES afterDelay:2];
                break;
                
            case AFNetworkReachabilityStatusReachableViaWWAN:
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = @"正在使用蜂窝网络";
                HUD.margin = 10.f;
                HUD.removeFromSuperViewOnHide = YES;
                [HUD hide:YES afterDelay:2];
                break;
                
            case AFNetworkReachabilityStatusNotReachable:
                HUD.mode = MBProgressHUDModeText;
                HUD.labelText = @"无法连接到服务器";
                HUD.margin = 10.f;
                HUD.removeFromSuperViewOnHide = YES;
                [HUD hide:YES afterDelay:5];
                break;
                
            default:
                break;
        }
    }];
    [mgr startMonitoring];
}

#pragma mark - NSURLConnection获取数据

- (void)startRequest {
    
    NSURL *url = [NSURL URLWithString:REQUEST_HTML];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                               if (data == nil || connectionError) {
                                   [self reloadView:connectionError];
                               } else {
                                   NSArray *allData = [NSJSONSerialization JSONObjectWithData:data
                                                                                      options:NSJSONReadingMutableLeaves
                                                                                        error:nil];
                                   for (NSDictionary *dict in allData) {
                                       BlogModel *oneBlog = [BlogModel blogWithDict:dict];
                                       [self.blogModelArray addObject:oneBlog];
                                   }
                               }
                               [self reloadView:connectionError];
                               [self.tableView reloadData];
                               for (BlogModel *model in self.blogModelArray) {
                                   NSDictionary *dict = [BlogModel dictionaryWithModel:model];
                                   [self.blogDictArray addObject:dict];
                               }
                               NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BlogList.plist"];
                               [self.blogDictArray writeToFile:path
                                                    atomically:YES];
                           }];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    HUD.delegate = self;
}

#pragma mark - NSURLSession获取数据

- (void)sessionRequest {
    NSURLSessionConfiguration *cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:cfg
                                                          delegate:self
                                                     delegateQueue:[NSOperationQueue mainQueue]];
    NSURL *url = [NSURL URLWithString:REQUEST_HTML];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                                                if (data == nil || error) {
                                                    [self reloadView:error];
                                                } else {
                                                    NSArray *allData = [NSJSONSerialization JSONObjectWithData:data
                                                                                                       options:NSJSONReadingMutableLeaves
                                                                                                         error:nil];
                                                    for (NSDictionary *dict in allData) {
                                                        BlogModel *oneBlog = [BlogModel blogWithDict:dict];
                                                        [self.blogModelArray addObject:oneBlog];
                                                    }
                                                    NSLog(@"%@", [NSThread currentThread]);
                                                    [self reloadView:error];
                                                }
                                                [self.tableView reloadData];
                                                
                                                //        不用写入文件
                                                //        for (BlogModel *model in self.blogModelArray) {
                                                //            NSDictionary *dict = [BlogModel dictionaryWithModel:model];
                                                //            [self.blogDictArray addObject:dict];
                                                //        }
                                                //        NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"BlogList.plist"];
                                                //        [self.blogDictArray writeToFile:path atomically:YES];
                                            }];
    [task resume];
    
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                               animated:YES];
    HUD.delegate = self;
}

#pragma mark - 使用AFNetworking获得数据

- (void)usingAFN {
    
    AFHTTPSessionManager *mgr = [AFHTTPSessionManager manager];
    [mgr GET:REQUEST_HTML
  parameters:nil
    progress:nil
     success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
         [self.blogModelArray removeAllObjects];
         NSArray *allData = (NSArray *)responseObject;
         for (NSDictionary *dict in allData) {
             BlogModel *oneBlog = [BlogModel blogWithDict:dict];
             [self.blogModelArray addObject:oneBlog];
         }
         [self reloadView:nil];
         [self.tableView reloadData];
     }
     failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
         NSLog(@"出错");
     }];
    HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view
                               animated:YES];
    HUD.delegate = self;
}

#pragma mark - 刷新博客

- (IBAction)refreshBlogs:(id)sender {
    if ([self isConnectionAvailable]) {
        //        [self startRequest];
        //        [self sessionRequest];
        [self usingAFN];
    }
}

#pragma mark - 持久化相关代码

- (NSString *)applicationDocumentsDirectoryEmptyFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"BlogList.plist"];
    NSMutableArray *all = [[NSMutableArray alloc] initWithContentsOfFile:path];
    [all removeAllObjects];
    [all writeToFile:path atomically:YES];
    return path;
}

#pragma mark - 刷新HUD

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

#pragma mark - MBProgressHUD代理方法

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
    
    BlogTitleTableViewCell *cell = [BlogTitleTableViewCell cellWithTableView:tableView];
    
    //将模型传给Cell
    BlogModel *blog = self.blogModelArray[indexPath.row];
    cell.blog = blog;
    
    
    // /*设置表格中成员图片代码
    NSInteger nameAtRow = [_appDelegate.memberNameFromPlist indexOfObject:blog.memberName];
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
    if ([segue.identifier isEqualToString:@"fromTopToWebView"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        BlogModel *blog = self.blogModelArray[selectedIndex];
        
        detailViewController.blogURL = blog.blogURL;
        
        detailViewController.title = blog.memberName;
        
    }
}

@end
