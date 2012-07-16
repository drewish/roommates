//
//  RMComment.h
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMObject.h"

@protocol RMCommentable <NSObject>
// Type of commentable object (required, [checklist_item, note, expense or reimbursal])
+ (NSString*)commentableType;
@end

@interface RMComment : NSObject <RMObject>

+ (void) post:(NSString*) body 
         toId:(NSNumber*) commentableId ofType:(NSString*) commentableType
    onSuccess:(RKObjectLoaderDidLoadObjectBlock) success
    onFailure:(RKObjectLoaderDidFailWithErrorBlock) failure;

@property (nonatomic, retain) NSNumber* commentId;
@property (nonatomic, retain) NSString* body;
@property (nonatomic, retain) NSDate* createdAt;
@property (nonatomic, retain) NSNumber* creatorId;

@end
