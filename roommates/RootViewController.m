//
//  RootViewController.m
//  roommates
//
//  Created by andrew morton on 7/13/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import "RootViewController.h"
#import "LoginViewController.h"
#import "RMData.h"

@interface RootViewController ()

@end

@implementation RootViewController {
    NSString *currentViewIdentifier;
}

- (id)init
{
    currentViewIdentifier = @"NoteList";
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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

- (IBAction)signOut:(id)sender {
    NSLog(@"Signing out…");
    [RMSession endSession];

    // TODO: figure out how to do this with a transition. It's too abrupt now.
    UIStoryboard* mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard" bundle:nil];
    LoginViewController* loginViewController = [mainStoryboard instantiateViewControllerWithIdentifier:@"Login"];
    UIApplication.sharedApplication.keyWindow.rootViewController = loginViewController;
}

@end
