//
//  BlogTitleTableViewCell.m
//  BlogViewer
//
//  Created by 123456 on 15/8/1.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import "BlogTitleTableViewCell.h"

@interface BlogTitleTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *memberName;
@property (weak, nonatomic) IBOutlet UILabel *releaseTime;
@property (weak, nonatomic) IBOutlet UILabel *blogTitle;


@end

@implementation BlogTitleTableViewCell

/**
 *  将传入的模型放入Cell中
 */
- (void)setBlog:(BlogModel *)blog {
    _blog = blog;
    self.memberName.text = blog.memberName;
    self.releaseTime.text = blog.releaseTime;
    self.blogTitle.text = blog.blogTitle;
}

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
