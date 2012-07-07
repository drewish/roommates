//
//  LoginViewController.h
//  roommates
//
//  Created by andrew morton on 7/7/12.
//  Copyright (c) 2012 drewish.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^OnLoginBlock)(id object);

@interface LoginViewController : UIViewController
@property (strong, nonatomic) OnLoginBlock onLogin;
@property (weak, nonatomic) IBOutlet UITextField *email;
@property (weak, nonatomic) IBOutlet UITextField *password;
- (IBAction)login:(id)sender;
- (IBAction)signup:(id)sender;

@end
