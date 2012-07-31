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
    NSDecimalNumber *amount_;
    NSNumberFormatter *formatter;
}
@synthesize amountText;
@synthesize amountLabel;
@synthesize toUserCell;
@synthesize fromUserCell;
@synthesize amount = amount_, toUser = toUser_, fromUser = fromUser_;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        formatter = [NSNumberFormatter new];
        formatter.numberStyle = NSNumberFormatterCurrencyStyle;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    self.fromUser = [[RMSession instance] user];
    self.toUser = nil;
    [amountText becomeFirstResponder];
}

- (void)viewDidUnload
{
    [self setAmountText:nil];
    [self setToUserCell:nil];
    [self setFromUserCell:nil];
    [self setAmountLabel:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    toUser_ = nil;
    fromUser_ = nil;
    amount_ = nil;
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
    NSString *asText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([asText length] == 0) {
        [self setAmount:[NSDecimalNumber zero]];
        return YES;
    }
    // We just want digits so cast the string to an integer then compare it
    // to itself. If they're same then we're good.
    NSInteger asInteger = [asText integerValue];
    NSNumber *asNumber = [NSNumber numberWithInteger:asInteger];
    if ([[asNumber stringValue] isEqualToString:asText]) {
        // Convert it to a decimal and shift it over by the fractional part.
        NSDecimalNumber *newAmount = [NSDecimalNumber decimalNumberWithDecimal:[asNumber decimalValue]];
        [self setAmount:[newAmount decimalNumberByMultiplyingByPowerOf10:-formatter.maximumFractionDigits]];
        return YES;
    }
    return NO;
}

-(void)setAmount:(NSDecimalNumber *)amount
{
    amount_ = amount;
    amountLabel.text = [formatter stringFromNumber:amount];
    self.navigationItem.rightBarButtonItem.enabled = [self isValid];
}

-(void)setToUser:(RMUser *)user
{
    toUser_ = user;
    toUserCell.detailTextLabel.text = user == nil ? @"Pick one" : user.displayName;
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
    return (amount_.floatValue > 0.0 && toUser_ && fromUser_ && ![toUser_ isEqualToUser:fromUser_]);
}

- (IBAction)done:(id)sender {
    RMReimbursal *item = [RMReimbursal new];
    item.amount = amount_;
    item.toUserId = toUser_.userId;
    item.fromUserId = fromUser_.userId;
    
    [SVProgressHUD showWithStatus:@"Posting"];
    [item postOnSuccess:^(id object) {
        [SVProgressHUD showSuccessWithStatus:@""];
        [TestFlight passCheckpoint:@"Create reimbursal"];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 0) {
        [amountText becomeFirstResponder];
        return nil;
    }
    return indexPath;
}

@end
