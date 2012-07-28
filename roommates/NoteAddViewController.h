//
//  NoteAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteAddViewController : UIViewController <UITextViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>


@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UIImageView *photoImage;

- (IBAction)done:(id)sender;
- (IBAction)attachPhoto:(id)sender;

@end
