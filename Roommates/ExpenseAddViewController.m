//
//  ExpenseAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/23/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ExpenseAddViewController.h"
#import "UIActionSheet+MKBlockAdditions.h"
#import "RMData.h"

@interface ExpenseAddViewController ()

@end

@implementation ExpenseAddViewController {
    RMExpense *expense;
    NSArray *users;
    NSMutableSet *participants;
    NSNumberFormatter *formatter;
    UIGestureRecognizer *tapper;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        users = [[RMHousehold current] userSorted];
        expense = [RMExpense new];
        participants = [NSMutableSet set];
        formatter = [NSNumberFormatter new];
        [formatter setNumberStyle: NSNumberFormatterCurrencyStyle];
        [formatter setLenient:YES];
        [formatter setGeneratesDecimalNumbers:YES];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;

    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = FALSE;
    [self.view addGestureRecognizer:tapper];
}

- (void)viewDidUnload
{
    [self.view removeGestureRecognizer:tapper];
    tapper = nil;

    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1) {
        self.name = textField.text;
    }
    else if (textField.tag == 2) {
        // the amount gets updated on every change... not sure if that's best
        // but that's what it's doing now.
    }
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // For non-numberic fields just give them a pass.
    if ([textField keyboardType] != UIKeyboardTypeNumberPad) {
        return YES;
    }

    NSString *replaced = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSDecimalNumber *amount = (NSDecimalNumber*) [formatter numberFromString:replaced];
    if (amount == nil) {
        // Something screwed up the parsing. Probably an alpha character.
        return NO;
    }
    // If the field is empty (the inital case) the number should be shifted to
    // start in the right most decimal place.
    short powerOf10 = 0;
    if ([textField.text isEqualToString:@""]) {
        powerOf10 = -formatter.maximumFractionDigits;
    }
    // If the edit point is to the right of the decimal point we need to do
    // some shifting.
    else if (range.location + formatter.maximumFractionDigits >= textField.text.length) {
        // If there's a range of text selected, it'll delete part of the number
        // so shift it back to the right.
        if (range.length) {
            powerOf10 = -range.length;
        }
        // Otherwise they're adding this many characters so shift left.
        else {
            powerOf10 = [string length];
        }
    }
    amount = [amount decimalNumberByMultiplyingByPowerOf10:powerOf10];

    // Replace the value and then cancel this change.
    [self setAmount:amount];
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [[self.tableView viewWithTag:2] becomeFirstResponder];
    }
    return YES;
}

- (IBAction)done:(id)sender {
    [SVProgressHUD showWithStatus:@"Posting"];

    [expense postWithParticipants:[participants allObjects] onSuccess:^(id object) {
        NSLog(@"posted ...%@", object);
        [SVProgressHUD showSuccessWithStatus:@""];
        [TestFlight passCheckpoint:@"Create expense"];
        [self dismissModalViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (NSDecimalNumber *) amount
{
    return expense.amount;
}
- (void)setAmount:(NSDecimalNumber *) val
{
    expense.amount = val;

    UITextField *amountText = (UITextField*) [self.tableView viewWithTag:2];
    amountText.text = [formatter stringFromNumber:val];

    self.navigationItem.rightBarButtonItem.enabled = [self isValid];

    // Re-split the price.
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
}

- (NSString *)name
{
    return expense.name;
}
- (void)setName:(NSString *) val
{
    expense.name = val;
    self.navigationItem.rightBarButtonItem.enabled = [self isValid];
}

- (UIImage *)photo
{
    return expense.photo;
}
- (void)setPhoto:(UIImage *) photo
{
    expense.photo = photo;

    NSIndexPath *photoIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:photoIndexPath];
    cell.imageView.image = photo;
    [cell layoutSubviews];
}

- (BOOL)isValid
{
    return (expense.amount.floatValue > 0.0 && expense.name.length > 0);
}

- (RMUser*)userInCell:(NSIndexPath*) indexPath
{
    return [users objectAtIndex:indexPath.row];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return @"Participants";
    }
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 3;
        case 1:
            return [users count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            cellIdentifier = @"Title";
        }
        else if (indexPath.row == 1) {
            cellIdentifier = @"Amount";
        }
        else {
            cellIdentifier = @"AddPhoto";
        }
    }
    else if (indexPath.section == 1) {
        cellIdentifier = @"Participant";
    }

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Configure the cell...
    if ([cellIdentifier isEqualToString: @"Participant"]) {
        RMUser *user = [self userInCell:indexPath];
        cell.textLabel.text = [user isEqualToUser:[RMSession instance]] ? @"Me" : [user displayName];
        if ([participants containsObject:user.userId]) {
            NSDecimalNumber *denominator = [[NSDecimalNumber alloc] initWithInt:participants.count];
            NSDecimalNumber *share = [expense.amount decimalNumberByDividingBy:denominator];
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            cell.detailTextLabel.text = [formatter stringFromNumber:share];
            cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        }
        else {
            cell.accessoryType = UITableViewCellAccessoryNone;
            cell.textLabel.font = [UIFont systemFontOfSize:17];
            cell.detailTextLabel.text = @"";
        }
    }
    else if ([cellIdentifier isEqualToString: @"AddPhoto"]) {
        cell.imageView.image = expense.photo;
    }

    return cell;
}


#pragma mark - Table view delegate
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UITextField *textField;
        if (indexPath.row == 0) {
            textField = (UITextField*) [cell.contentView viewWithTag:1];
            [textField becomeFirstResponder];
        }
        else if (indexPath.row == 1) {
            textField = (UITextField*) [cell.contentView viewWithTag:2];
            [textField becomeFirstResponder];
        }
        else if (indexPath.row == 2) {
            [self attachPhoto:nil];
        }
        return nil;
    }

    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSNumber *userId = [[self userInCell:indexPath] userId];
        if ([participants containsObject:userId]) {
            [participants removeObject:userId];
        }
        else {
            [participants addObject:userId];
        }
        // Changing the participants will change each person's share so reload
        // the whole section.
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
}

#pragma mark Photo handling

- (IBAction)attachPhoto:(id)sender {
    [UIActionSheet photoPickerWithTitle:@"" showInView:self.view presentVC:self onPhotoPicked:^(UIImage *chosenImage) {
        self.photo = [UIActionSheet resize:chosenImage bounds:CGSizeMake(1200, 1200)];
    } onCancel:^{
        //
    }];
}

@end
