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

// Array of items returned by fetching.
@property (nonatomic, retain) NSMutableArray* items;
// Optional dictionary of parameters to pass to the fetch.
@property (readonly) NSDictionary* fetchParams;

- (Class)dataClass;
- (void)fetchItems;

@end
