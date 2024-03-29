//
//  RMListViewController.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import "UIActionSheet+MKBlockAdditions.h"
#import "RMListViewController.h"
#import "RMData.h"
#import "RMPhotoable.h"
#import "RootViewController.h"

@implementation RMListViewController

@synthesize items = _items, pull;

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
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

-(NSDictionary *)fetchParams
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    pull.delegate = self;
    [self.tableView addSubview:pull];

	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)]) {
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];

		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal.png"] style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
	}

    UIBarButtonItem *sideSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    sideSpace.width = 20;
    UIBarButtonItem *middleSpacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.toolbarItems = @[
        sideSpace,
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-expense.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addTransaction:)],
        middleSpacer,
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-camera.png"] style:UIBarButtonItemStylePlain target:self action:@selector(takePhoto:)],
        middleSpacer,
        [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"toolbar-note.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addNote:)],
        sideSpace,
    ];
    
    [self attachObservers];

    [self fetchItems];
}

- (void)attachObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMHouseholdSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemAdded" object:[self dataClass]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemChanged" object:[self dataClass]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemRemoved" object:[self dataClass]];
}

- (void)fetchOnNotification:(NSNotification*)notification
{
    [self fetchItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    pull = nil;
    self.items = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)pullToRefreshViewShouldRefresh:(PullToRefreshView *)view;
{
    [self fetchItems];
}

- (void)fetchItems {
    RMHousehold *current = [RMHousehold current];
    if ([RMSession instance] == nil || current == nil) {
        return;
    }

    [[self dataClass] fetchForHousehold:current.householdId 
                             withParams:self.fetchParams
                              onSuccess:^(NSArray *items_) {
        self.items = [NSMutableArray arrayWithArray:items_];
        [self.tableView reloadData];
        [pull finishedLoading];
        [TestFlight passCheckpoint:[NSString stringWithFormat:@"Viewed %@ list", self.dataClass]];
    } onFailure:^(NSError *error) {
        [pull finishedLoading];
        NSLog(@"Couldn't fetch items: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Can't connect"];
    }];
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
    cell.textLabel.text = [[self.items objectAtIndex:indexPath.row] description];

    return cell;
}

- (IBAction)addTransaction:(id)sender {
    [UIActionSheet actionSheetWithTitle:@"What would you like to create?"
                                message:@"Hello World"
                                buttons:@[@"Expense", @"Reimbursement"]
                             showInView:sender
                              onDismiss:^(int buttonIndex)
    {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:buttonIndex == 0 ? @"ExpenseAdd" : @"ReimbursalAdd"];
        [self presentViewController:vc animated:TRUE completion:^{}];
    } onCancel:^() {
        //
    }];
}

- (IBAction)addNote:(id)sender {
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"NoteAdd"];
    [self presentViewController:vc animated:TRUE completion:^{}];
}

- (IBAction)takePhoto:(id)sender {
    [UIActionSheet photoPickerWithTitle:@"" showInView:sender presentVC:self onPhotoPicked:^(UIImage *chosenImage) {
        [UIActionSheet actionSheetWithTitle:@"What should we attach the photo to?" message:@""
                                    buttons:@[@"New Note", @"New Expense"]
                                 showInView:sender
                                  onDismiss:^(int buttonIndex)
        {
            UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
            UINavigationController* vc = [mainStoryboard instantiateViewControllerWithIdentifier:buttonIndex == 0 ? @"NoteAdd" : @"ExpenseAdd"];

            [self presentViewController:vc animated:TRUE completion:^{
                if ([vc.visibleViewController conformsToProtocol:@protocol(RMPhotoable)]) {
                    [(id<RMPhotoable>) vc.visibleViewController setPhoto:[UIActionSheet resize:chosenImage bounds:CGSizeMake(1200, 1200)]];
                }
            }];
        } onCancel:^{
            //
        }];
    } onCancel:^{
        //
    }];
}

@end
