//
//  LoginViewController.m
//  roommates
//
//  Created by andrew morton on 7/7/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "LoginViewController.h"
#import "RootViewController.h"
#import "RMData.h"

@interface LoginViewController ()

@end

@implementation LoginViewController
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
    // Do any additional setup after loading the view.
    email.text = @"delany@gmail.com";
    password.text = @"123456";
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
    login.enabled = (email.text.length && password.text.length);
    return TRUE;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:email]) {
        [password becomeFirstResponder];
    }
    else if ([textField isEqual:password]) {
        if (login.enabled) {
            [login sendActionsForControlEvents: UIControlEventTouchUpInside];
        }
    }
    return FALSE;
}

- (void)loggedIn
{
    RootViewController *vc = [[RootViewController alloc] init];
    UIApplication.sharedApplication.keyWindow.rootViewController = vc;
}

- (IBAction)login:(id)sender {
    [SVProgressHUD showWithStatus:@"Logging in" maskType: SVProgressHUDMaskTypeBlack];

    [RMSession startSessionEmail:email.text Password:password.text OnSuccess:^(RMSession *session) {
        NSLog(@"Loaded User ID #%@ -> Name: %@, token: %@", session.userId, session.fullName, session.apiToken);
        // We got logged in, let's fetch the households before doing anything 
        // else.
        [RMHousehold getHouseholdsOnSuccess:^(NSArray *objects) {
            [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Hi %@!", session.displayName]];
            [self loggedIn];
        } OnFailure:^(NSError *error) {
            [SVProgressHUD dismiss];
//            [SVProgressHUD showErrorWithStatus:@"Bad login?"];
            [[[UIAlertView alloc] initWithTitle:@"Error"
                                        message:[error localizedDescription]
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }];
    } OnFailure:^(NSError *error) {
        [SVProgressHUD dismiss];
        NSLog(@"Encountered an error: %@", error);
//        [SVProgressHUD showErrorWithStatus:@"Bad login?"];
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
}

- (IBAction)signup:(id)sender {
    // TODO: Need to get the correct URL for this.
    NSString* launchUrl = @"http://roommates-staging.herokuapp.com/users/sign_in";
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
}
@end
