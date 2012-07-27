//
//  ChecklistItemDetailViewController.h
//  roommates
//
//  Created by andrew morton on 7/18/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMData.h"

@interface ChecklistItemDetailViewController : UITableViewController <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UIButton *deleteButton;
@property (retain) RMChecklistItem *item;
- (IBAction)deleteItem:(id)sender;
- (IBAction)addComment:(id)sender;

@end
