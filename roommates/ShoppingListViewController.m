//
//  ShoppingListViewController.m
//  roommates
//
//  Created by andrew morton on 7/18/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ShoppingListViewController.h"

@interface ShoppingListViewController ()

@end

@implementation ShoppingListViewController

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
    return [NSDictionary dictionaryWithObject:@"shopping" forKey:@"kind"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    // Configure the cell...
    cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] title];

    return cell;
}

#pragma

@end
