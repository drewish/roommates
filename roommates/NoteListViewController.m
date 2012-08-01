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
#import "RMData.h"


@interface NoteListViewController ()

@end

@implementation NoteListViewController

-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
    }
    return self;    
}

- (Class)dataClass
{
   return [RMNote class];
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

// Little action to tie both buttons to the same segue.
- (IBAction)addComment:(id)sender {
    [self performSegueWithIdentifier:@"addComment" sender:sender];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([@"addComment" isEqualToString:segue.identifier]) {
        UITableViewCell *cell;
        if ([sender isKindOfClass:[UIButton class]]) {
            // Figure out what cell the button they clicked was in by going up the
            // view hierarchy...
            cell = (UITableViewCell*) [[sender superview] superview];
        }
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            cell = (UITableViewCell*) sender;
        }
        // ...then get its index and load the item to find its id.
        NSIndexPath *path = [self.tableView indexPathForCell:cell];
        RMNote *item = [self.items objectAtIndex:path.section];
        assert(item != nil);

        // Pass that along to the view controller so the comment can reference 
        // the right entity.
        CommentAddViewController *vc = segue.destinationViewController;
        vc.commentableType = [[item class] commentableType];
        vc.commentableId = item.noteId;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.items.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    RMNote *item = [self.items objectAtIndex:section];
    return [item.createdAt timeAgo];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<RMCommentable> item = [self.items objectAtIndex:section];
    return item.comments.count + 2;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMNote *item = [self.items objectAtIndex:indexPath.section];

    if (indexPath.row == 0) {
        return 280;
    }
    if (indexPath.row <= item.comments.count) {
        RMComment *comment = [item.comments objectAtIndex:indexPath.row - 1];
        CGSize commentSize = CGSizeMake(280, FLT_MAX);
        commentSize = [comment.body sizeWithFont:[UIFont systemFontOfSize:14] constrainedToSize:commentSize];
        // A single line should be 18 so any more than that should be added
        // to the height.
        if (commentSize.height > 18) {
            return 44 + commentSize.height - 18;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RMNote *item = [self.items objectAtIndex:indexPath.section];
    NoteCell *cell;
    
    if (indexPath.row == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"NoteCell"];

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
            [cell.photo setImageWithURL:item.photoURL
                       placeholderImage:[UIImage imageNamed:@"placeholder.png"]];
            cell.wrapper.backgroundColor = [UIColor whiteColor];
        }

        // Avoid setting this up ever time a cell comes into view.
        if (cell.wrapper.layer.shadowPath == nil) {
            // This stuff was lifted from: http://nachbaur.com/blog/fun-shadow-effects-using-custom-calayer-shadowpaths
            cell.wrapper.layer.shadowColor = [UIColor blackColor].CGColor;
            cell.wrapper.layer.shadowOpacity = 0.3f;
            cell.wrapper.layer.shadowOffset = CGSizeMake(0.0f, 2.0f);
            cell.wrapper.layer.shadowRadius = 2.0f;
            cell.wrapper.layer.masksToBounds = NO;
            CGRect f = cell.wrapper.frame;
            CGSize size = f.size;
            CGFloat curlFactor = 2.0f;
            CGFloat shadowDepth = 4.0f;
            UIBezierPath *path = [UIBezierPath bezierPath];
            [path moveToPoint:CGPointMake(0.0f, 0.0f)];
            [path addLineToPoint:CGPointMake(size.width, 0.0f)];
            [path addLineToPoint:CGPointMake(size.width, size.height)];
            [path addCurveToPoint:CGPointMake(0.0f, size.height)
                    controlPoint1:CGPointMake(size.width, size.height + shadowDepth + curlFactor)
                    controlPoint2:CGPointMake(0, size.height + shadowDepth + curlFactor)];
            cell.wrapper.layer.shadowPath = path.CGPath;
        }
    }
    else if (indexPath.row <= [item.comments count]) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"Comment"];
        RMComment *comment = [item.comments objectAtIndex:indexPath.row - 1];

        cell.textLabel.text = comment.body;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"—%@, %@",
                                     [RMUser nameForId:comment.creatorId],
                                     [comment.createdAt timeAgo]];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"AddComment"];
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
