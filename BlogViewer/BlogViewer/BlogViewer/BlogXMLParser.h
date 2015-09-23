//
//  BlogXMLParser.h
//  BlogViewer
//
//  Created by 杨璟 on 15/9/11.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import <Foundation/Foundation.h>

#define blogXMLString @"http://blog.nogizaka46.com/atom.xml"

@interface BlogXMLParser : NSObject<NSXMLParserDelegate>

//解析出的数据内部
@property (strong, nonatomic) NSMutableArray *blogs;
@property (strong, nonatomic) NSMutableDictionary *tempAttributes;
//当前标签的名字
@property (strong, nonatomic) NSString *currentTagName;

//开始解析
-(void)start;

@end
