//
//  ViewController.m
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import "ViewController.h"
#import "DetailViewController.h"
#import "BlogTitleTableViewCell.h"

#import "Reachability.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"

#define blogUrlString @"http://blog.nogizaka46.com/smph/?p=%d"
#define blogCatchPattern @"<td class=\"heading\"><span class=\"author\">(.*?)</span> <span class=\"entrytitle\"><a href=\"(.*?)\" rel=\"bookmark\">(.*?)</a></span></td>.*?<div class=\"kijifoot\">(.*?)｜.*?</div>"

@interface ViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (assign, nonatomic) NSInteger blogPageIndex;
@property (strong, nonatomic) NSString *htmlCache;
@property (strong, nonatomic) NSArray *catchedBlogs;

// /*图片与名称对应代码
@property (strong, nonatomic) NSDictionary *nameWithIcon;
@property (strong, nonatomic) NSArray *memberNameFromPlist;
@property (strong, nonatomic) NSArray *memberIconFromPlist;
// */
/*
- (IBAction)RefreshBlog:(id)sender;
- (IBAction)jumpToBlog:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BookMark;
*/

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
// /*设置图片与名称对称的代码
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"nameWithIcon" ofType:@"plist"];
    self.nameWithIcon = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    self.memberNameFromPlist = [self.nameWithIcon objectForKey:@"name"];
    self.memberIconFromPlist = [self.nameWithIcon objectForKey:@"icon"];
// */
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
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 30, 0);
    // 忽略掉底部inset
    self.tableView.footer.ignoredScrollViewContentInsetBottom = 30;
}

- (void)goToPage:(int)Index {
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread
    [HUD show:YES];
    
    if ([self isConnectionAvailable]) {

        [self catchHTMLBlogs:Index];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        
//        self.navigationItem.prompt = @"无法连接到服务器";
        return NO;
    }
    
    return isExistenceNetwork;
}


- (IBAction)RefreshBlog:(id)sender {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"BlogList.plist"];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    [array removeAllObjects];
    [array writeToFile:path atomically:YES];
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

//持久化相关代码
- (void)creatEditableCopyOfDatabaseIfNeed {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *writableDBPath = [self applicationDocumentsDirectoryFile];
    
    BOOL dbexits = [fileManager fileExistsAtPath:writableDBPath];
    if (!dbexits) {
        NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"BlogList.plist"];
        NSError *error;
        BOOL success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        NSAssert(success, @"错误写入文件");
    }
}

- (NSString *)applicationDocumentsDirectoryFile {
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentDirectory stringByAppendingPathComponent:@"BlogList.plist"];
    return path;
}

//抓取博客代码
- (void)catchHTMLBlogs:(int)pageIndex {
    NSString *blogIndex = [NSString stringWithFormat:blogUrlString, pageIndex];
    NSURL *blogURL = [NSURL URLWithString:blogIndex];

    NSURLRequest *request = [NSURLRequest requestWithURL:blogURL
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:10.0f];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               self.htmlCache = [[NSString alloc] initWithData:data
                                                                      encoding:NSUTF8StringEncoding];
                               self.catchedBlogs = [self findedResults:self.htmlCache];
                               
                               [self.tableView reloadData];
                               [self reloadView:connectionError];
                           }];
}

- (NSArray *)findedResults:(NSString *)html {
    
    NSRegularExpression *regexOfBlogCatch = [[NSRegularExpression alloc] initWithPattern:blogCatchPattern
                                                                                 options:NSRegularExpressionCaseInsensitive | NSRegularExpressionDotMatchesLineSeparators
                                                                                   error:nil];
    
    NSArray *detailsOfBlog = [regexOfBlogCatch matchesInString:html
                                                       options:NSMatchingReportCompletion
                                                         range:NSMakeRange(0, html.length)];
    //在异步加载中进行持久化
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    //进行持久化
    for (int i = 0; i < 5; i++) {
        NSDictionary *dict = [NSDictionary dictionaryWithObjects:@[[html substringWithRange:[[detailsOfBlog objectAtIndex:i] rangeAtIndex:1]],
                                                                   [html substringWithRange:[[detailsOfBlog objectAtIndex:i] rangeAtIndex:2]],
                                                                   [html substringWithRange:[[detailsOfBlog objectAtIndex:i] rangeAtIndex:3]],
                                                                   [html substringWithRange:[[detailsOfBlog objectAtIndex:i] rangeAtIndex:4]]]
                                                         forKeys:@[@"memberName",
                                                                   @"blogURL",
                                                                   @"blogTitle",
                                                                   @"releaseTime"]];
        [array addObject:dict];
    }
    
    [array writeToFile:path atomically:YES];
    
    return detailsOfBlog;
}

- (void)reloadView:(NSError *)connectionError {
    if (!connectionError) {
        self.navigationItem.prompt = nil;
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

#pragma marks - TableView代理方法

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    return [array count];
    
    //    return [self.catchedBlogs count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BlogTitleCell";
    BlogTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger row = [indexPath row];
    
    NSString *path = [self applicationDocumentsDirectoryFile];
    NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
    
    for (int i = 0; i <= row; i++) {
        cell.memberName.text = [[array objectAtIndex:i] objectForKey:@"memberName"];
        cell.blogTitle.text = [[array objectAtIndex:i] objectForKey:@"blogTitle"];
        cell.releaseTime.text = [[array objectAtIndex:i] objectForKey:@"releaseTime"];
    }
/*
    cell.memberName.text = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:row] rangeAtIndex:1]];
    cell.blogTitle.text = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:row] rangeAtIndex:3]];
    cell.releaseTime.text = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:row] rangeAtIndex:4]];
*/
    
// /*设置表格中成员图片代码
    NSUInteger nameAtRow = [self.memberNameFromPlist indexOfObject:cell.memberName.text];
    NSString *imagePath = [self.memberIconFromPlist objectAtIndex:nameAtRow];
    imagePath = [imagePath stringByAppendingString:@".JPG"];
    cell.memberIcon.image = [UIImage imageNamed:imagePath];
// */
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toWebView"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        
        NSString *path = [self applicationDocumentsDirectoryFile];
        NSMutableArray *array = [[NSMutableArray alloc] initWithContentsOfFile:path];
        
        detailViewController.blogURL = [[array objectAtIndex:selectedIndex] objectForKey:@"blogURL"];
        
        detailViewController.title = [[array objectAtIndex:selectedIndex] objectForKey:@"memberName"];
/*
        self.urlString = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:selectedIndex] rangeAtIndex:2]];
        
        detailViewController.blogURL = self.urlString;
        detailViewController.title = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:selectedIndex] rangeAtIndex:1]];
*/
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}

@end
