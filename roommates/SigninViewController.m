//
//  LoginViewController.m
//  roommates
//
//  Created by andrew morton on 7/7/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "SigninViewController.h"
#import "RootViewController.h"
#import "RMData.h"
#import "PDKeychainBindingsController.h"

@interface SigninViewController ()

@end

@implementation SigninViewController
@synthesize email;
@synthesize password;
@synthesize login;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *image = [UIImage imageNamed:@"background.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    // Do any additional setup after loading the view.
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    email.text = [keychain stringForKey:@"email"];
    password.text = [keychain stringForKey:@"password"];
    login.enabled = (email.text.length && password.text.length);
}

- (void)viewDidUnload
{
    [self setEmail:nil];
    [self setPassword:nil];
    [self setLogin:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // TODO: this isn't the best place to do this since the length won't have 
    // the requested change so we'll be a little behind.
    login.enabled = (email.text.length && password.text.length);
    return TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:email]) {
        [password becomeFirstResponder];
        return TRUE;
    }
    else if ([textField isEqual:password]) {
        if (login.enabled) {
            [textField resignFirstResponder];
            [login sendActionsForControlEvents: UIControlEventTouchUpInside];
            return TRUE;
        }
    }
    return FALSE;
}

- (IBAction)login:(id)sender {
    // Get rid of any keyboard so the HUD doesn't end up moving around as much.
    [self.view endEditing:NO];
    [SVProgressHUD showWithStatus:@"Logging in…" maskType:SVProgressHUDMaskTypeGradient];

    [RMSession startSessionEmail:email.text Password:password.text OnSuccess:^(RMSession *session) {
        // Store a copy for loading.
        PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
        [keychain setObject:session.apiToken forKey:@"apiToken"];
        [keychain setObject:email.text forKey:@"email"];
        [keychain setObject:password.text forKey:@"password"];

        NSLog(@"Loaded User ID #%@ -> Name: %@, token: %@", session.userId, session.fullName, session.apiToken);
        [TestFlight passCheckpoint:@"Signed in"];
        // The RootViewController will handle the signin notification and close
        // this view and dismiss the HUD.
    } OnFailure:^(NSError *error) {
        NSLog(@"Encountered an error: %@", error);
        NSString *message = [[[error userInfo] valueForKeyPath:@"RKObjectMapperErrorObjectsKey.error"] lastObject];
        if (message.length < 1) {
            message = @"Sorry, the server is speaking in tongues.";
        }
        [SVProgressHUD showErrorWithStatus:message];
    }];
}

- (IBAction)signup:(id)sender {
    // TODO: Need to get the correct URL for this.
    NSString* launchUrl = @"http://roommat.es/users/sign_up";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}
@end
