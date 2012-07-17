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

    UIImage *image = [UIImage imageNamed:@"signIn.png"];
    self.view.backgroundColor = [UIColor colorWithPatternImage:image];

    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    email.text = [defaults stringForKey:@"email"];
    password.text = [defaults stringForKey:@"password"];
    login.enabled = (email.text.length && password.text.length);
    // @"delany@gmail.com";
    // @"123456";
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
    [SVProgressHUD showWithStatus:@"Logging in" maskType: SVProgressHUDMaskTypeBlack];

    [RMSession startSessionEmail:email.text Password:password.text OnSuccess:^(RMSession *session) {
        NSLog(@"Loaded User ID #%@ -> Name: %@, token: %@", session.userId, session.fullName, session.apiToken);
        [SVProgressHUD dismiss];
        // The signin will fire a notification that will close this view.
    } OnFailure:^(NSError *error) {
        NSLog(@"Encountered an error: %@", error);
        NSString *message = [[[error userInfo] valueForKeyPath:@"RKObjectMapperErrorObjectsKey.error"] lastObject];
        [SVProgressHUD showErrorWithStatus:message];
    }];
}

- (IBAction)signup:(id)sender {
    // TODO: Need to get the correct URL for this.
    NSString* launchUrl = @"http://roommat.es/users/sign_up";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}
@end
