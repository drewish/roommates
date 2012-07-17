//
//  NoteCell.h
//  roommates
//
//  Created by andrew morton on 7/7/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommentTableDataSource.h"

@interface NoteCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *agoLabel;
@property (weak, nonatomic) IBOutlet UIView *wrapper;
@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UITextView *bodyText;
@property (weak, nonatomic) IBOutlet UILabel *userLabel;
@property (weak, nonatomic) IBOutlet UITableView *comments;


@property (retain, nonatomic) CommentTableDataSource *commentData;
@end
