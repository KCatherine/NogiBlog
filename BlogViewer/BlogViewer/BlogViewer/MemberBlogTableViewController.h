//
//  MemberBlogTableViewController.h
//  BlogViewer
//
//  Created by 杨璟 on 15/12/23.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberBlogTableViewController : UITableViewController<UITableViewDataSource, UITableViewDelegate>

@property (copy, nonatomic) NSString *toBeCatchedblogURL;

@end
