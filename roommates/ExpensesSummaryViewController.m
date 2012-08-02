//
//  RMListViewController.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ExpensesSummaryViewController.h"
#import "RMData.h"

@interface ExpensesSummaryItem : NSObject
@property(retain) RMUser *user;
@property(retain) NSDecimalNumber *amount;
+(id) itemWithUserId:(NSNumber*) userId forAmount:(NSDecimalNumber*) amount;
@end

@implementation ExpensesSummaryItem
@synthesize user, amount;
+(id) itemWithUserId:(NSNumber*) userId forAmount:(NSDecimalNumber*) amount
{
    ExpensesSummaryItem *item = [self new];
    item.user = [[RMUser users] objectForKey: userId];
    item.amount = amount;
    return item;
}
@end

@implementation ExpensesSummaryViewController {
    PullToRefreshView *pull;
    NSDecimalNumber *myBalance;
    NSMutableArray *top;
    NSMutableArray *bottom;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        myBalance = [NSDecimalNumber notANumber];
        top = [NSMutableArray array];
        bottom = [NSMutableArray array];
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

		self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reveal.png"] style:UIBarButtonItemStylePlain target:self.navigationController.parentViewController action:@selector(revealToggle:)];
	}
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMHouseholdSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemAdded" object:[RMTransaction class]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchOnNotification:) name:@"RMItemRemoved" object:[RMTransaction class]];

    [self fetchItems];
}

- (void)fetchOnNotification:(NSNotification*)note
{
    [self fetchItems];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    pull = nil;
    myBalance = nil;
    top = nil;
    bottom = nil;
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

    RKObjectManager *mgr = [RKObjectManager sharedManager];
    NSString *path = [NSString stringWithFormat:@"/api/households/%@/transactions/summary", current.householdId];
    [mgr.client get:path usingBlock:^(RKRequest *request) {
        request.onDidLoadResponse = ^(RKResponse *response) {
            NSError *parseError = nil;
            NSDictionary *body = [response parsedBody:&parseError];

            NSDecimalNumber *negativeOne = [NSDecimalNumber decimalNumberWithMantissa:1 exponent:0 isNegative:YES];
            NSMutableDictionary *balances = [NSMutableDictionary dictionaryWithDictionary:
                                             [body valueForKeyPath:@"balances"]];
            NSNumber *myId = [RMSession instance].userId;
            myBalance = [NSDecimalNumber decimalNumberWithString: [balances objectForKey:[myId stringValue]]];

            // Put us at the top of both.
            top = [NSMutableArray arrayWithObject:[ExpensesSummaryItem itemWithUserId:myId forAmount:myBalance]];
            bottom = [NSMutableArray arrayWithObject:[ExpensesSummaryItem itemWithUserId:myId forAmount:myBalance]];

            NSString *keyPath = (myBalance > 0) ? @"current.owed" : @"current.owes";
            NSDictionary *totals = [body valueForKeyPath:keyPath];
            for (NSString *key in totals) {
                NSNumber *userId = @([key integerValue]);
                NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[totals objectForKey:key]];
                [top addObject:[ExpensesSummaryItem itemWithUserId:userId forAmount:amount]];
            }

            for (NSString *key in balances) {
                NSNumber *userId = @([key integerValue]);
                // Skip the current user since we put ourselves at the top already.
                if (![userId isEqualToNumber:myId]) {
                    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[balances objectForKey:key]];
                    [bottom addObject:[ExpensesSummaryItem itemWithUserId:userId forAmount:amount]];
                }
            }

            [self.tableView reloadData];
            [pull finishedLoading];
            [TestFlight passCheckpoint:@"Viewed expense summary"];
        };
        request.onDidFailLoadWithError = ^(NSError *error) {
            [pull finishedLoading];
            [SVProgressHUD showErrorWithStatus:@"Can't connect"];
            NSLog(@"%@", [error description]);
        };
    }];
}

- (IBAction)testIt:(id)sender {
    [RMTransaction fetchForHousehold:[RMHousehold current].householdId
                          withParams:nil onSuccess:^(NSArray *objects) {
        NSLog(@"%@", objects);
    } onFailure:^(NSError *error) {
        NSLog(@"%@", error);
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
            return top.count;
        case 1:
            return bottom.count;
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (![myBalance isEqualToNumber:[NSDecimalNumber notANumber]]) {
        if (section == 0) {
            if ([myBalance floatValue] > 0) {
                return @"You are owed";
            }
            else if ([myBalance floatValue] < 0) {
                return @"You owe";
            }
            return @"You are paid up";
        }
        if (section == 1) {
            return @"Household Summary";
        }
    }
    return @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // TODO: this whole thing is a giant hack that needs to be cleaned up.
    // I just want to get it showing the right stuff.
    NSString *action;
    NSString *message = @"";
    NSNumberFormatter * f = [NSNumberFormatter new];
    f.numberStyle = NSNumberFormatterCurrencyStyle;
    f.negativeFormat = f.positiveFormat;
    UIColor *ourRed = [UIColor colorWithRed:0.882 green:0.000 blue:0.000 alpha:1.000];
    UIColor *ourGreen = [UIColor colorWithRed:0.349 green:0.812 blue:0.125 alpha:1.000];
    UIColor *color = [UIColor colorWithRed:0.216 green:0.325 blue:0.525 alpha:1.000];

    ExpensesSummaryItem *item;
    NSString *cellIdentifier = @"Cell";
    switch (indexPath.section) {
        case 0:
            item = [top objectAtIndex:indexPath.row];
            cellIdentifier = (indexPath.row == 0) ? @"MyBalance" : @"Cell";
            break;
        case 1:
            item = [bottom objectAtIndex:indexPath.row];
            break;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    NSDecimalNumber *amount = item.amount;

    // Configure the cell...
    switch (indexPath.section) {
        case 0:
            if (indexPath.row == 0) {
                color = myBalance.floatValue < 0 ? ourRed : ourGreen;
                cell.textLabel.text = [f stringFromNumber:amount];
                cell.textLabel.textColor = color;
            }
            else {
                if (myBalance.floatValue > 0) {
                    action = @"owed";
                    color = ourGreen;
                }
                else {
                    action = @"owes";
                    color = ourRed;
                }
                cell.textLabel.text = [NSString stringWithFormat:(action == @"owes") ? @"to %@:" : @"by %@", item.user.displayName];
            }
            break;

        case 1:
            if (indexPath.row == 0) {
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
                cell.textLabel.text = message;
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:17];
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
                cell.textLabel.text = [NSString stringWithFormat:message, item.user.displayName];
            }
            break;
    }

    cell.detailTextLabel.text = [f stringFromNumber:amount];
    cell.detailTextLabel.textColor = color;

    return cell;
}

@end
