//
//  ConnectionService.m
//  ev8dloveck101
//
//  Created by Stan Tsai on 2013/12/3.
//  Copyright (c) 2013年 Stan Tsai. All rights reserved.
//

#import "ConnectionService.h"

#import "AppDelegate.h"
#import <hpple/TFHpple.h>
#import <AFNetworking/AFHTTPRequestOperation.h>

@implementation ConnectionService

+ (instancetype)sharedService
{
    static ConnectionService *_sharedService = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedService = [[self alloc] init];
    });
    
    return _sharedService;
}

- (void)parseck101Page:(NSString *)pageURL success:(void (^)(NSArray *elements, NSString *title))success fail:(void (^)())fail
{
    AppDelegate *appdelegate = [[UIApplication sharedApplication] delegate];
    if ([pageURL hasPrefix:[appdelegate propertyFromPlist:@"Settings" withKey:CK101BASE_PREFIX]]) {
        NSURL *url = [NSURL URLWithString:[pageURL stringByReplacingOccurrencesOfString:@" " withString:@""]];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];

        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            TFHpple *doc = [[TFHpple alloc] initWithData:responseObject isXML:NO];
            
            // observe title to avoiding redirect by ck101
            TFHppleElement *title = [doc peekAtSearchWithXPathQuery:@"//title"];
            if (title) {
                NSArray *hppleElements = [doc searchWithXPathQuery:@"//img/@file"];
                
                NSMutableArray *elements = [NSMutableArray array];
                
                for (TFHppleElement *element in hppleElements) {
                    [elements addObject:[[element firstTextChild] content]];
                }
                success([NSArray arrayWithArray:elements], [title text]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Network error", nil)
                                                            message:[error localizedDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
            [alert show];
            fail();
        }];
        
        [operation start];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"pattern not supported", nil)
                                                        message:NSLocalizedString(@"should be like this: http://ck101.com/thread-2593278-1-1.html", nil)
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", nil) otherButtonTitles:nil, nil];
        [alert show];
        fail();
    }
    
}
@end
