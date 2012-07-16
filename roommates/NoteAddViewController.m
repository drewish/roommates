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
    // This stuff was lifted from: http://nachbaur.com/blog/fun-shadow-effects-using-custom-calayer-shadowpaths
    bodyText.layer.shadowColor = [UIColor blackColor].CGColor;
    bodyText.layer.shadowOpacity = 0.7f;
    bodyText.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    bodyText.layer.shadowRadius = 3.0f;
    bodyText.layer.masksToBounds = NO;
    // Did some tweaking here... They were using a UIImage which seems like it
    // computes it's bounds differently. I think it might have been because I
    // zeroed out the UITextView's content insets.
    CGRect f = bodyText.frame;
    CGSize size = CGSizeMake(f.size.width, f.size.height - f.origin.y);
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    bodyText.layer.shadowPath = path.CGPath;

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
    [RMNote postNote:bodyText.text onSuccess:^(id obj){
        NSLog(@"posted ...%@", obj);
        // TODO: Need to get all this UI code out of here and into callbacks.
        [SVProgressHUD dismiss];
        
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
    [SVProgressHUD showWithStatus:@"Posting"];
}

@end
