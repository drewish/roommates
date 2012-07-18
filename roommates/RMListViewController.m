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

@implementation RMListViewController {
    PullToRefreshView *pull;
}

@synthesize items;

// This was taken from https://github.com/kevinlawler/NSDate-TimeAgo
// might be worth just including that code.
+ (NSString*)asTimeAgo:(NSDate*)date
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(householdDidChange:) name:@"RMHouseholdSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemWasAdded:) name:@"RMItemAdded" object:[self dataClass]];
    // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(watchIt:) name:@"RMListFetched" object:[self dataClass]];

    [self fetchItems];
}

- (void)householdDidChange:(NSNotification*)note
{
    [self fetchItems];
}

- (void)itemWasAdded:(NSNotification*)note
{
    // TODO: i set this up thinking it'd be a way to get the correct animation
    // of coming back from the add note view. but i think it's wrong. it'll 
    // probably also get fired for adding a comment but we need different 
    // behavior for that. new comments should refresh the cell i guess.
    [self fetchItems];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    pull = nil;
    items = nil;
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
        self.items = items_;
        [self.tableView reloadData];
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
        [pull finishedLoading];
    } onFailure:^(NSError *error) {
        [pull finishedLoading];
        NSLog(@"Couldn't fetch items: %@", error);
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
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
