//
//  ExpenseAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/23/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMPhotoable.h"

@interface ExpenseAddViewController : UITableViewController <UITextViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate, RMPhotoable>

@property (retain, nonatomic) NSString *name;
@property (retain, nonatomic) NSDecimalNumber *amount;
@property (retain, nonatomic) UIImage *photo;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
