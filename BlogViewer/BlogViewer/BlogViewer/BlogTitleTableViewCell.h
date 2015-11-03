//
//  BlogTitleTableViewCell.h
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BlogTitleTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *memberName;
@property (weak, nonatomic) IBOutlet UILabel *releaseTime;
@property (weak, nonatomic) IBOutlet UILabel *blogTitle;

@end
