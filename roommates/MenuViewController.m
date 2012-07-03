//
//  MenuViewController.m
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "MenuViewController.h"
#import "ZUUIRevealController.h"
#import "LogEntryViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

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

//-(NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
//{
//    return [NSArray arrayWithObjects:@"HOUSERHOLD", @"Settings", nil];
//}

//#pragma marl - UITableView Data Source
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//	return 4;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	static NSString *cellIdentifier = @"Cell";
//	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//	
//	if (nil == cell)
//	{
//		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
//	}
//	
//	if (indexPath.row == 0)
//	{
//		cell.textLabel.text = @"Front View Controller";
//	}
//	else if (indexPath.row == 1)
//	{
//		cell.textLabel.text = @"Map View Controller";
//	}
//	else if (indexPath.row == 2)
//	{
//		cell.textLabel.text = @"Enter Presentation Mode";
//	}
//	else if (indexPath.row == 3)
//	{
//		cell.textLabel.text = @"Resign Presentation Mode";
//	}
//	
//	return cell;
//}
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//	// Grab a handle to the reveal controller, as if you'd do with a navigtion 
//    // controller via self.navigationController.
//	ZUUIRevealController *revealController = [self.parentViewController isKindOfClass:[ZUUIRevealController class]] ? (ZUUIRevealController *)self.parentViewController : nil;
//    
//	// Here you'd implement some of your own logic... I simply take for granted 
//    // that the first row (=0) corresponds to the "FrontViewController".
//	if (indexPath.row == 0)
//	{
//		// Now let's see if we're not attempting to swap the current 
//        // frontViewController for a new instance of ITSELF, which'd be highly redundant.
//		if ([revealController.frontViewController isKindOfClass:[UINavigationController class]] && 
//            ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[LogEntryViewController class]])
//		{
//            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
//            UIViewController* frontViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"LogEntryList"];
//			[revealController setFrontViewController:frontViewController animated:NO];
//
////			FrontViewController *frontViewController = [[FrontViewController alloc] init];
////			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
////			[revealController setFrontViewController:navigationController animated:NO];
//			
//		}
//		// Seems the user attempts to 'switch' to exactly the same controller he came from!
//		else
//		{
//			[revealController revealToggle:self];
//		}
//	}
//	// ... and the second row (=1) corresponds to the "MapViewController".
//	else if (indexPath.row == 1)
//	{
////		// Now let's see if we're not attempting to swap the current frontViewController for a new instance of ITSELF, which'd be highly redundant.
////		if ([revealController.frontViewController isKindOfClass:[UINavigationController class]] && ![((UINavigationController *)revealController.frontViewController).topViewController isKindOfClass:[MapViewController class]])
////		{
////			MapViewController *mapViewController = [[MapViewController alloc] init];
////			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
////			[revealController setFrontViewController:navigationController animated:NO];
////		}
////		// Seems the user attempts to 'switch' to exactly the same controller he came from!
////		else
////		{
////			[revealController revealToggle:self];
////		}
//	}
//	else if (indexPath.row == 2)
//	{
//		[revealController hideFrontView];
//	}
//	else if (indexPath.row == 3)
//	{
//		[revealController showFrontViewCompletely:NO];
//	}
//}

//#pragma mark - Table view delegate
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    // Navigation logic may go here. Create and push another view controller.
//    /*
//     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
//     // ...
//     // Pass the selected object to the new view controller.
//     [self.navigationController pushViewController:detailViewController animated:YES];
//     */
//    
//}

@end
