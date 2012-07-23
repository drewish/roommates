//
//  ReimbursalAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/12/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ReimbursalAddViewController.h"
#import "RMData.h"
#import "UserViewController.h"

@interface ReimbursalAddViewController ()

@end

@implementation ReimbursalAddViewController {
    RMUser *fromUser_;
    RMUser *toUser_;
    NSNumberFormatter *formatter;
}
@synthesize amountText;
@synthesize toUserCell;
@synthesize fromUserCell;
@synthesize amount;
@synthesize toUser = toUser_, fromUser = fromUser_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterDecimalStyle;
        formatter.minimum = [NSNumber numberWithInt:0];
        formatter.generatesDecimalNumbers = YES;
        formatter.maximumFractionDigits = 2;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fromUser = [[RMSession instance] user];
    self.toUser = nil;
    amountText.keyboardType = UIKeyboardTypeDecimalPad;
    [amountText becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setAmountText:nil];
    [self setToUserCell:nil];
    [self setFromUserCell:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    toUser_ = nil;
    fromUser_ = nil;
    amount = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"to"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.user = [self toUser];
        vc.navigationItem.title = @"To";
        vc.onSelect = ^(RMUser *user) {
            self.toUser = user;
            [self.navigationController popViewControllerAnimated:YES];
        };
    }
    else if ([segue.identifier isEqualToString:@"from"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.user = [self fromUser];
        vc.navigationItem.title = @"From";
        vc.onSelect = ^(RMUser *user) {
            self.fromUser = user;
            [self.navigationController popViewControllerAnimated:YES];
        };        
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSDecimalNumber *newNumber = (NSDecimalNumber*) [formatter numberFromString:newText];
    NSLog(@"Changing to %@ %@", newText, newNumber);
    if (newNumber != nil) {
        amount = newNumber;
        self.navigationItem.rightBarButtonItem.enabled = [self isValid];
        return YES;
    }
    return NO;
}

-(void)setToUser:(RMUser *)user
{
    toUser_ = user;
    toUserCell.detailTextLabel.text = user.displayName;
    self.navigationItem.rightBarButtonItem.enabled = [self isValid];
}

-(void)setFromUser:(RMUser *)user
{
    fromUser_ = user;
    fromUserCell.detailTextLabel.text = user == nil ? @"Pick one" : user.displayName;
    self.navigationItem.rightBarButtonItem.enabled = [self isValid];
}

-(BOOL)isValid
{
    return (amount.floatValue > 0.0 && toUser_ && fromUser_ && ![toUser_ isEqualToUser:fromUser_]);
}

- (IBAction)done:(id)sender {
    RKObjectManager *mgr = [RKObjectManager sharedManager];
    RMReimbursal *item = [RMReimbursal new];

//    [mgr postObject:item usingBlock:^(RKObjectLoader *loader) {
//        RKParams* params = [RKParams params];
//        [params setValue:body forParam:@"note[body]"];
//        RKParamsAttachment *attachment = [params setData:UIImagePNGRepresentation(image) MIMEType:@"image/png" forParam:@"note[photo]"];
//        attachment.fileName = @"image.png";
//        loader.params = params;
//
//        loader.onDidFailLoadWithError = ^(NSError *error) {
//            NSLog(@"%@", error);
//            failure(error);
//        };
//        loader.onDidLoadObject = ^(id whatLoaded) {
//            NSLog(@"%@", whatLoaded);
//            success(whatLoaded);
//            [[NSNotificationCenter defaultCenter]
//             postNotificationName:@"RMItemAdded" object:[self class]];
//        };
//        loader.onDidLoadResponse = ^(RKResponse *response) {
//            NSLog(@"%@", response);
//            // Check for validation errors.
//            if (response.statusCode == 422) {
//                NSError *parseError = nil;
//                NSDictionary *errors = [[response parsedBody:&parseError] objectForKey:@"errors"];
//                failure([NSError errorWithDomain:@"roomat.es" code:100 userInfo:errors]);
//            }
//        };
//    }];
}

@end
