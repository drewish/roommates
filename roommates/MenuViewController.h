//
//  MenuViewController.h
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZUUIRevealController.h"

@interface MenuViewController : UITableViewController <UIActionSheetDelegate,
    UIPickerViewDataSource, UIPickerViewDelegate>
@property(nonatomic) UIActionSheet *actionSheet;
@property(nonatomic, weak) ZUUIRevealController *revealController;
- (IBAction)signOut:(id)sender;
- (IBAction)switchHousehold:(id)sender;
@end
