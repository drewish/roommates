//
//  ExpenseAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/23/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "ExpenseAddViewController.h"
#import "RMData.h"

@interface ExpenseAddViewController ()

@end

@implementation ExpenseAddViewController {
    RMExpense *expense;
    NSArray *users;
    NSMutableSet *participants;
    UIImage *photo;
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

    NSString *asText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([asText length] == 0) {
        self.amount = [NSDecimalNumber zero];
        return YES;
    }
    // We just want digits so cast the string to an integer then compare it
    // to itself. If they're same then we're good.
    NSInteger asInteger = [asText integerValue];
    NSNumber *asNumber = [NSNumber numberWithInteger:asInteger];
    if ([[asNumber stringValue] isEqualToString:asText]) {
        // Convert it to a decimal and shift it over by the fractional part.
        NSDecimalNumber *newAmount = [NSDecimalNumber decimalNumberWithDecimal:[asNumber decimalValue]];
        self.amount = [newAmount decimalNumberByMultiplyingByPowerOf10:-formatter.maximumFractionDigits];
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

- (IBAction)done:(id)sender {
    [SVProgressHUD showWithStatus:@"Posting"];

    [expense postWithImage:photo participants:[participants allObjects] onSuccess:^(id object) {
        NSLog(@"posted ...%@", object);
        [SVProgressHUD showSuccessWithStatus:@""];
        [TestFlight passCheckpoint:@"Create expense"];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

- (NSDecimalNumber *) amount
{
    return expense.amount;
}
- (void)setAmount:(NSDecimalNumber *) val
{
    expense.amount = val;

    UILabel *amountLabel = (UILabel*) [self.tableView viewWithTag:3];
    amountLabel.text = [formatter stringFromNumber:expense.amount];

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
    return photo;
}
- (void)setPhoto:(UIImage *) photo_
{
    // Store it in our instance variable then load the cell where it'll display.
    photo = photo_;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
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
        cell.imageView.image = photo;
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
        // the whole section then animate their row.
        [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:YES];
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:NO];
    }
}

#pragma mark Photo handling

- (IBAction)attachPhoto:(id)sender {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];

    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])) {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }

    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = @[(NSString*) kUTTypeImage];

    [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;

    [self presentModalViewController: cameraUI animated: YES];
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self.navigationController dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;

    // Handle a still image capture
    if (CFStringCompare((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];

        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }

        [self setPhoto:imageToSave];
    }

    [self.navigationController dismissModalViewControllerAnimated: YES];
}

@end
