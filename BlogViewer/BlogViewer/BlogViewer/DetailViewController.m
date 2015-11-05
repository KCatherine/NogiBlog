//
//  DetailViewController.m
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController () <MBProgressHUDDelegate> {
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
- (IBAction)backToPage:(id)sender;
- (IBAction)refreshPage:(id)sender;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.detailWebView.delegate = self;
    NSLog(@"%@", self.blogURL);
    NSURL *url = [NSURL URLWithString:self.blogURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self showActivityIndicatorViewInNavigationItem];
    [self.detailWebView loadRequest:request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
}

- (void)showActivityIndicatorViewInNavigationItem {

    // The hud will dispable all input on the view (use the higest view possible in the view hierarchy)
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    [self.navigationController.view addSubview:HUD];
    
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    
    // Show the HUD while the provided method executes in a new thread

    [HUD show:YES];
 
}

- (void)reloadView {
    [HUD hide:YES];
}


- (void)handleLongTouch {
//    NSLog(@"%@", _imgURL);
    if (_imgURL && _gesState == GESTURE_STATE_START) {

        UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"保存到手机"
                                                                       message:nil
                                                                preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *defaultButton = [UIAlertAction actionWithTitle:@"确定"
                                                                style:UIAlertActionStyleDefault
                                                              handler:^(UIAlertAction *action) {
                                                                  /*
                                                                  if (_imgURL) {
                                                                      NSLog(@"imgurl = %@", _imgURL);
                                                                  }
                                                                  */
                                                                  NSString *urlToSave = [self.detailWebView stringByEvaluatingJavaScriptFromString:_imgURL];
                                                                  /*
                                                                  NSLog(@"image url = %@", urlToSave);
                                                                  */
                                                                  NSData* data = [NSData dataWithContentsOfURL:[NSURL URLWithString:urlToSave]];
                                                                  UIImage* image = [UIImage imageWithData:data];
                                                                  
                                                                  //UIImageWriteToSavedPhotosAlbum(image, nil, nil,nil);
                                                                  /*
                                                                  NSLog(@"UIImageWriteToSavedPhotosAlbum = %@", urlToSave);
                                                                  */
                                                                  
                                                                  UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
                                                              }];
        UIAlertAction *cancelButton = [UIAlertAction actionWithTitle:@"取消"
                                                               style:UIAlertActionStyleCancel
                                                             handler:^(UIAlertAction *action) {
                                                                 
                                                             }];
        [sheet addAction:defaultButton];
        [sheet addAction:cancelButton];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            sheet.modalPresentationStyle = UIModalPresentationPopover;
            UIPopoverPresentationController *popPC = sheet.popoverPresentationController;
            popPC.sourceView = self.view;
            popPC.sourceRect = CGRectMake((CGRectGetWidth(self.view.bounds)-2)*0.5f, (CGRectGetHeight(self.view.bounds)-2)*0.5f, 2, 2);
            popPC.permittedArrowDirections = UIPopoverArrowDirectionAny;
        }
        [self presentViewController:sheet animated:YES completion:nil];
    }
}

- (void)showAlert:(NSString *)msg {

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确定"
                                                           style:UIAlertActionStyleDefault
                                                         handler:nil];
    [alert addAction:defaultAction];
    [self presentViewController:alert
                       animated:YES
                     completion:nil];
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError*)error contextInfo:(void*)contextInfo
{
    if (error){
        NSLog(@"Error");
        [self showAlert:@"保存失败..."];
    }else {
        NSLog(@"OK");
        [self showAlert:@"保存成功！"];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Webview代理方法
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self reloadView];
    [self.detailWebView stringByEvaluatingJavaScriptFromString:kTouchJavaScriptString];
    
    //清除JS缓存
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:@"WebKitCacheModelPreferenceKey"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitDiskImageCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"WebKitOfflineWebApplicationCacheEnabled"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    HUD.mode = MBProgressHUDModeText;
    HUD.labelText = @"出现错误";
    HUD.margin = 10.f;
    HUD.removeFromSuperViewOnHide = YES;
    [HUD hide:YES afterDelay:2];
    
    NSLog(@"错误为：%@", [error description]);
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    NSString *requestString = [[request URL] absoluteString];
    NSArray *components = [requestString componentsSeparatedByString:@":"];
    if ([components count] > 1 && [(NSString *)[components objectAtIndex:0]
                                   isEqualToString:@"myweb"]) {
        if([(NSString *)[components objectAtIndex:1] isEqualToString:@"touch"])
        {
            //NSLog(@"you are touching!");
            //NSTimeInterval delaytime = Delaytime;
            if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"start"])
            {
                /*
                 @需延时判断是否响应页面内的js...
                 */
                _gesState = GESTURE_STATE_START;
                NSLog(@"touch start!");
                
                float ptX = [[components objectAtIndex:3]floatValue];
                float ptY = [[components objectAtIndex:4]floatValue];
                NSLog(@"touch point (%f, %f)", ptX, ptY);

                NSString *js = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).tagName", ptX, ptY];
                NSString * tagName = [self.detailWebView stringByEvaluatingJavaScriptFromString:js];
                _imgURL = nil;
                if ([tagName isEqualToString:@"IMG"]) {
                    _imgURL = [NSString stringWithFormat:@"document.elementFromPoint(%f, %f).src", ptX, ptY];
                }
                if (_imgURL) {
                    _timer = [NSTimer scheduledTimerWithTimeInterval:1.25 target:self selector:@selector(handleLongTouch) userInfo:nil repeats:NO];
                }
            }
            else if ([(NSString *)[components objectAtIndex:2] isEqualToString:@"move"])
            {
                //**如果touch动作是滑动，则取消hanleLongTouch动作**//
                _gesState = GESTURE_STATE_MOVE;
                NSLog(@"you are move");
            }
            else if ([(NSString*)[components objectAtIndex:2]isEqualToString:@"end"]) {
                [_timer invalidate];
                _timer = nil;
                _gesState = GESTURE_STATE_END;
                NSLog(@"touch end");
            }
        }
        return NO;
    }
    return YES;
}

#pragma mark--UIPresentationController

- (void)popoverPresentationController:(UIPopoverPresentationController *)popoverPresentationController
          willRepositionPopoverToRect:(inout CGRect *)rect
                               inView:(inout UIView *__autoreleasing  _Nonnull *)view {
    *rect = CGRectMake((CGRectGetWidth((*view).bounds)-2)*0.5f, (CGRectGetHeight((*view).bounds)-2)*0.5f, 2, 2);// 显示在中心位置
}

#pragma mark - MBProgressHUDDelegate

- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [HUD removeFromSuperview];
    HUD = nil;
}


- (IBAction)backToPage:(id)sender {
    if ([self.detailWebView canGoBack]) {
        [self showActivityIndicatorViewInNavigationItem];
        [self.detailWebView goBack];
    }
}

- (IBAction)refreshPage:(id)sender {
    
    [self showActivityIndicatorViewInNavigationItem];
    [self.detailWebView reload];

}
@end
