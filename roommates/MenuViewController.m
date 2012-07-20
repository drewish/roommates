//
//  MenuViewController.m
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "MenuViewController.h"
#import "RootViewController.h"
#import "RMData.h"

@interface MenuViewController ()

@end

@implementation MenuViewController
@synthesize actionSheet, rootController;

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
    self.clearsSelectionOnViewWillAppear = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(householdDidChange:) name:@"RMHouseholdSelected" object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    actionSheet = nil;
    rootController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)didMoveToParentViewController:(UIViewController *)parent
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion 
    // controller via self.navigationController.
	self.rootController = [self.parentViewController isKindOfClass:[RootViewController class]] ? (RootViewController *)self.parentViewController : nil;
}

- (void)householdDidChange:(NSNotification*)note
{
    // Make sure the new household shows up in the section title.
    [self.tableView reloadData];
    [self resetSelected];
}

- (void)resetSelected
{
    NSArray *items = [NSArray arrayWithObjects:@"LogEntryList", @"ExpenseSummary", 
                      @"ShoppingList", @"ToDoList", @"NoteList", nil];
    NSIndexPath *selected = [NSIndexPath indexPathForRow:[items indexOfObject:rootController.currentViewIdentifier] inSection:0];
    [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - UITableView Data Source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

#pragma mark - Table view delegate
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    RMHousehold *current;
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
                return [rootController showActivityFeed:nil];
            case 1:
                return [rootController showExpenses:nil];
            case 2:
                return [rootController showShoppingList:nil];
            case 3:
                return [rootController showTodos:nil];
            case 4:
                return [rootController showNotes:nil];
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

#pragma mark - Actions

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
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    actionSheet.tag = 1;
    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet_ didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (actionSheet_.tag == 1 && buttonIndex == 0) {
        [rootController signOut:nil];
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
    // Show them their data.
    [rootController revealToggle:self];
}

@end
