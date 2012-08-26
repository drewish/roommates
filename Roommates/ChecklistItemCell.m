//
//  ChecklistItemCell.m
//  roommates
//
//  Created by andrew morton on 8/18/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "ChecklistItemCell.h"

@implementation ChecklistItemCell
@synthesize checkmarkButton;
@synthesize textLabel;
@synthesize commentLabel;

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
