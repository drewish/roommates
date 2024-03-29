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

// Handles our pull to refresh, sub classes need access.
@property (readonly) PullToRefreshView *pull;
// Array of items returned by fetching.
@property (nonatomic, retain) NSMutableArray* items;
// Optional dictionary of parameters to pass to the fetch.
@property (readonly) NSDictionary* fetchParams;

- (IBAction)addTransaction:(id)sender;
- (IBAction)addNote:(id)sender;
- (IBAction)takePhoto:(id)sender;

- (Class)dataClass;
- (void)fetchItems;
- (void)attachObservers;

@end
