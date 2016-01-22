//
//  BlogModel.h
//  BlogViewer
//
//  Created by 杨璟 on 15/12/24.
//  Copyright © 2015年 YangJing. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BlogModel : NSObject

@property (nonatomic, copy) NSString *memberName;
@property (nonatomic, copy) NSString *memberID;
@property (nonatomic, copy) NSString *releaseTime;
@property (nonatomic, copy) NSString *blogURL;
@property (nonatomic, copy) NSString *blogTitle;
@property (nonatomic, copy) NSString *uniqueID;

- (instancetype)initWithDict:(NSDictionary *)dict;
+ (instancetype)blogWithDict:(NSDictionary *)dict;
+ (NSDictionary *)dictionaryWithModel:(BlogModel *)model;

@end
