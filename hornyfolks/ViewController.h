//
//  ViewController.h
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MWPhotoBrowser.h>

@interface ViewController : UITableViewController <MWPhotoBrowserDelegate, NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

- (IBAction)generateFromClipboard:(id)sender;

- (void)getURLContext:(NSString *) url;

@end
