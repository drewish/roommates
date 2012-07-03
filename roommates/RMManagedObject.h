//
//  RMManagedObject.h
//  roommates
//
//  Created by andrew morton on 7/2/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData.h>

@protocol RMManagedObject <NSObject>
+ (void) registerMappingsWith:(RKObjectMappingProvider*) provider inManagedObjectStore:(RKManagedObjectStore *)objectStore;
+ (RKManagedObjectMapping*) addMappingsTo:(RKManagedObjectMapping*) mapping;
@end
