//
//  BlogModel.m
//  BlogViewer
//
//  Created by 杨璟 on 15/12/24.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import "BlogModel.h"

@implementation BlogModel

/**
 *  将传入的字典转换成模型存储
 */
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        self.memberName = dict[@"memberName"];
        self.blogTitle = dict[@"blogTitle"];
        self.blogURL = dict[@"blogURL"];
        self.releaseTime = dict[@"releaseTime"];
    }
    return self;
}

+ (instancetype)blogWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

@end
