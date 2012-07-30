//
//  ChecklistItemDetailViewController.m
//  roommates
//
//  Created by andrew morton on 7/18/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ChecklistItemDetailViewController.h"
#import "CommentAddViewController.h"

@interface ChecklistItemDetailViewController ()

@end

@implementation ChecklistItemDetailViewController

@synthesize deleteButton;
@synthesize item = item_;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemRemoved" object:nil];
}

- (void)viewDidUnload
{
    [self setDeleteButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.item = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)fetchOnNotification:(NSNotification*)note
{
//    [RMChecklistItem getItem:item.checklistItemId OnSuccess:^(NSArray *objects) {
//        NSLog(@"worked");
//    } onFailure:^(NSError *error) {
//        NSLog(@"failed");
//    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"addComment" isEqualToString:segue.identifier]) {
        assert(self.item != nil);

        // Pass that along to the view controller so the comment can reference 
        // the right entity.
        CommentAddViewController *vc = segue.destinationViewController;
        vc.commentableType = [[self.item class] commentableType];
        vc.commentableId = self.item.checklistItemId;
    }
}

-(void)setItem:(RMChecklistItem *)item
{
    item_ = item;
//    [self.tableView reloadData];
    deleteButton.hidden = ![item isDeletable];
}
-(RMChecklistItem *)item
{
    return item_;
}

- (IBAction)deleteItem:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"This will delete the item from the server."
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                               destructiveButtonTitle:@"Delete"
                                                    otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self.view];
}

- (IBAction)addComment:(id)sender {
    [self performSegueWithIdentifier:@"addComment" sender:sender];
}

-(void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        [self.item deleteItemOnSuccess:^(NSArray *objects) {
            [self.navigationController popViewControllerAnimated:YES];
        } onFailure:RMSession.objectLoadErrorBlock];
    }
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return (section == 0) ? 1 : self.item.comments.count + 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row > 0 && indexPath.row < self.item.comments.count) {
        RMComment *comment = [self.item.comments objectAtIndex:indexPath.row];
        CGSize commentSize = CGSizeMake(280, FLT_MAX);
        commentSize = [comment.body sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:commentSize];
        // A single line should be 18 so any more than that should be added
        // to the height.
        if (commentSize.height > 18) {
            return 44 + commentSize.height - 18;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier: @"ItemCell"];
        cell.textLabel.text = self.item.title;
        cell.accessoryType = [self.item.completed boolValue] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    }
    else if (indexPath.row < [self.item.comments count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        RMComment *comment = [self.item.comments objectAtIndex:indexPath.row];
        cell.textLabel.text = comment.body;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"—%@, %@",
                                     [RMUser nameForId:comment.creatorId],
                                     [comment.createdAt timeAgo]];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddComment"];
    }
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
