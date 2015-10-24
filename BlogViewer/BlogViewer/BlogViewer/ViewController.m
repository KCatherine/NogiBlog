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
#import "BlogXMLParser.h"
#import "MBProgressHUD.h"

#define blogXMLString @"http://blog.nogizaka46.com/atom.xml"
#define blogUrlString @"http://blog.nogizaka46.com/smph/?p=%d"
#define blogCatchPattern @"<td class=\"heading\"><span class=\"author\">(.*?)</span> <span class=\"entrytitle\"><a href=\"(.*?)\" rel=\"bookmark\">(.*?)</a></span></td>.*?<div class=\"kijifoot\">(.*?)｜.*?</div>"

@interface ViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}
@property (strong, nonatomic) NSString *htmlCache;
@property (strong, nonatomic) NSArray *catchedBlogs;
/*
@property (strong, nonatomic) NSMutableArray *blogs;
*/
@property (strong, nonatomic) NSDictionary *nameWithIcon;
@property (strong, nonatomic) NSArray *memberNameFromPlist;
@property (strong, nonatomic) NSArray *memberIconFromPlist;

- (IBAction)RefreshBlog:(id)sender;
- (IBAction)jumpToBlog:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *BookMark;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    NSBundle *bundle = [NSBundle mainBundle];
    NSString *plistPath = [bundle pathForResource:@"nameWithIcon" ofType:@"plist"];
    self.nameWithIcon = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    self.memberNameFromPlist = [self.nameWithIcon objectForKey:@"name"];
    self.memberIconFromPlist = [self.nameWithIcon objectForKey:@"icon"];
    
    [self goToPage:1];

/*
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadView:)
                                                 name:@"reloadViewNotification"
                                               object:nil];
    BlogXMLParser *parser = [BlogXMLParser new];
    [parser start];
*/
}

- (void)goToPage:(int)Index {
    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    [HUD show:YES];
    if ([self isConnectionAvailable]) {
//        self.navigationItem.prompt = @"数据加载中...";

        // Show the HUD while the provided method executes in a new thread
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
    [self goToPage:1];
}

- (IBAction)jumpToBlog:(id)sender {

    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择你想查看的页面"
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *pageOne = [UIAlertAction actionWithTitle:@"第一页"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction *action) {
                                                        [self goToPage:1];
                                                        self.navigationItem.title = @"最新动态";
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

/*
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:blogURL];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request
                                                                  delegate:self];
    if (connection) {
        self.htmlCache = [NSString new];
    }
*/
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

- (void)reloadView:(NSError *)connectionError {
    if (!connectionError) {
        self.navigationItem.prompt = nil;
        [HUD hide:YES];
    } else {
        
        HUD.mode = MBProgressHUDModeText;
        HUD.labelText = @"请求超时";
        HUD.margin = 10.f;
        HUD.removeFromSuperViewOnHide = YES;
        [HUD hide:YES afterDelay:2];
        
//        self.navigationItem.prompt = @"请求超时";
    }
    
}


/*
- (void)reloadView:(NSNotification *)notification {
    NSMutableArray *resList = [notification object];
    self.blogs = resList;
    [self.tableView reloadData];
}
*/

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}

#pragma marks - TableView代理方法

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return [self.catchedBlogs count];
//    return self.blogs.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"BlogTitleCell";
    BlogTitleTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSUInteger row = [indexPath row];

    cell.memberName.text = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:row] rangeAtIndex:1]];
    cell.blogTitle.text = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:row] rangeAtIndex:3]];
    cell.releaseTime.text = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:row] rangeAtIndex:4]];

/*
    NSMutableDictionary *detailOfBlog = self.blogs[row];
    cell.memberName.text = [detailOfBlog objectForKey:@"blogAuthor"];
    cell.blogTitle.text = [detailOfBlog objectForKey:@"blogTitle"];
    cell.releaseTime.text = [detailOfBlog objectForKey:@"blogTime"];
*/
    NSUInteger nameAtRow = [self.memberNameFromPlist indexOfObject:cell.memberName.text];
    NSString *imagePath = [self.memberIconFromPlist objectAtIndex:nameAtRow];
    imagePath = [imagePath stringByAppendingString:@".JPG"];
    cell.memberIcon.image = [UIImage imageNamed:imagePath];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue
                 sender:(id)sender {
    if ([segue.identifier isEqualToString:@"toWebView"]) {
        DetailViewController *detailViewController = segue.destinationViewController;
        NSInteger selectedIndex = [[self.tableView indexPathForSelectedRow] row];
        self.urlString = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:selectedIndex] rangeAtIndex:2]];
        
//        self.urlString = [[self.blogs objectAtIndex:selectedIndex] objectForKey:@"blogLink"];
        
        detailViewController.blogURL = self.urlString;
        detailViewController.title = [self.htmlCache substringWithRange:[[self.catchedBlogs objectAtIndex:selectedIndex] rangeAtIndex:1]];
        
//        detailViewController.title = [[self.blogs objectAtIndex:selectedIndex] objectForKey:@"blogAuthor"];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath
                                  animated:YES];
}
/*
#pragma mark - NSURLConnection回调方法

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data {
    self.htmlCache = [[NSString alloc] initWithData:data
                                           encoding:NSUTF8StringEncoding];
    self.catchedBlogs = [self findedResults:self.htmlCache];
    [self.tableView reloadData];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error {
    [self reloadView:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.tableView reloadData];
}
*/

@end
