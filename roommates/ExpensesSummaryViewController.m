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
    NSDictionary *balance;
    NSDictionary *owed;
    NSDictionary *owes;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        balance = [NSDictionary dictionary];
        owed = [NSDictionary dictionary];
        owes = [NSDictionary dictionary];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    pull = [[PullToRefreshView alloc] initWithScrollView:(UIScrollView *) self.tableView];
    [pull setDelegate:self];
    [self.tableView addSubview:pull];

	if ([self.navigationController.parentViewController respondsToSelector:@selector(revealGesture:)] && [self.navigationController.parentViewController respondsToSelector:@selector(revealToggle:)]) {
		UIPanGestureRecognizer *navigationBarPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self.navigationController.parentViewController action:@selector(revealGesture:)];
		[self.navigationController.navigationBar addGestureRecognizer:navigationBarPanGestureRecognizer];

		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reveal", @"Reveal") style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refeshIt:) name:@"RMHouseholdSelected" object:nil];

    [self fetchItems];
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
    balance = nil;
    owed = nil;
    owes = nil;
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

- (NSDictionary*)parseExpenseSection:(NSString*)keyPath inDictionary:(NSDictionary*)body
{
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    NSNumberFormatter * f = [NSNumberFormatter new];
    f.numberStyle = NSNumberFormatterDecimalStyle;

    if ([[body valueForKeyPath:keyPath] isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *d = [body valueForKeyPath:keyPath];
        for (NSString *key in d) {
            id val = [d objectForKey:key];
            NSNumber *userId = [f numberFromString:key];
            NSNumber *amount = ([val isKindOfClass:[NSNumber class]]) ? val : [f numberFromString:val];
            if ([[RMUser users] objectForKey:userId]) {
                [ret setObject:amount forKey:userId];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:ret];
}

- (void)fetchItems {
    RMHousehold *current = [RMHousehold current];
    if ([RMSession instance] == nil || current == nil) {
        return;
    }

    RKObjectManager *mgr = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"/api/households/%@/transactions/summary", current.householdId];
    [mgr.client get:path usingBlock:^(RKRequest *request) {
        request.onDidLoadResponse = ^(RKResponse *response) {
            NSError *parseError = nil;
            NSDictionary *body = [response parsedBody:&parseError];
            NSLog(@"%@", body);
            balance = [self parseExpenseSection:@"balances" inDictionary:body];
            owed = [self parseExpenseSection:@"current.owed" inDictionary:body];
            owes = [self parseExpenseSection:@"current.owes" inDictionary:body];

            [self.tableView reloadData];
            [pull finishedLoading];
        };
        request.onDidFailLoadWithError = ^(NSError *error) {
            [pull finishedLoading];
            [SVProgressHUD showErrorWithStatus:@"Can't connect"];
            NSLog(@"%@", [error description]);
        };
    }];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return balance.count;
        case 1:
            return owed.count + owes.count;
        default:
            return 0;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return balance.count ? @"Expense Summary" : nil;
        case 1:
            return owed.count + owes.count ? @"Household Summary" : nil;
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: this whole thing is a giant hack that needs to be cleaned up.
    // I just want to get it showing the right stuff.
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSArray *balanceUsers = [balance allKeys];
    NSArray *owedUsers = [owed allKeys];
    NSArray *owesUsers = [owes allKeys];
    NSNumber *amount;
    NSString *action;
    NSNumber *userId;
    BOOL isSessionUser = FALSE;
    NSString *message = @"";
    UIColor *ourRed = [UIColor colorWithRed:0.882 green:0.000 blue:0.000 alpha:1.000];
    UIColor *ourGreen = [UIColor colorWithRed:0.349 green:0.812 blue:0.125 alpha:1.000];
    UIColor *color = [UIColor colorWithRed:0.216 green:0.325 blue:0.525 alpha:1.000];

    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            userId = [balanceUsers objectAtIndex:indexPath.row];
            amount = [balance objectForKey:userId];
            isSessionUser = [[RMSession instance].userId isEqualToNumber:userId];

            if (isSessionUser) {
                if ([amount floatValue] > 0) {
                    message = @"You are owed";
                    color = ourGreen;
                }
                else if ([amount floatValue] < 0) {
                    message = @"You owe";
                    color = ourRed;
                }
                else {
                    message = @"You are paid up";
                }
            }
            else {
                if ([amount floatValue] > 0) {
                    message = @"%@ is owed";
                    color = ourGreen;
                }
                else if ([amount floatValue] < 0) {
                    message = @"%@ owes";
                    color = ourRed;                }
                else {
                    message = @"%@ is paid up";
                }
                message = [NSString stringWithFormat:message, [RMUser nameForId: userId]];
            }
            break;

        case 1:
            if (indexPath.row < owedUsers.count) {
                userId = [owedUsers objectAtIndex:indexPath.row];
                action = @"owed";
                color = ourGreen;
                amount = [owed objectForKey:userId];
            }
            else {
                userId = [owesUsers objectAtIndex:indexPath.row];
                action = @"owes";
                color = ourRed;
                // Since we're flipping the color don't format negative number.
                amount = [owes objectForKey:userId];
            }

            isSessionUser = [[RMSession instance].userId isEqualToNumber:userId];
            if (isSessionUser) {
                // TODO: Not sure this branch will fire. Might need to pull our
                // total from the balances.
                message = (action == @"owes") ? @"You owe:" : @"You are owed:";
            }
            else {
                message = [NSString stringWithFormat:(action == @"owes") ? @"You owe %@:" : @"%@ owes you:", [RMUser nameForId: userId]];
            }
            break;
    }

    if (isSessionUser) {
        cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
        cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    cell.textLabel.text = message;
    cell.textLabel.textColor = color;
    NSNumberFormatter * f = [NSNumberFormatter new];
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    f.negativeFormat = f.positiveFormat;
    cell.detailTextLabel.text = [f stringFromNumber:amount];
    cell.detailTextLabel.textColor = color;

    return cell;
}

@end
