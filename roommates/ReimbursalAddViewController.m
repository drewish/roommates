//
//  ReimbursalAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/12/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ReimbursalAddViewController.h"
#import "RMData.h"
#import "UserViewController.h"

@interface ReimbursalAddViewController ()

@end

@implementation ReimbursalAddViewController {
    NSArray *users;
}
@synthesize amountText;
@synthesize fromText;
@synthesize toText;
@synthesize picker;

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

    users = [[[RMHousehold current] users] allObjects];
}

- (void)viewDidUnload
{
    [self setAmountText:nil];
    [self setFromText:nil];
    [self setToText:nil];
    [self setPicker:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return users.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[users objectAtIndex:row] displayName];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"to"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.onSelect = ^(RMUser *user) {
            toText.text = user.displayName;  
        };
    }
    else if ([segue.identifier isEqualToString:@"from"]) {
        UserViewController *vc = segue.destinationViewController;
        vc.onSelect = ^(RMUser *user) {
            fromText.text = user.displayName;  
        };        
    }
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
