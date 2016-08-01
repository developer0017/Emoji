//
//  SMSViewController.h
//  trckle
//
//  Created by Jeremiah McAllister on 8/14/14.
//  Copyright (c) 2014 Jeremiah McAllister. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"
#import "ChatViewController.h"
#import <MessageUI/MessageUI.h>

@interface SMSViewController : UIViewController <MFMessageComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UIView *loginView;
@property (strong, nonatomic) IBOutlet UITextField *ccText;
@property (strong, nonatomic) IBOutlet UITextField *phoneNum;

@property (strong, nonatomic) IBOutlet UIButton *doneBtn;

- (IBAction)donePressed:(id)sender;

- (IBAction)dismissKeyboard:(id)sender;

@property (assign, nonatomic) ViewController *delegate;
@property (assign, nonatomic) ChatViewController *chatDelegate;

@end
