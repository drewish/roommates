//
//  ExpensesSummaryItem.m
//  roommates
//
//  Created by andrew morton on 8/3/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ExpensesSummaryItem.h"
#import "RMData.h"

@implementation ExpensesSummaryItem

+(id) itemWithUserId:(NSNumber*) userId forAmount:(NSDecimalNumber*) amount
{
    ExpensesSummaryItem *item = [self new];
    item.user = [[RMUser users] objectForKey: userId];
    item.amount = amount;
    return item;
}

@synthesize user, amount;

@end
