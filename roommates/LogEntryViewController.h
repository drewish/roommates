//
//  LogEntryViewController.h
//  roommates
//
//  Created by andrew morton on 6/29/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface LogEntryViewController : UITableViewController <UITableViewDelegate,
    UITableViewDataSource, RKObjectLoaderDelegate>

@property (nonatomic, retain) NSArray* logEntries;

@end
