//
//  NoteCell.m
//  roommates
//
//  Created by andrew morton on 7/7/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "NoteCell.h"

@implementation NoteCell

@synthesize wrapper, photo, bodyText, userLabel;

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
