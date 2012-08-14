//
//  MenuViewController.h
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RootViewController.h"

@interface MenuViewController : UITableViewController <UIActionSheetDelegate,
    UIPickerViewDataSource, UIPickerViewDelegate>
@property(nonatomic, strong) UIActionSheet *actionSheet;
@property(nonatomic, weak) RootViewController *rootController;
- (IBAction)signOut:(id)sender;
- (IBAction)switchHousehold:(id)sender;
@end
