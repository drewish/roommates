//
//  RMListViewController.m
//  roommates
//
//  Created by andrew morton on 7/6/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ExpensesSummaryViewController.h"
#import "ExpensesSummaryItem.h"
#import "RMData.h"

@implementation ExpensesSummaryViewController {
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

- (Class)dataClass
{
    return [RMTransaction class];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    myBalance = nil;
    top = nil;
    bottom = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
            NSMutableDictionary *balances = [NSMutableDictionary dictionaryWithDictionary:
                                             [body valueForKeyPath:@"balances"]];
            NSNumber *myId = [RMSession instance].userId;
            id value = [balances objectForKey:[myId stringValue]];
            myBalance = [NSDecimalNumber decimalNumberWithString: [value isKindOfClass:[NSString class]] ? value : [value stringValue]];

            // Put us at the top of both.
            top = [NSMutableArray arrayWithObject:[ExpensesSummaryItem itemWithUserId:myId forAmount:myBalance]];
            bottom = [NSMutableArray arrayWithObject:[ExpensesSummaryItem itemWithUserId:myId forAmount:myBalance]];

            NSString *keyPath = ([myBalance floatValue] > 0) ? @"current.owed" : @"current.owes";
            NSDictionary *totals = [body valueForKeyPath:keyPath];
            if (![totals isKindOfClass:[NSNull class]]) {
                for (NSString *key in totals) {
                    NSNumber *userId = @([key integerValue]);
                    value = [totals objectForKey:key];
                    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[value isKindOfClass:[NSString class]] ? value : [value stringValue]];
                    [top addObject:[ExpensesSummaryItem itemWithUserId:userId forAmount:amount]];
                }
            }

            for (NSString *key in balances) {
                NSNumber *userId = @([key integerValue]);
                // Skip the current user since we put ourselves at the top already.
                if (![userId isEqualToNumber:myId]) {
                    value = [balances objectForKey:key];
                    NSDecimalNumber *amount = [NSDecimalNumber decimalNumberWithString:[value isKindOfClass:[NSString class]] ? value : [value stringValue]];
                    [bottom addObject:[ExpensesSummaryItem itemWithUserId:userId forAmount:amount]];
                }
            }
            
            [self.tableView reloadData];
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:TRUE];
            [self.pull finishedLoading];
            [TestFlight passCheckpoint:@"Viewed expense summary"];
        };
        request.onDidFailLoadWithError = ^(NSError *error) {
            [self.pull finishedLoading];
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
                return @"You Are Owed";
            }
            else if ([myBalance floatValue] < 0) {
                return @"You Owe";
            }
            return @"You Are Paid Up!";
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
                cell.textLabel.text = [NSString stringWithFormat:(action == @"owes") ? @"to %@:" : @"by %@", [RMUser nameForId:item.userId]];
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
                cell.textLabel.text = [NSString stringWithFormat:message, [RMUser nameForId:item.userId]];
            }
            break;
    }
    cell.detailTextLabel.text = [f stringFromNumber:amount];
    cell.detailTextLabel.textColor = color;

    return cell;
}

@end
