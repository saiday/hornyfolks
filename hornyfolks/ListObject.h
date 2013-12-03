//
//  ListObject.h
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

@interface ListObject : NSManagedObject

@property (nonatomic, strong) NSNumber *objID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSDate *createdAt;

@end
