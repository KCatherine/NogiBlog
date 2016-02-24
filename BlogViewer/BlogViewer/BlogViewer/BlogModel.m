//
//  BlogModel.m
//  BlogViewer
//
//  Created by 杨璟 on 15/12/24.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import "BlogModel.h"

#define TIME_ZONE 9*60*60

@implementation BlogModel

/**
 *  将传入的字典转换成模型存储
 */
- (instancetype)initWithDict:(NSDictionary *)dict {
    if (self = [super init]) {
        _blogTitle = dict[@"title"];
        _memberName = dict[@"talent"];
        _blogURL = dict[@"url"];
        _releaseTime = dict[@"create"];
        _uniqueID = dict[@"aid"];
        _memberID = dict[@"sid"];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
        NSDate *dataTime = [dateFormatter dateFromString:_releaseTime];
        
        NSDate *realTime = [dataTime dateByAddingTimeInterval:TIME_ZONE];
        _releaseTime = [dateFormatter stringFromDate:realTime];
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
