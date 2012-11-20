//
//  ReimbursalAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/12/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMData.h"

@interface ReimbursalAddViewController : UITableViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *amountText;
@property (weak, nonatomic) IBOutlet UITableViewCell *toUserCell;
@property (weak, nonatomic) IBOutlet UITableViewCell *fromUserCell;
@property (retain, nonatomic) RMUser *fromUser;
@property (retain, nonatomic) RMUser *toUser;
@property (retain, nonatomic) NSDecimalNumber *amount;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;

@end
