//
//  NoteListViewController.m
//  roommates
//
//  Created by andrew morton on 7/5/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "NoteListViewController.h"
#import "NoteCell.h"
#import "CommentAddViewController.h"
#import "RMData.h"


@interface NoteListViewController ()

@end

@implementation NoteListViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        super.dataClass = [RMNote class];
    }
    return self;    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"addComment" isEqualToString:segue.identifier]) {
        // Figure out what cell the button they clicked was in by going up the
        // view hierarchy...
        UITableViewCell *cell = (UITableViewCell*) [[sender superview] superview];
        // ...then get its index and load the item to find its id.
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        RMNote *item = [self.items objectAtIndex:path.row];

        // Pass that along to the view controller so the comment can reference 
        // the right entity.
        CommentAddViewController *vc = segue.destinationViewController;
        vc.commentableType = [RMNote commentableType];
        vc.commentableId = item.noteId;
    }
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NoteCell";
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    RMNote *item = [self.items objectAtIndex:indexPath.row];
    cell.agoLabel.text = [self asTimeAgo:item.createdAt];
    cell.bodyText.text = item.body;
    cell.userLabel.text = [NSString stringWithFormat:@"— %@", [RMUser nameForId:item.creatorId]];

    // This stuff was lifted from: http://nachbaur.com/blog/fun-shadow-effects-using-custom-calayer-shadowpaths
    cell.bodyText.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.bodyText.layer.shadowOpacity = 0.7f;
    cell.bodyText.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    cell.bodyText.layer.shadowRadius = 3.0f;
    cell.bodyText.layer.masksToBounds = NO;
    // Did some tweaking here... They were using a UIImage which seems like it
    // computes it's bounds differently. I think it might have been because I
    // zeroed out the UITextView's content insets.
    CGRect f = cell.bodyText.frame;
    CGSize size = CGSizeMake(f.size.width - 2 * f.origin.x, f.size.height);
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    cell.bodyText.layer.shadowPath = path.CGPath;

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
