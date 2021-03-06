//
//  BlogTitleTableViewCell.h
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BlogModel.h"

@interface BlogTitleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *memberIcon;

@property (strong, nonatomic) BlogModel *blog;

+ (instancetype)cellWithTableView:(UITableView *)tableView;

@end
