//
//  AppDelegate.h
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>

#define CK101BASE_PREFIX @"ck101BasePrefix"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    NSManagedObjectModel *managedObjectModel;
	NSManagedObjectContext *managedObjectContext;
	NSPersistentStoreCoordinator *persistentStoreCoordinator;
}

@property (nonatomic, strong) UIWindow *window;

@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;

@property (nonatomic) NSUInteger clipboardChangeCount;
@property (nonatomic) BOOL hasNewContext;
@property (nonatomic, strong) NSTimer *loop;

- (NSManagedObjectContext *)managedObjectContext;
- (NSString *)propertyFromPlist:(NSString *)file withKey:(NSString *)key;

@end
