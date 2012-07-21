//
//  TodoListViewController.m
//  roommates
//
//  Created by andrew morton on 7/17/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ChecklistItemListViewController.h"
#import "ChecklistItemDetailViewController.h"

@interface ChecklistItemListViewController ()

@end

@implementation ChecklistItemListViewController

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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"Detail" isEqualToString:segue.identifier]) {
        ChecklistItemDetailViewController *vc = segue.destinationViewController;
        UITableViewCell *cell = (UITableViewCell*) sender;
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        vc.item = [self.items objectAtIndex:path.row];
        vc.navigationItem.title = vc.item.kind;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    RMChecklistItem *item = [self.items objectAtIndex:indexPath.row];
    cell.textLabel.text = item.title;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d comments", item.comments.count];

    return cell;
}

#pragma

@end
