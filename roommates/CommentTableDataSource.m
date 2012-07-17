//
//  CommentTableDataSource.m
//  roommates
//
//  Created by andrew morton on 7/16/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "CommentTableDataSource.h"
#import "RMListViewController.h"

@implementation CommentTableDataSource

@synthesize commentableItem;

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return commentableItem.comments.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"CommentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    RMComment *comment = [commentableItem.comments objectAtIndex:indexPath.row];
    
    cell.textLabel.text = comment.body;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"—%@, %@", 
                                 [RMUser nameForId:comment.creatorId], 
                                 [RMListViewController asTimeAgo:comment.createdAt]];

    return cell;
 }

@end
