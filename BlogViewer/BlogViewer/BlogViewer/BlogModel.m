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
        self.blogTitle = dict[@"title"];
        self.memberName = dict[@"talent"];
        self.blogURL = dict[@"url"];
        self.releaseTime = dict[@"create"];
        self.uniqueID = dict[@"aid"];
        self.memberID = dict[@"sid"];
    }
    return self;
}

+ (instancetype)blogWithDict:(NSDictionary *)dict {
    return [[self alloc] initWithDict:dict];
}

+ (NSDictionary *)dictionaryWithModel:(BlogModel *)model {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"title"] = model.blogTitle;
    dict[@"talent"] = model.memberName;
    dict[@"url"] = model.blogURL;
    dict[@"create"] = model.releaseTime;
    dict[@"aid"] = model.uniqueID;
    dict[@"sid"] = model.memberID;
    return dict;
}

@end
