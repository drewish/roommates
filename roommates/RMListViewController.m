//
//  RMListViewController.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMListViewController.h"
#import "RMObject.h"

#import "RMLogEntry.h"

@interface RMListViewController ()

@end

@implementation RMListViewController

@synthesize items, dataClass = _dataClass;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)]) {
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];

		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reveal", @"Reveal") style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
	}
    
    // Make sure we've got household info before trying to load items.
    NSArray *households = [RMHousehold households];
    assert(households.count > 0);

    [self fetchItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    items = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)fetchItems {
    RMHousehold *current = [RMHousehold current];
    if (current != nil) {
        [_dataClass fetchForHousehold:current.householdId OnSuccess:^(NSArray *items_) {
            self.items = items_;
            [self.tableView reloadData];
        } OnFailure:^(NSError *error) {
            NSLog(@"Couldn't fetch items: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    }
}

// This was taken from https://github.com/kevinlawler/NSDate-TimeAgo
// might be worth just including that code.
- (NSString*)asTimeAgo:(NSDate*)date
{
    NSDate *now = [NSDate date];
    double deltaSeconds = fabs([date timeIntervalSinceDate:now]);
    double deltaMinutes = deltaSeconds / 60.0f;

    if (deltaSeconds < 5) {
        return @"Just now";
    } else if (deltaSeconds < 60) {
        return [NSString stringWithFormat:@"%d seconds ago", (int)deltaSeconds];
    } else if (deltaSeconds < 120) {
        return @"A minute ago";
    } else if (deltaMinutes < 60) {
        return [NSString stringWithFormat:@"%d minutes ago", (int)deltaMinutes];
    } else if (deltaMinutes < 120) {
        return @"An hour ago";
    } else if (deltaMinutes < (24 * 60)) {
        return [NSString stringWithFormat:@"%d hours ago", (int)floor(deltaMinutes/60)];
    } else if (deltaMinutes < (24 * 60 * 2)) {
        return @"Yesterday";
    } else if (deltaMinutes < (24 * 60 * 7)) {
        return [NSString stringWithFormat:@"%d days ago", (int)floor(deltaMinutes/(60 * 24))];
    } else if (deltaMinutes < (24 * 60 * 14)) {
        return @"Last week";
    } else if (deltaMinutes < (24 * 60 * 31)) {
        return [NSString stringWithFormat:@"%d weeks ago", (int)floor(deltaMinutes/(60 * 24 * 7))];
    } else if (deltaMinutes < (24 * 60 * 61)) {
        return @"Last month";
    } else if (deltaMinutes < (24 * 60 * 365.25)) {
        return [NSString stringWithFormat:@"%d months ago", (int)floor(deltaMinutes/(60 * 24 * 30))];
    } else if (deltaMinutes < (24 * 60 * 731)) {
        return @"Last year";
    }

    return [NSString stringWithFormat:@"%d years ago", (int)floor(deltaMinutes/(60 * 24 * 365))];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    
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