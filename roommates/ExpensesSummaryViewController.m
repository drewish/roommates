//
//  RMListViewController.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ExpensesSummaryViewController.h"
#import "RMObject.h"

#import "RMLogEntry.h"

@interface ExpensesSummaryViewController ()

@end

@implementation ExpensesSummaryViewController {
    PullToRefreshView *pull;
}
//@synthesize items;

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

    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];

	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)]) {
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];

		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reveal", @"Reveal") style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
	}
    
    // Make sure we've got household info before trying to load items.
    NSArray *households = [RMHousehold households];
    assert(households.count > 0);

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refeshIt:) name:@"RMItemAdded" object:_dataClass];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refeshIt:) name:@"RMHouseholdSelected" object:nil];
//
//    [self fetchItems];
}

- (void)refeshIt:(NSNotification*)note
{
    [self fetchItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    pull = nil;
//    items = nil;
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
//    RMHousehold *current = [RMHousehold current];
//    if (current != nil) {
//        [_dataClass fetchForHousehold:current.householdId OnSuccess:^(NSArray *items_) {
//            self.items = items_;
//            [self.tableView reloadData];
            [pull finishedLoading];
//        } OnFailure:^(NSError *error) {
//            [pull finishedLoading];
//            NSLog(@"Couldn't fetch items: %@", error);
//            [[[UIAlertView alloc] initWithTitle:@"Error"
//                                        message:[error localizedDescription]
//                                       delegate:nil
//                              cancelButtonTitle:@"OK"
//                              otherButtonTitles:nil] show];
//        }];
//    }
}


#pragma mark - Table view data source

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    return [self.items count];
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    // Configure the cell...
//    
//    return cell;
//}

@end
