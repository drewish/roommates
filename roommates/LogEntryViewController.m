//
//  LogEntryViewController.m
//  roommates
//
//  Created by andrew morton on 6/29/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "LogEntryViewController.h"
#import "LogEntryCell.h"
#import "RMData.h"

@interface LogEntryViewController ()

@end

@implementation LogEntryViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (Class)dataClass
{
    return [RMLogEntry class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogEntryCell";
    LogEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // TODO this should move into LogEntryCell.m?
    // Configure the cell...
    RMLogEntry *le = [self.items objectAtIndex:indexPath.row];

    UIColor *lableColor;
    if ([le.label isEqualToString:@"agreement"]) {
        lableColor = [UIColor colorWithRed:0.616 green:0.149 blue:0.114 alpha:1.000];
    }
    else if ([le.label isEqualToString:@"comment"]) {
        lableColor = [UIColor colorWithRed:0.400 green:0.600 blue:1.000 alpha:1.000];
    }
    else if ([le.label isEqualToString:@"expense"]) {
        lableColor = [UIColor colorWithRed:0.765 green:0.196 blue:0.373 alpha:1.000];
    }
    else if ([le.label isEqualToString:@"note"]) {
        lableColor = [UIColor colorWithRed:0.478 green:0.263 blue:0.714 alpha:1.000];
    }
    else if ([le.label isEqualToString:@"reimbursal"]) {
        lableColor = [UIColor colorWithRed:0.275 green:0.647 blue:0.275 alpha:1.000];
    }
    else if ([le.label isEqualToString:@"shopping"] || [le.label isEqualToString:@"todo"]) {
        lableColor = [UIColor colorWithRed:0.973 green:0.580 blue:0.024 alpha:1.000];
    }
    cell.labelLabel.textColor = lableColor;
    cell.labelLabel.text = le.label;
    cell.actionLabel.text = [NSString stringWithFormat:@"%@ %@", le.action, [RMUser nameForId:le.actorId]];

    // Move the action over next to the label
    CGSize labelSize = [le.label sizeWithFont:cell.labelLabel.font];
    CGRect frame = cell.actionLabel.frame;
    frame.origin.x = cell.labelLabel.frame.origin.x + labelSize.width + 10;
    cell.actionLabel.frame = frame;
    
    cell.agoLabel.text = [le.updatedAt timeAgo];

    cell.summaryLabel.text = le.summary;
    // If this is a completed list item denote that using strike through text.
//    if ([le.action isEqualToString:@"Completed by"]) {
//        // TODO: iOS doesn't support strike through but we should be able to
//        // just draw a line across. for now we'll just stick dashes in there.
//        cell.summaryLabel.text = [NSString stringWithFormat:@"-%@-", [le.summary stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
//    }

    return cell;
}

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
