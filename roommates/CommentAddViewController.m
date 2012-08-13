//
//  CommentAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/16/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CommentAddViewController.h"
#import "RMData.h"


@implementation CommentAddViewController {
    RMComment *comment;
}

@synthesize doneButton;
@synthesize bodyText;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        comment = [RMComment new];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    CALayer *layer = bodyText.layer;
    layer.backgroundColor = [[UIColor whiteColor] CGColor];
    layer.borderColor = [[UIColor grayColor] CGColor];
    layer.borderWidth = 1.0;
    layer.cornerRadius = 10.0;
    layer.masksToBounds = YES;
    layer.shadowRadius = 5.0;

    [bodyText becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setBodyText:nil];
    [self setDoneButton:nil];
    [super viewDidUnload];
}

-(void)setCommentableId:(NSNumber *)commentableId
{
    comment.commentableId = commentableId;
}
-(NSNumber *)commentableId
{
    return comment.commentableId;
}

-(void)setCommentableType:(NSString *)commentableType
{
    comment.commentableType = commentableType;
}
-(NSString *)commentableType
{
    return comment.commentableType;
}

-(void)textViewDidChange:(UITextView *)textView
{
    comment.body = textView.text;
    doneButton.enabled = textView.hasText;
}

- (IBAction)done:(id)sender {
    [SVProgressHUD showWithStatus:@"Posting"];

    [comment postOnSuccess:^(id obj){
        NSLog(@"posted ...%@", obj);
        [SVProgressHUD showSuccessWithStatus:@""];
        [TestFlight passCheckpoint:@"Create comment"];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

@end
