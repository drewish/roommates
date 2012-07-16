//
//  CommentAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentAddViewController : UIViewController <UITextViewDelegate>

@property NSString *commentableType;
@property NSNumber *commentableId;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;

- (IBAction)done:(id)sender;

@end
