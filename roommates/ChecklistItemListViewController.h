//
//  TodoListViewController.h
//  roommates
//
//  Created by andrew morton on 7/17/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMListViewController.h"

@interface ChecklistItemListViewController : RMListViewController <UITextFieldDelegate>

@property NSString *kind;

- (IBAction)add:(id)sender;

@end
