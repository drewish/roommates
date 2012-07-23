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

@interface ExpensesSummaryViewController : UITableViewController <PullToRefreshViewDelegate>

- (void)fetchItems;
- (IBAction)testIt:(id)sender;

@end
