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
    UIGestureRecognizer *tapper;
}

@synthesize doneButton;
@synthesize bodyText;
@synthesize photoImage;

-(void)viewDidLoad {
    [bodyText.layer setBorderColor: [[UIColor grayColor] CGColor]];
    [bodyText.layer setBorderWidth: 1.0];
    [bodyText.layer setCornerRadius:10.0];
    [bodyText.layer setMasksToBounds:YES];
    [bodyText.layer setShadowRadius:5.0];

    [bodyText becomeFirstResponder];

    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = FALSE;
    [self.view addGestureRecognizer:tapper];
}

- (void)viewDidUnload {
    [self.view removeGestureRecognizer:tapper];
    tapper = nil;

    [self setBodyText:nil];
    [self setDoneButton:nil];
    [self setPhotoImage:nil];
    [super viewDidUnload];
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

-(void)textViewDidChange:(UITextView *)textView
{
    doneButton.enabled = textView.hasText;
}

- (IBAction)done:(id)sender {
    [SVProgressHUD showWithStatus:@"Posting"];

    [RMNote postNote:bodyText.text image:photoImage.image onSuccess:^(id obj){
        NSLog(@"posted ...%@", obj);
        [SVProgressHUD showSuccessWithStatus:@""];
        [TestFlight passCheckpoint:@"Create note"];
        [self.navigationController popViewControllerAnimated:YES];
    } onFailure:[RMSession objectValidationErrorBlock]];
}

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
    if (CFStringCompare((__bridge CFStringRef) mediaType, kUTTypeImage, 0)
        == kCFCompareEqualTo) {

        editedImage = (UIImage *) [info objectForKey:
                                   UIImagePickerControllerEditedImage];
        originalImage = (UIImage *) [info objectForKey:
                                     UIImagePickerControllerOriginalImage];

        if (editedImage) {
            imageToSave = editedImage;
        } else {
            imageToSave = originalImage;
        }

        photoImage.image = imageToSave;
        // Save the new image (original or edited) to the Camera Roll
//        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil , nil);
    }

    [self.navigationController dismissModalViewControllerAnimated: YES];
}

@end
