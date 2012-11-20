//
//  UserViewController.h
//  roommates
//
//  Created by andrew morton on 7/12/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMData.h"

@interface UserViewController : UITableViewController

@property(strong, nonatomic) void(^onSelect)(RMUser *user);
@property(weak, nonatomic) RMUser* user;

@end
