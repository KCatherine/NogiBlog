//
//  BlogXMLParser.m
//  BlogViewer
//
//  Created by 杨璟 on 15/9/11.
//  Copyright (c) 2015年 YangJing. All rights reserved.
//

#import "BlogXMLParser.h"

@implementation BlogXMLParser

-(void)start
{
    NSURL *blogUrl = [NSURL fileURLWithPath:blogXMLString];
    //开始解析XML
    NSXMLParser *blogParser = [[NSXMLParser alloc] initWithContentsOfURL:blogUrl];
    blogParser.delegate = self;
    [blogParser parse];
    NSLog(@"解析完成...");
}

//文档开始的时候触发
- (void)parserDidStartDocument:(NSXMLParser *)parser
{
    _blogs = [NSMutableArray new];
    _tempAttributes = [NSMutableDictionary new];
}

//文档出错的时候触发
- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"%@",parseError);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    _currentTagName = elementName;
    NSLog(@"_currentTagName = %@",_currentTagName);
    if ([_currentTagName isEqualToString:@"entry"]) {
        NSMutableDictionary *dict = [NSMutableDictionary new];
        [_blogs addObject:dict];
        _tempAttributes = dict;
    }
    else if (_tempAttributes) {
        if ([_currentTagName isEqualToString:@"link"]) {
            NSString *_blogstring = [attributeDict objectForKey:@"href"];
            [_tempAttributes setObject:_blogstring forKey:@"blogLink"];
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([string isEqualToString:@""]) {
        return;
    }
    NSMutableDictionary *dict = [_blogs lastObject];
    if ([_currentTagName isEqualToString:@"title"] && dict) {
        [dict setObject:string forKey:@"blogTitle"];
    }
    if ([_currentTagName isEqualToString:@"name"] && dict) {
        [dict setObject:string forKey:@"blogAuthor"];
    }
    if ([_currentTagName isEqualToString:@"published"]) {
        [dict setObject:string forKey:@"blogTime"];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    self.currentTagName = nil;
}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadViewNotification"
                                                        object:self.blogs
                                                      userInfo:nil];
    self.blogs = nil;
    self.tempAttributes = nil;
}

@end
