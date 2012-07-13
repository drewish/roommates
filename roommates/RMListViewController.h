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

@property (nonatomic, weak) Class dataClass;
@property (nonatomic, retain) NSArray* items;

- (void)fetchItems;
- (NSString*)asTimeAgo:(NSDate*)date;

@end
