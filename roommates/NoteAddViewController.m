//
//  NoteAddViewController.m
//  roommates
//
//  Created by andrew morton on 7/11/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <QuartzCore/QuartzCore.h>
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
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"purty_wood.png"];
    self.tableView.backgroundColor = [UIColor colorWithPatternImage:image];

    bodyText.text = note.body;
    [bodyText becomeFirstResponder];

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
    note.body = textView.text;
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
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

#pragma mark Photo handling

- (IBAction)attachPhoto:(id)sender {
    UIImagePickerController *cameraUI = [[UIImagePickerController alloc] init];

    if (([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])) {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeCamera;
    }
    else {
        cameraUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    }

    // Displays a control that allows the user to choose picture or
    // movie capture, if both are available:
    cameraUI.mediaTypes = @[(NSString*) kUTTypeImage];

    [UIImagePickerController availableMediaTypesForSourceType: UIImagePickerControllerSourceTypeCamera];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    cameraUI.allowsEditing = NO;
    cameraUI.delegate = self;

    [self presentModalViewController: cameraUI animated: YES];
}

// For responding to the user tapping Cancel.
- (void) imagePickerControllerDidCancel: (UIImagePickerController *) picker {
    [self.navigationController dismissModalViewControllerAnimated: YES];
}

// For responding to the user accepting a newly-captured picture or movie
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    UIImage *originalImage, *editedImage, *imageToSave;

    // Handle a still image capture
    if (CFStringCompare((__bridge CFStringRef) mediaType, kUTTypeImage, 0) == kCFCompareEqualTo) {
        editedImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];

        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }

        self.photo = imageToSave;
    }

    [self.navigationController dismissModalViewControllerAnimated: YES];
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
