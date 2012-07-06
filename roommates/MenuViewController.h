//
//  MenuViewController.h
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZUUIRevealController.h"

@interface MenuViewController : UITableViewController
@property(nonatomic, weak) ZUUIRevealController *revealController;
- (IBAction)showActivityFeed:(id)sender;
- (IBAction)showExpenses:(id)sender;
- (IBAction)showShoppingList:(id)sender;
- (IBAction)showTodos:(id)sender;
- (IBAction)showNotes:(id)sender;
- (IBAction)signOut:(id)sender;
- (IBAction)switchHousehold:(id)sender;
@end
