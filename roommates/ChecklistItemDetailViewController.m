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

    // We want to catch additions of comments and changes to ourself.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemChanged" object:nil];
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
    [RMChecklistItem fetchItem:self.item.checklistItemId OnSuccess:^(RMChecklistItem *item) {
        [self setItem:item];
    } onFailure:^(NSError *error) {}];
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
    [self.tableView reloadData];
    deleteButton.hidden = ![item isDeletable];
}
-(RMChecklistItem *)item
{
    return item_;
}

- (IBAction)addComment:(id)sender {
    [self performSegueWithIdentifier:@"addComment" sender:sender];
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
    // Section 0 is the checklist item, section 1 is the comments and add
    // comment link. The comments can have variable heights so we need to size
    // them up.
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
        cell.imageView.image = [UIImage imageNamed:([self.item.completed boolValue] ? @"checkmark_on.png" : @"checkmark_off.png")];
        cell.textLabel.text = self.item.title;
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

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0 && indexPath.section == 0) {
        [self.item toggleOnSuccess:^(id object) {
            //
        } onFailure:^(NSError *error) {
            [SVProgressHUD showErrorWithStatus:@""];
        }];
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:NO];
    }
}

@end
