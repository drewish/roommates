//
//  MenuViewController.m
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "MenuViewController.h"
#import "LoginViewController.h"
#import "LogEntryViewController.h"
#import "NoteListViewController.h"
#import "RMHousehold.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize revealController;

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

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion 
    // controller via self.navigationController.
	self.revealController =[self.parentViewController isKindOfClass:[ZUUIRevealController class]] ? (ZUUIRevealController *)self.parentViewController : nil;
}

#pragma marl - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark - Table view delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{   RMHousehold *current;
    switch (section) {
        case 0:
            current = RMHousehold.current;
            return current == nil ? @"No household" : current.displayName;
        case 1:
            return @"Settings";
        default:
            return @"";
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                return [self showActivityFeed:nil];
            case 1:
                return [self showExpenses:nil];
            case 2:
                return [self showShoppingList:nil];
            case 3:
                return [self showTodos:nil];
            case 4:
                return [self showNotes:nil];
        }
    }
    else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                return [self switchHousehold:nil];
            case 1:
                return [self signOut:nil];
        }
    }
}

// Little helper function to pick the right viewcontroller from the story board
// and get it setup inside a navigation controller.
- (void)switchToView:(Class)aClass withStoryBoardIdentifier:(NSString*)identifer
{
    if ([revealController.frontViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = ((UINavigationController *)revealController.frontViewController);
        // Now let's see if we're not attempting to swap the current 
        // frontViewController for a new instance of ITSELF, which'd be highly redundant.
        if (![nav.topViewController isKindOfClass:aClass]) {
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UIViewController* frontViewController = [mainStoryboard instantiateViewControllerWithIdentifier:identifer];
			UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:frontViewController];
			[revealController setFrontViewController:navigationController animated:NO];
            return;
        }
    }
    // Seem like they want to stay where they are.
    [revealController revealToggle:self];
}

- (IBAction)showActivityFeed:(id)sender {
    NSLog(@"Activity Feed");
    [self switchToView:[LogEntryViewController class] withStoryBoardIdentifier:@"LogEntryList"];
}

- (IBAction)showExpenses:(id)sender {
    NSLog(@"Expenses");
}

- (IBAction)showShoppingList:(id)sender {
    NSLog(@"Shopping List");
}

- (IBAction)showTodos:(id)sender {
    NSLog(@"To-Do's");
}

- (IBAction)showNotes:(id)sender {
    NSLog(@"Notes");
    [self switchToView:[NoteListViewController class] withStoryBoardIdentifier:@"NoteList"];
}

- (IBAction)signOut:(id)sender {
    NSLog(@"sign out..");
    [RMSession endSession];

    // TODO: figure out how to do this with a transition. It's too abrupt now.
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginViewController* loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    UIApplication.sharedApplication.keyWindow.rootViewController = loginViewController;
}

- (IBAction)switchHousehold:(id)sender {
    NSLog(@"switch households");
}

@end
