//
//  CommentAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CommentAddViewController.h"
#import "RMData.h"


@implementation CommentAddViewController

@synthesize commentableType;
@synthesize commentableId;
@synthesize doneButton;
@synthesize bodyText;


- (void)viewDidLoad {
    [bodyText.layer setBackgroundColor: [[UIColor whiteColor] CGColor]];
    [bodyText.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [bodyText.layer setBorderWidth: 1.0];
    [bodyText.layer setCornerRadius:10.0];
    [bodyText.layer setMasksToBounds:YES];
    [bodyText.layer setShadowRadius:5.0];
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
    [SVProgressHUD showWithStatus:@"Posting"];

    [RMComment post:bodyText.text toId:commentableId ofType:commentableType onSuccess:^(id obj){
        NSLog(@"posted ...%@", obj);
        // TODO: Need to get all this UI code out of here and into callbacks.
        [SVProgressHUD dismiss];
        
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];

}

@end
