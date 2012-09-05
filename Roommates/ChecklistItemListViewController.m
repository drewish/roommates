//
//  TodoListViewController.m
//  roommates
//
//  Created by andrew morton on 7/17/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ChecklistItemListViewController.h"
#import "ChecklistItemDetailViewController.h"
#import "ChecklistItemCell.h"

@interface ChecklistItemListViewController ()

@end

@implementation ChecklistItemListViewController {
    UIGestureRecognizer *tapper;
}

@synthesize kind;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(Class)dataClass
{
    return [RMChecklistItem class];
}

-(NSDictionary *)fetchParams
{
    return [NSDictionary dictionaryWithObject:self.kind forKey:@"kind"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
//    self.navigationItem.rightBarButtonItem = self.editButtonItem;

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
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"Detail" isEqualToString:segue.identifier]) {
        ChecklistItemDetailViewController *vc = segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell*) sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        vc.item = [self.items objectAtIndex:path.row];
        // FIXME: This it a little nasty
        vc.navigationItem.title = self.navigationItem.title;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChecklistItemCell *cell;

    // Configure the cell...
    RMChecklistItem *item = [self.items objectAtIndex:indexPath.row];
    if (item.title == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Add"];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"View"];
        cell.textLabel.text = item.title;
        cell.commentLabel.text = (item.comments.count > 0) ? [NSString stringWithFormat:@"%i", item.comments.count] : @"";
        cell.checkmarkButton.imageView.image = [UIImage imageNamed:([item.completed boolValue] ? @"checkmark_on.png" : @"checkmark_off.png")];
    }

    return cell;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    // TODO: are we sure this will always be the first item?
    RMChecklistItem *newItem = [self.items objectAtIndex:0];

    if (textField.text.length < 1 || newItem == nil) {
        return FALSE;
    }

    newItem.title = textField.text;

    [textField resignFirstResponder];

    [SVProgressHUD showWithStatus:@"Posting"];
    [newItem postOnSuccess:^(id object) {
        textField.text = @"";
        self.navigationItem.rightBarButtonItem.enabled = YES;
        [SVProgressHUD showSuccessWithStatus:@""];
        [self fetchItems];
        [TestFlight passCheckpoint:@"Create checklist_item"];
    } onFailure:[RMSession objectValidationErrorBlock]];
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMChecklistItem *item = [self.items objectAtIndex:indexPath.row];
    NSNumber *permission = [[item abilities] objectForKey:@"destroy"];
    return [permission boolValue];
}


-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        RMChecklistItem *item = [self.items objectAtIndex:indexPath.row];
        [item deleteItemOnSuccess:^(NSArray *objects) {
            [self fetchItems];
        } onFailure:^(NSError *error) {
            //code
        }];
    }
}
#pragma

- (IBAction)add:(id)sender {
    RMChecklistItem *newOne = [RMChecklistItem new];
    newOne.kind = kind;

    self.navigationItem.rightBarButtonItem.enabled = NO;
    [self.items insertObject:newOne atIndex:0];

    NSIndexPath *path = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[path] withRowAnimation:YES];
    [[[self.tableView cellForRowAtIndexPath:path] viewWithTag:1] becomeFirstResponder];
}

- (IBAction)toggle:(id)sender {
    UITableViewCell *cell;
    if ([sender isKindOfClass:[UIButton class]]) {
        // Figure out what cell the button they clicked was in by going up the
        // view hierarchy...
        cell = (UITableViewCell*) [[sender superview] superview];
    }
    // ...then get its index and load the item to find its id.
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    RMChecklistItem *item = [self.items objectAtIndex:path.section];
    assert(item != nil);
    [SVProgressHUD showWithStatus:@"Toggling"];
    [item toggleOnSuccess:^(id object) {
        [SVProgressHUD dismiss];
    } onFailure:^(NSError *error) {
        [SVProgressHUD showErrorWithStatus:@""];
    }];
}

@end
