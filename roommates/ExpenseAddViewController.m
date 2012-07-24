//
//  ExpenseAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/23/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ExpenseAddViewController.h"
#import "RMData.h"

@interface ExpenseAddViewController ()

@end

@implementation ExpenseAddViewController {
    RMExpense *expense;
    NSArray *users;
    NSMutableIndexSet *participants;
    NSDecimalNumber *amount;
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
        participants = [NSMutableIndexSet indexSet];
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
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    tapper = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField.tag == 1) {
        expense.name = textField.text;
    }
    else if (textField.tag == 2) {
        // We'll want to re-split the price.
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // For non-numberic fields just give them a pass.
    if ([textField keyboardType] != UIKeyboardTypeNumberPad) {
        return YES;
    }

    UILabel *amountLabel = (UILabel*) [textField.superview viewWithTag:3];
    NSString *asText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([asText length] == 0) {
        expense.amount = [NSDecimalNumber zero];
        amountLabel.text = [formatter stringFromNumber:expense.amount];
        return YES;
    }
    // We just want digits so cast the string to an integer then compare it
    // to itself. If they're same then we're good.
    NSInteger asInteger = [asText integerValue];
    NSNumber *asNumber = [NSNumber numberWithInteger:asInteger];
    if ([[asNumber stringValue] isEqualToString:asText]) {
        // Convert it to a decimal and shift it over by the fractional part.
        NSDecimalNumber *newAmount = [NSDecimalNumber decimalNumberWithDecimal:[asNumber decimalValue]];
        expense.amount = [newAmount decimalNumberByMultiplyingByPowerOf10:-formatter.maximumFractionDigits];
        amountLabel.text = [formatter stringFromNumber:expense.amount];
        return YES;
    }
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField.tag == 1) {
        [[self.tableView viewWithTag:2] becomeFirstResponder];
    }
    return YES;
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
            return 2;
        case 1:
            return users.count;
        case 2:
            return 2;
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
        else {
            cellIdentifier = @"Amount";
        }
    }
    else if (indexPath.section == 1) {
        cellIdentifier = @"Participant";
    }
    else if (indexPath.section == 2) {
        cellIdentifier = @"Split";
    }

    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    // Configure the cell...
    if ([cellIdentifier isEqualToString: @"Participant"]) {
        cell.textLabel.text = [[users objectAtIndex:indexPath.row] displayName];
        if ([participants containsIndex:indexPath.row]) {
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
    else if ([cellIdentifier isEqualToString: @"Split"]) {
        //
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
        } else if (indexPath.row == 1) {
            textField = (UITextField*) [cell.contentView viewWithTag:2];
        }
        [textField becomeFirstResponder];
        return nil;
    }
    if (indexPath.section == 1) {
        return indexPath;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        if ([participants containsIndex:indexPath.row]) {
            [participants removeIndex:indexPath.row];
        }
        else {
            [participants addIndex:indexPath.row];
        }
        // Changing the participants will change each person's share so reload
        // the whole section then animate their row.
        [tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
}

@end
