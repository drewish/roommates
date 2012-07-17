//
//  CommentTableDataSource.h
//  roommates
//
//  Created by andrew morton on 7/16/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMData.h"

@interface CommentTableDataSource : NSObject <UITableViewDataSource>

@property id<RMCommentable> commentableItem;

@end
