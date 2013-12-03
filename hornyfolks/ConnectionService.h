//
//  ConnectionService.h
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionService : NSObject

+ (instancetype)sharedService;
- (void)parseck101Page:(NSString *)pageURL success:(void (^)(NSArray *elements, NSString *title))success fail:(void (^)())fail;

@end
