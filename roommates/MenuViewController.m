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
@synthesize actionSheet, revealController;

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
    actionSheet = nil;
    revealController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion 
    // controller via self.navigationController.
	self.revealController = [self.parentViewController isKindOfClass:[ZUUIRevealController class]] ? (ZUUIRevealController *)self.parentViewController : nil;
}

#pragma mark - UITableView Data Source
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

#pragma mark - Actions

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

- (IBAction)switchHousehold:(id)sender {
    NSLog(@"switch households");
    actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                              delegate:nil
                                     cancelButtonTitle:nil
                                destructiveButtonTitle:nil
                                     otherButtonTitles:nil];
    actionSheet.tag = 0;
    //    [actionSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

    CGRect frame = CGRectMake(0, 0, self.view.bounds.size.width, 44);
    UIToolbar *pickerToolbar = [[UIToolbar alloc] initWithFrame:frame];
    //    pickerToolbar.barStyle = UIBarStyleBlackOpaque;
    NSMutableArray *barItems = [[NSMutableArray alloc] init];

    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [barItems addObject:flexSpace];

    UILabel *toolBarItemlabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 180, 30)];
    toolBarItemlabel.textAlignment = UITextAlignmentCenter;
    toolBarItemlabel.textColor = [UIColor whiteColor];
    toolBarItemlabel.font = [UIFont boldSystemFontOfSize:16];
    toolBarItemlabel.backgroundColor = [UIColor clearColor];
    toolBarItemlabel.text = @"Pick a household";
    UIBarButtonItem *labelButton = [[UIBarButtonItem alloc] initWithCustomView:toolBarItemlabel];
    [barItems addObject:labelButton];

    [barItems addObject:flexSpace];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(householdPickerDone:)];
    [barItems addObject:doneButton];

    pickerToolbar.items = barItems;
    [actionSheet addSubview:pickerToolbar];


    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 40, 0, 0)];
    pickerView.showsSelectionIndicator = YES;
    pickerView.dataSource = self;
    pickerView.delegate = self;
    [pickerView selectRow:[[RMHousehold households] indexOfObject:[RMHousehold current]] inComponent:0 animated:NO];
    [actionSheet addSubview:pickerView];

    // The order of these calls seems backwards but it's the correct way.
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
    [actionSheet setBounds:CGRectMake(0, 0, 320, 485)];
}

- (IBAction)signOut:(id)sender {
    actionSheet = [[UIActionSheet alloc] initWithTitle:@"Signing out remove your roommat.es account information from your iPhone."
                                              delegate:self
                                     cancelButtonTitle:@"Cancel"
                                destructiveButtonTitle:@"Sign out"
                                     otherButtonTitles:nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    actionSheet.tag = 1;
    [actionSheet showInView:[[UIApplication sharedApplication] keyWindow]];
}

-(void)actionSheet:(UIActionSheet *)actionSheet_ didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet_.tag == 1 && buttonIndex == 0) {
        NSLog(@"Signing out…");
        [RMSession endSession];

        // TODO: figure out how to do this with a transition. It's too abrupt now.
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        LoginViewController* loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
        UIApplication.sharedApplication.keyWindow.rootViewController = loginViewController;
    }
    actionSheet = nil;
}

#pragma mark - Household picker
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [[RMHousehold households] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[RMHousehold households] objectAtIndex:row] displayName];
}

// TODO it's not idea having the picking split between here...
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    RMHousehold *selected = [[RMHousehold households] objectAtIndex:row];
    NSLog(@"Picked %@", selected);
    RMHousehold.current = selected;
}
// ...and here... it'd probably be best to move the household picking into its 
// own view so we don't have to set the household until they click done.
- (IBAction)householdPickerDone:(id)sender {
    [actionSheet dismissWithClickedButtonIndex:0 animated:YES];
    // Use the new household in the section title.
    [self.tableView reloadData];
}

@end
