//
//  ChecklistItemCell.h
//  roommates
//
//  Created by andrew morton on 8/18/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChecklistItemCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *checkmarkButton;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end
