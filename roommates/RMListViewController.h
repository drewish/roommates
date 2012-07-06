//
//  RMListViewController.h
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>
#import "RMSession.h"
#import "RMUser.h"
#import "RMHousehold.h"

@interface RMListViewController : UITableViewController

@property (nonatomic, weak) Class dataClass;
@property (nonatomic, retain) NSArray* items;

// TODO Needs a method for fetching the items
- (void)fetchItems;
@end
