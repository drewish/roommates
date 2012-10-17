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

@implementation SigninViewController {
    UIGestureRecognizer *tapper;
}

@synthesize email;
@synthesize password;
@synthesize login;
@synthesize signup;

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

    UIImage* normalImage = [[UIImage imageNamed:@"button-normal.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    UIImage* activeImage = [[UIImage imageNamed:@"button-depressed.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(14, 14, 14, 14)];
    [self.login setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.login setBackgroundImage:activeImage forState:UIControlStateHighlighted];
    [self.signup setBackgroundImage:normalImage forState:UIControlStateNormal];
    [self.signup setBackgroundImage:activeImage forState:UIControlStateHighlighted];

    // Do any additional setup after loading the view.
    PDKeychainBindings *keychain = [PDKeychainBindings sharedKeychainBindings];
    email.text = [keychain stringForKey:@"email"];
    password.text = [keychain stringForKey:@"password"];
    login.enabled = (email.text.length && password.text.length);

    tapper = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    tapper.cancelsTouchesInView = FALSE;
    [self.view addGestureRecognizer:tapper];
}

- (void)viewDidUnload {
    [self.view removeGestureRecognizer:tapper];
    tapper = nil;

    [self setEmail:nil];
    [self setPassword:nil];
    [self setLogin:nil];
    [self setSignup:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)handleSingleTap:(UITapGestureRecognizer *) sender
{
    [self.view endEditing:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *asText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    UITextField *otherText = [textField isEqual:email] ? password : email;
    login.enabled = asText.length > 0 && otherText.text.length > 0;

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
