//
//  ViewController.m
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"

#import <SDWebImage/UIImageView+WebCache.h>
#import <MWPhoto.h>
#import <MWPhotoBrowser.h>

#import "ConnectionService.h"
#import "ListObject.h"

@interface ViewController ()

//@property (nonatomic, strong) NSMutableArray *listObjects;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *itemSizes;

@end

@implementation ViewController
@synthesize managedObjectContext;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        AppDelegate *appdelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.managedObjectContext = [appdelegate managedObjectContext];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(copyToClip) name:UIPasteboardChangedNotification object:nil];
    }
    
    return self;
}

- (void)getURLContext:(NSString *) url
{
    [self.navigationItem setTitle:@"Loading.."];
    
    ConnectionService *sharedService = [ConnectionService sharedService];
    [sharedService parseck101Page: url success:^(NSArray *elements, NSString *title) {
        // managed core data
        [self addRecordTitle:title URL:url];
        
        NSMutableArray *images = [NSMutableArray array];
        for (NSString *url in elements) {
            [images addObject:[MWPhoto photoWithURL:[NSURL URLWithString:url]]];
        }
        _images = [images copy];
        
        MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
        browser.displayActionButton = YES;
        browser.displayNavArrows = NO;
        browser.zoomPhotosToFill = YES;
        [browser setCurrentPhotoIndex:0];
        [self.navigationItem setTitle:@"ck101 folks"];
        [self.navigationController pushViewController:browser animated:YES];
    } fail:^{
        [self.navigationItem setTitle:@"ck101 folks"];
    }];
}

#pragma mark -
#pragma mark MWPhotoBrowserDelegate

- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser {
    return _images.count;
}

- (MWPhoto *)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index {
    if (index < _images.count)
        return [_images objectAtIndex:index];
    return nil;
}

- (void)photoBrowser:(MWPhotoBrowser *)photoBrowser didDisplayPhotoAtIndex:(NSUInteger)index {
//    NSLog(@"Did start viewing photo at index %i", index);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setTitle:@"ck101 folks"];
    [self fetchRecords];
}

#pragma mark -
#pragma mark Actions

- (void)fetchRecords
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:NSStringFromClass([ListObject class])];
    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"createdAt" ascending:NO];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    [request setSortDescriptors:sortDescriptors];
    
    NSError *error;
    
    // Setup fetched results
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                        managedObjectContext:managedObjectContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
    [self.fetchedResultsController setDelegate:self];
    
    BOOL fetchSuccessful = [self.fetchedResultsController performFetch:&error];
    if (!fetchSuccessful)
        NSLog(@"%@", [error localizedDescription]);
}

- (void)addRecordTitle:(NSString *)title URL:(NSString *)url
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"ListObject" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"url == %@", url];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSError *error;
    
    ListObject *object;
    NSArray *requestObject = [managedObjectContext executeFetchRequest:request error:&error];
    
    if ([requestObject count] > 0) {
        object = [requestObject objectAtIndex:0];
        NSLog(@"exist");
    } else {
        object = (ListObject *)[NSEntityDescription insertNewObjectForEntityForName:@"ListObject" inManagedObjectContext:managedObjectContext];
    }
    [object setCreatedAt:[NSDate date]];
    [object setUrl:url];
    [object setTitle:title];
    
    
    if (![managedObjectContext save:&error]) {
        // Errors
        NSLog(@"record cannot be saved: %@", [error localizedDescription]);
    }
}

- (void)copyToClip
{
    NSLog(@"notification");
}

- (IBAction)generateFromClipboard:(id)sender
{
    [self getURLContext:[[UIPasteboard generalPasteboard] string]];
}

#pragma mark - 
#pragma mark NSFetchedResultsControllerDelegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller{
    
    [self.tableView reloadData];
    
}

#pragma mark -
#pragma mark TableView datasource

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id  sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    
    return [sectionInfo name];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark -
#pragma mark TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    static NSDateFormatter *dateFormatter = nil;
    if (dateFormatter == nil) {
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"h:mm.ss a"];
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    ListObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];

    [cell.textLabel setText:[object title]];
    [cell.detailTextLabel setText: [dateFormatter stringFromDate: [object createdAt]]];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ListObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [self getURLContext:object.url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
