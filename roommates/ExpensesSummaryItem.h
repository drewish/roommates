//
//  ExpensesSummaryItem.h
//  roommates
//
//  Created by andrew morton on 8/3/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RMUser;

@interface ExpensesSummaryItem : NSObject

+(id) itemWithUserId:(NSNumber*) userId forAmount:(NSDecimalNumber*) amount;

@property(retain) RMUser *user;
@property(retain) NSDecimalNumber *amount;

@end
