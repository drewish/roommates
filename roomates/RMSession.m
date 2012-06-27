//
//  RMSession.m
//  roomates
//
//  Created by andrew morton on 6/27/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RMSession.h"

@implementation RMSession
@synthesize avatar, apiToken;

+ (RKObjectMapping*) addMappingsTo:(RKObjectMapping*) mapping
{
    [super addMappingsTo:mapping];
    [mapping mapKeyPath:@"avatar" toAttribute:@"avatar"];
    [mapping mapKeyPath:@"api_token" toAttribute:@"apiToken"];
    return mapping;
}
@end
