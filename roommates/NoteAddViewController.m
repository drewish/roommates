//
//  NoteAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "NoteAddViewController.h"
#import "RMHousehold.h"

@implementation NoteAddViewController
@synthesize doneButton;
@synthesize bodyText;

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

    RKObjectManager *mgr = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"/api/households/%@/notes", RMHousehold.current.householdId];

    [mgr.client post:path usingBlock:^(RKRequest *request) {
        NSDictionary *note = [NSDictionary dictionaryWithObjectsAndKeys:
                              bodyText.text, @"body", 
                              nil];
        request.params = [NSDictionary dictionaryWithObject:note forKey:@"note"];
        request.onDidLoadResponse = ^(RKResponse *response) {
            [SVProgressHUD dismiss];

            // Check for validation errors.
            if (response.statusCode == 422) {
                NSError *parseError = nil;
                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
                NSMutableString *feedback = [NSMutableString stringWithCapacity:50];
                for (NSString *field in errors) {
                    [feedback appendFormat:@"%@ %@", field, [[errors objectForKey: field] lastObject]];
                }

                [[[UIAlertView alloc] initWithTitle:@"Sorry"
                                            message:feedback
                                           delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
            }
            else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        };
        request.onDidFailLoadWithError = ^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@"Can't connect"];
            NSLog(@"%@", [error description]);
        };
    }];
}

@end
