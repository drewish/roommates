//
//  NoteAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NoteAddViewController.h"
#import "RMData.h"

@implementation NoteAddViewController

@synthesize doneButton;
@synthesize bodyText;

-(void)viewDidLoad {
    [bodyText.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [bodyText.layer setBorderWidth: 1.0];
    [bodyText.layer setCornerRadius:10.0];
    [bodyText.layer setMasksToBounds:YES];
    [bodyText.layer setShadowRadius:5.0];

    [bodyText becomeFirstResponder];
}

- (void)viewDidUnload {
    [self setBodyText:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

-(void)textViewDidChange:(UITextView *)textView
{
    doneButton.enabled = textView.hasText;
}

- (IBAction)done:(id)sender {
    // FIXME: let them pick the image instead of hardcoding this test image.
    UIImage* image = [UIImage imageNamed:@"purty_wood.png"];

    [SVProgressHUD showWithStatus:@"Posting"];

    [RMNote postNote:bodyText.text image:image onSuccess:^(id obj){
        NSLog(@"posted ...%@", obj);
        [SVProgressHUD showSuccessWithStatus:@""];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

@end
