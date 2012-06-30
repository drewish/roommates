//
//  LogEntryCell.m
//  roommates
//
//  Created by andrew morton on 6/29/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "LogEntryCell.h"

@implementation LogEntryCell

@synthesize descriptionLabel;
@synthesize labelLabel;
@synthesize actionLabel;
@synthesize agoLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
