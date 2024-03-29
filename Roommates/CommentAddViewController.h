//
//  CommentAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/16/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAddViewController : UITableViewController <UITextViewDelegate>

@property NSString *commentableType;
@property NSNumber *commentableId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;

- (IBAction)done:(id)sender;

@end
