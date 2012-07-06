//
//  RMObject.h
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

@protocol RMObject <NSObject>
+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider;
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping;
@end
