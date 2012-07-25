//
//  ExpenseAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/23/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpenseAddViewController : UITableViewController <UITextFieldDelegate>

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSDecimalNumber *amount;

- (IBAction)done:(id)sender;

@end