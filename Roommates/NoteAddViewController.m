//
//  NoteAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIActionSheet+MKBlockAdditions.h"
#import "NoteAddViewController.h"
#import "RMData.h"

@implementation NoteAddViewController {
    RMNote *note;
    UIGestureRecognizer *tapper;
}

@synthesize bodyText;

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        note = [RMNote new];
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    bodyText.text = note.body;
    [bodyText becomeFirstResponder];

    self.navigationItem.rightBarButtonItem.enabled = [self isValid];

    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = FALSE;
    [self.view addGestureRecognizer:tapper];
}

- (void)viewDidUnload {
    [self.view removeGestureRecognizer:tapper];
    tapper = nil;

    [self setBodyText:nil];
    [super viewDidUnload];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)textViewDidChange:(UITextView *)textView
{
    [self setBody:textView.text];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *)body
{
    return note.body;
}
- (void)setBody:(NSString *) val
{
    note.body = val;
    self.navigationItem.rightBarButtonItem.enabled = [self isValid];
}

- (UIImage *)photo
{
    return note.photo;
}
- (void)setPhoto:(UIImage *) photo
{
    note.photo = photo;

    NSIndexPath *photoIndexPath = [NSIndexPath indexPathForRow:1 inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:photoIndexPath];
    cell.imageView.image = photo;
    [cell layoutSubviews];
}

- (BOOL)isValid
{
    return note.body.length > 0;
}

- (IBAction)done:(id)sender {
    [SVProgressHUD showWithStatus:@"Posting"];
    [note postOnSuccess:^(id obj){
        NSLog(@"posted ...%@", obj);
        [SVProgressHUD showSuccessWithStatus:@""];
        [TestFlight passCheckpoint:@"Create note"];
        [self dismissModalViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

- (IBAction)cancel:(id)sender {
    [self dismissModalViewControllerAnimated:YES];
}

- (IBAction)attachPhoto:(id)sender {
    [UIActionSheet photoPickerWithTitle:@"" showInView:self.view presentVC:self onPhotoPicked:^(UIImage *chosenImage) {
        self.photo = chosenImage;
    } onCancel:^{
        //
    }];
}

#pragma mark Table Stuff

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0 && indexPath.row == 1) {
        [self attachPhoto:nil];
        return nil;
    }
    return indexPath;
}

@end
