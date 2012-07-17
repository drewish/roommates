//
//  NoteListViewController.m
//  roommates
//
//  Created by andrew morton on 7/5/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "NoteListViewController.h"
#import "NoteCell.h"
#import "CommentAddViewController.h"
#import "CommentTableDataSource.h"
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

// Little action to tie both buttons to the same segue.
- (IBAction)addComment:(id)sender {
    [self performSegueWithIdentifier:@"addComment" sender:sender];
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

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMNote *item = [self.items objectAtIndex:indexPath.row];
    
    // Rough value for timestamp, note wrapper, add comment button. 
    CGFloat height = 370;

    // Add some space for the photo.
    if (item.photo.length > 0) {
//        height += 100;
    }

    // Add in the comment table height per row.
    if (item.comments.count > 0) {
        height += 44 * item.comments.count + 12;
    }

    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"NoteCell";
    NoteCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    RMNote *item = [self.items objectAtIndex:indexPath.row];

    cell.agoLabel.text = [RMListViewController asTimeAgo:item.createdAt];
    cell.bodyText.text = item.body;
    cell.userLabel.text = [NSString stringWithFormat:@"—%@", [RMUser nameForId:item.creatorId]];

    cell.photo.hidden = item.photo == nil;
    if (item.photo == nil) {
        cell.wrapper.backgroundColor = [UIColor colorWithRed:1.000 green:0.973 blue:0.757 alpha:1.000];

        // Let the text take up the whole screen.
        cell.bodyText.frame = cell.wrapper.bounds;
    }
    else {
        cell.wrapper.backgroundColor = [UIColor whiteColor];

        // Figure out how much space our text takes and scale the image to 
        // share the space.
        CGSize wrapperSize = cell.wrapper.bounds.size;
        CGSize bodySize = [item.body sizeWithFont:cell.bodyText.font constrainedToSize:wrapperSize];
        cell.bodyText.frame = CGRectMake(0, cell.userLabel.frame.origin.y - bodySize.height - 16, wrapperSize.width, bodySize.height + 16);
        
        cell.bodyText.backgroundColor = [UIColor colorWithWhite:0.95 alpha:0.4];

        // Here we use the new provided setImageWithURL: method to load the web image
        [cell.photo setImageWithURL:[NSURL URLWithString:item.photo]
                   placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
        cell.wrapper.backgroundColor = [UIColor whiteColor];
    }

    // This stuff was lifted from: http://nachbaur.com/blog/fun-shadow-effects-using-custom-calayer-shadowpaths
    cell.wrapper.layer.shadowColor = [UIColor blackColor].CGColor;
    cell.wrapper.layer.shadowOpacity = 0.7f;
    cell.wrapper.layer.shadowOffset = CGSizeMake(0.0f, 5.0f);
    cell.wrapper.layer.shadowRadius = 3.0f;
    cell.wrapper.layer.masksToBounds = NO;
    // Did some tweaking here... They were using a UIImage which seems like it
    // computes it's bounds differently. I think it might have been because I
    // zeroed out the UITextView's content insets.
    CGRect f = cell.wrapper.frame;
    CGSize size = f.size; //CGSizeMake(258, f.size.height);
    CGFloat curlFactor = 15.0f;
    CGFloat shadowDepth = 5.0f;
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, 0.0f)];
    [path addLineToPoint:CGPointMake(size.width, size.height + shadowDepth)];
    [path addCurveToPoint:CGPointMake(0.0f, size.height + shadowDepth)
            controlPoint1:CGPointMake(size.width - curlFactor, size.height + shadowDepth - curlFactor)
            controlPoint2:CGPointMake(curlFactor, size.height + shadowDepth - curlFactor)];
    cell.wrapper.layer.shadowPath = path.CGPath;

    cell.comments.hidden = (item.comments.count < 1);
    if (cell.comments.hidden) {
        
    }
    else {
        cell.commentData = [[CommentTableDataSource alloc] init];
        cell.commentData.commentableItem = item;
        cell.comments.dataSource = cell.commentData;
    //    CGRect cb = cell.comments.bounds;
    //    cb.size.height = item.comments.count * 44;
    //    cell.comments.bounds = cb;
    }

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
