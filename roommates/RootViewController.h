//
//  RootViewController.h
//  roommates
//
//  Created by andrew morton on 7/13/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ZUUIRevealController.h"

@interface RootViewController : ZUUIRevealController

- (IBAction)showActivityFeed:(id)sender;
- (IBAction)showExpenses:(id)sender;
- (IBAction)showShoppingList:(id)sender;
- (IBAction)showTodos:(id)sender;
- (IBAction)showNotes:(id)sender;
- (IBAction)signOut:(id)sender;

@end
