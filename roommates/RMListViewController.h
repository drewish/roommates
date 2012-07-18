//
//  RMListViewController.h
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "PullToRefreshView.h"
#import "RMData.h"

@interface RMListViewController : UITableViewController <PullToRefreshViewDelegate>

// Convert a date into a time ago string... should probably go some place else.
+ (NSString*)asTimeAgo:(NSDate*)date;

// Array of items returned by fetching.
@property (nonatomic, retain) NSArray* items;
// Optional dictionary of parameters to pass to the fetch.
@property (readonly) NSDictionary* fetchParams;

- (Class)dataClass;
- (void)fetchItems;

@end
