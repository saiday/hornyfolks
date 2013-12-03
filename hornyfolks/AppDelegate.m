//
//  AppDelegate.m
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@implementation AppDelegate
@synthesize loop;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}

#pragma mark -
#pragma mark Core Data stack

/**
 Returns the managed object context for the application.
 If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
 */
- (NSManagedObjectContext *) managedObjectContext {
	
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
	
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator: coordinator];
    }
    return managedObjectContext;
}


/**
 Returns the managed object model for the application.
 If the model doesn't already exist, it is created by merging all of the models found in the application bundle.
 */
- (NSManagedObjectModel *)managedObjectModel {
	
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil] ;
    return managedObjectModel;
}


/**
 Returns the persistent store coordinator for the application.
 If the coordinator doesn't already exist, it is created and the application's store added to it.
 */
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
	
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
	
    NSURL *storeUrl = [NSURL fileURLWithPath: [[self applicationDocumentsDirectory] stringByAppendingPathComponent: @"ev8dloveck101.sqlite"]];
	
	NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error]) {
		/*
		 Replace this implementation with code to handle the error appropriately.
		 
		 abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
		 
		 Typical reasons for an error here include:
		 * The persistent store is not accessible
		 * The schema for the persistent store is incompatible with current managed object model
		 Check the error message to determine what the actual problem was.
		 */
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
	
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Application's Documents directory

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    self.hasNewContext = NO;
    self.clipboardChangeCount = [[UIPasteboard generalPasteboard] changeCount];
    
    [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
    loop = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(Update) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:loop forMode:NSRunLoopCommonModes];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)Update
{
    if (self.clipboardChangeCount != [[UIPasteboard generalPasteboard] changeCount]) {
        self.clipboardChangeCount = [[UIPasteboard generalPasteboard] changeCount];
        
        NSString *clipboardString = [[UIPasteboard generalPasteboard] string];
        if ([clipboardString hasPrefix:[self propertyFromPlist:@"Settings" withKey:CK101BASE_PREFIX]]) {
            self.hasNewContext = YES;
            
            UILocalNotification *notification= [[UILocalNotification alloc] init];
            if (notification != nil) {
                NSDate *now=[NSDate new];
                notification.fireDate = now;
                notification.timeZone = [NSTimeZone defaultTimeZone];
                notification.alertBody = NSLocalizedString(@"Open ck101 folks gallery?", nil);
                [[UIApplication sharedApplication] scheduleLocalNotification:notification];
            }
        }
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [loop invalidate];
    if (self.hasNewContext) {
        UINavigationController *navController = (UINavigationController *)self.window.rootViewController;
        ViewController *vc = (ViewController *)navController.topViewController;
        [vc getURLContext:[[UIPasteboard generalPasteboard] string]];
    }
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (NSString *)propertyFromPlist:(NSString *)file withKey:(NSString *)key
{
    NSString *bundlePathofPlist = [[NSBundle mainBundle] pathForResource:file ofType:@"plist"];
    NSAssert(bundlePathofPlist.length > 0, ([NSString stringWithFormat:@"Couldn't find %@.plist",file]));
    
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:bundlePathofPlist];
    NSString *value = [dict objectForKey:key];
    NSAssert(value.length > 0, ([NSString stringWithFormat:@"No value for key '%@' in %@", key, file]));
    
    return value;
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"going to be killed");
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
