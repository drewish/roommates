//
//  RMDataObject.h
//  roomates
//
//  Created by andrew morton on 6/28/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>

// This is acting like an abstract base class...

@interface RMDataObject : NSObject
+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider;
+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping;
@end
