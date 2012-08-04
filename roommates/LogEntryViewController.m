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

@implementation LogEntryViewController {
    NSDictionary *lableColors;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        lableColors = @{
            @"agreement":  [UIColor colorWithRed:0.616 green:0.149 blue:0.114 alpha:1.000],
            @"comment":    [UIColor colorWithRed:0.400 green:0.600 blue:1.000 alpha:1.000],
            @"expense":    [UIColor colorWithRed:0.765 green:0.196 blue:0.373 alpha:1.000],
            @"note":       [UIColor colorWithRed:0.478 green:0.263 blue:0.714 alpha:1.000],
            @"reimbursal": [UIColor colorWithRed:0.275 green:0.647 blue:0.275 alpha:1.000],
            @"shopping":   [UIColor colorWithRed:0.973 green:0.580 blue:0.024 alpha:1.000],
            @"todo":       [UIColor colorWithRed:0.973 green:0.580 blue:0.024 alpha:1.000],
        };
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

- (void)attachObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMHouseholdSelected" object:nil];
    // We want to refresh when anything is created.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemAdded" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemRemoved" object:nil];
}

#pragma mark - Table view delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogEntryCell";

    LogEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // TODO this should move into LogEntryCell.m?
    // Configure the cell...
    RMLogEntry *le = [self.items objectAtIndex:indexPath.row];

    cell.labelLabel.textColor = [lableColors objectForKey:le.label];
    cell.labelLabel.text = le.label;
    cell.actionLabel.text = [NSString stringWithFormat:@"%@ %@", le.action, [RMUser nameForId:le.actorId]];

    // Move the action over next to the label
    CGSize labelSize = [le.label sizeWithFont:cell.labelLabel.font];
    CGRect frame = cell.actionLabel.frame;
    frame.origin.x = cell.labelLabel.frame.origin.x + labelSize.width + 10;
    cell.actionLabel.frame = frame;
    
    cell.agoLabel.text = [le.updatedAt timeAgo];

    cell.summaryLabel.text = le.summary;

    return cell;
}

@end
