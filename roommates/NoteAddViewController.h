//
//  NoteAddViewController.h
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoteAddViewController : UITableViewController <UITextViewDelegate,
UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *bodyText;

@property (retain, nonatomic) NSString *body;
@property (retain, nonatomic) UIImage *photo;

- (IBAction)cancel:(id)sender;
- (IBAction)done:(id)sender;
- (IBAction)attachPhoto:(id)sender;

@end
