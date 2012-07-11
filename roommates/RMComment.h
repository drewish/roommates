//
//  RMComment.h
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMObject.h"

@interface RMComment : NSObject <RMObject>
@property (nonatomic, retain) NSNumber* commentId;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSDate* createdAt;
@property (nonatomic, retain) NSNumber* creatorId;

@end
