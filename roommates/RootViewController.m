//
//  RootViewController.m
//  roommates
//
//  Created by andrew morton on 7/13/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RootViewController.h"
#import "SigninViewController.h"
#import "RMData.h"

@interface RootViewController ()

@end

@implementation RootViewController

@synthesize currentViewIdentifier;

- (id)init
{
    currentViewIdentifier = @"ExpenseSummary";
    UIStoryboard* s = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController* rear = [s instantiateViewControllerWithIdentifier:@"Menu"];
    UIViewController* front = [s instantiateViewControllerWithIdentifier:currentViewIdentifier];
    self = [super initWithFrontViewController:front rearViewController:rear];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogin:) name:@"RMSessionStarted" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onLogout:) name:@"RMSessionEnded" object:nil];
}

-(void)viewDidAppear:(BOOL)animated
{
    // When we start up check if we need to login.
    if (![[RMSession instance] userId]) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *email = [defaults stringForKey:@"email"];
        NSString *password = [defaults stringForKey:@"password"];
        if (email.length > 0 && password.length > 0) {
            [RMSession startSessionEmail:email Password:password OnSuccess:^(id object) {
                // Should be good...
            } OnFailure:^(NSError *error) {
                [self showSignIn:nil];
            }];
        }
        else {
            [self showSignIn:nil];
        }
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)onLogin:(NSNotification*)note
{
    // We got logged in, let's fetch the households before doing anything
    // else.
    [RMHousehold getHouseholdsOnSuccess:^(NSArray *objects) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Hi %@!", [RMSession instance].displayName]];
        [self dismissViewControllerAnimated:YES completion:^{}];
    } OnFailure:^(NSError *error) {
        [[[UIAlertView alloc] initWithTitle:@"Fetching Households"
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:nil] show];
    }];
}

- (void)onLogout:(NSNotification*)note
{
    [SVProgressHUD dismiss];
    [self showSignIn:nil];
}

- (void)switchToViewWithIdentifier:(NSString*)identifer
{
    if (![currentViewIdentifier isEqualToString:identifer]) {
        UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
        UIViewController* frontViewController = [mainStoryboard instantiateViewControllerWithIdentifier:identifer];
        [self setFrontViewController:frontViewController animated:YES];
        currentViewIdentifier = identifer;
        return;        
    }
    // Seem like they want to stay where they are.
    [self revealToggle:self];
}

- (IBAction)showActivityFeed:(id)sender {
    NSLog(@"Activity Feed");
    [self switchToViewWithIdentifier:@"LogEntryList"];
}

- (IBAction)showExpenses:(id)sender {
    NSLog(@"Expenses");
    [self switchToViewWithIdentifier:@"ExpenseSummary"];
}

- (IBAction)showShoppingList:(id)sender {
    NSLog(@"Shopping List");
    [self switchToViewWithIdentifier:@"ShoppingList"];
}

- (IBAction)showTodos:(id)sender {
    NSLog(@"To-Do's");
    [self switchToViewWithIdentifier:@"ToDoList"];
}

- (IBAction)showNotes:(id)sender {
    NSLog(@"Notes");
    [self switchToViewWithIdentifier:@"NoteList"];
}

- (IBAction)showSignIn:(id)sender {
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    UIViewController *vc = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:vc animated:YES completion:^{}];
}

- (IBAction)signOut:(id)sender {
    NSLog(@"Signing out…");
    [SVProgressHUD showWithStatus:@"Signing out"];
    [RMSession endSession];
    [self revealToggle:self];
}

@end
