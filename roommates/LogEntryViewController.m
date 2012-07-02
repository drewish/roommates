//
//  LogEntryViewController.m
//  roommates
//
//  Created by andrew morton on 6/29/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "LogEntryViewController.h"
#import "LogEntryCell.h"
#import "RMSession.h"
#import "RMHousehold.h"
#import "RMLogEntry.h"
@interface LogEntryViewController ()

@end

@implementation LogEntryViewController

@synthesize logEntries;


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

//    RKLogConfigureByName("RestKit", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelTrace);
//    RKLogConfigureByName("RestKit/CoreData", RKLogLevelTrace);

    NSString *url = @"http://roommates-staging.herokuapp.com";

    RKObjectManager* mgr = [RKObjectManager managerWithBaseURLString:url];
    mgr.serializationMIMEType = RKMIMETypeJSON;
    mgr.client.requestQueue.showsNetworkActivityIndicatorWhenBusy = YES;
    [mgr.client setValue:@"application/roommates.v1" forHTTPHeaderField:@"Accept"];

    // Setup our mappings.
    [RMUser registerMappingsWith:mgr.mappingProvider];
    [RMHousehold registerMappingsWith:mgr.mappingProvider];
    [RMLogEntry registerMappingsWith:mgr.mappingProvider];

    //TODO: these might be useful later when I'm uploading
    //    // Setup out class routes.
    //    [mgr.router routeClass:[RMUser class] toResourcePath:@"/api/users" forMethod:RKRequestMethodGET];
    //    [mgr.router routeClass:[RMHousehold class] toResourcePath:@"/api/households" forMethod:RKRequestMethodGET];


    [RMSession startSessionEmail:@"delany@gmail.com" Password:@"123456" OnSuccess:^(RMSession *session) {
        NSLog(@"Loaded User ID #%@ -> Name: %@, token: %@", session.userId, session.fullName, session.apiToken);
        // FIXME: hardcoding this for now
        NSNumber *theId = [NSNumber numberWithInt:1];

        [RMLogEntry getLogEntriesForHousehold:theId OnSuccess:^(NSArray *logEntries_) {
            logEntries = logEntries_;
            [self.tableView reloadData];
        } OnFailure:^(NSError *error) {
            NSLog(@"Couldn't fetch feeds: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];

        [RMHousehold getHouseholdsOnSuccess:^(NSArray *households) {
            NSLog(@"Households: %@", households);
            // TODO store this some place:....
        } OnFailure:^(NSError *error) {
            NSLog(@"Couldn't fetch households: %@", error);
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    } OnFailure:^(NSError *error) {
        NSLog(@"Encountered an error: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.logEntries count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LogEntry";
    LogEntryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    RMLogEntry *le = [self.logEntries objectAtIndex:indexPath.row];

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
    
    // TODO: should convert the user id into a user's display name.
    cell.actionLabel.text = [NSString stringWithFormat:@"%@ User# %@", le.action, le.actorId];

    // Move the action over next to the label
    CGSize labelSize = [le.label sizeWithFont:cell.labelLabel.font];
    CGRect frame = cell.actionLabel.frame;
    frame.origin.x = cell.labelLabel.frame.origin.x + labelSize.width + 10;
    cell.actionLabel.frame = frame;
    
    // TODO the API should be returning a timestamp that we can format as time ago...
    cell.agoLabel.text = [le.updatedAt stringValue];

    cell.summaryLabel.text = le.summary;
    // If this is a completed list item denote that using strike through text.
    if ([le.action isEqualToString:@"Completed by"]) {
        // TODO: iOS doesn't support strike through but we should be able to
        // just draw a line across. for now we'll just stick dashes in there.
        cell.summaryLabel.text = [NSString stringWithFormat:@"-%@-", [le.summary stringByReplacingOccurrencesOfString:@" " withString:@"-"]];
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
