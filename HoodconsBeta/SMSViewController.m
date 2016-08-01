//
//  SMSViewController.m
//  trckle
//
//  Created by Jeremiah McAllister on 8/14/14.
//  Copyright (c) 2014 Jeremiah McAllister. All rights reserved.
//

#import "SMSViewController.h"
#import "ViewController.h"
#import <MessageUI/MessageUI.h>
#import <Parse/Parse.h>

@interface SMSViewController ()
{
    CGPoint viewOrigCenter;
}

@end

@implementation SMSViewController
@synthesize ccText;
@synthesize phoneNum;
@synthesize delegate;
@synthesize chatDelegate;
@synthesize loginView;

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
    // Do any additional setup after loading the view from its nib.
    viewOrigCenter = loginView.center;
    
    UIImageView *textSpaceC = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
    [textSpaceC setImage:[UIImage imageNamed:@"smssignup-cc-plus.png"]];
    [ccText setLeftViewMode:UITextFieldViewModeAlways];
    [ccText setLeftView:textSpaceC];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)donePressed:(id)sender {
    if (phoneNum.text && ![phoneNum.text isEqualToString:@""]) {
//        NSString *toNum = [NSString stringWithFormat:@"+12247231639"];
//        NSString *fromNum = [NSString stringWithFormat:@"+%@%@", ccText.text, phoneNum.text];
//        NSString *message = [NSString stringWithFormat:@"trckle Verify"];
//        [PFCloud callFunctionInBackground:@"sendSMS"
//                           withParameters:@{@"toNum": toNum, @"fromNum": fromNum, @"message": message}
//                                    block:^(NSString *result, NSError *error) {
//                                        if (!error) {
//                                            NSLog(@"%@", result);
//                                        } else {
//                                            NSLog(@"%@", error);
//                                        }
//                                    }];
//        MFMessageComposeViewController *controller = [[MFMessageComposeViewController alloc] init];
//        if([MFMessageComposeViewController canSendText])
//        {
//            NSLog(@"Sending Text");
//            controller.body = fromNum;
//            controller.recipients = [NSArray arrayWithObjects:toNum, nil];
//            [controller setBody:message];
//            controller.messageComposeDelegate = self;
////            [self presentModalViewController:controller animated:YES];
//            [self presentViewController:controller animated:YES completion:nil];
//        }
        [[NSUserDefaults standardUserDefaults] setValue:phoneNum.text forKey:@"phoneNumber"];
        [[NSUserDefaults standardUserDefaults] synchronize];
//        PFUser *user = [PFUser user];
//        user.username = phoneNum.text;
//        user.password = phoneNum.text;
//        [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//            NSString *alertMsg = nil;
//            BOOL loggedIn = NO;
//            if (error) {
//                if (error.code == 202) {
//                    //                    alertMsg =[NSString stringWithFormat:@"Welcome Back to trckle"];
//                    alertMsg = nil;
//                    loggedIn = YES;
//                } else {
//                    alertMsg = [[error userInfo] objectForKey:@"error"];
//                }
//            } else {
//                alertMsg =[NSString stringWithFormat:@"Phone Number Verified"];
//                [[PFUser currentUser] setObject:phoneNum.text forKey:@"phoneNumber"];
////                [RootViewController current].currUserId = [PFUser currentUser].objectId;
//                loggedIn = YES;
//            }
//            if (alertMsg) {
//                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertMsg message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
//                [alertView show];
//            }
//            if (loggedIn) {
//                [[NSUserDefaults standardUserDefaults] setValue:phoneNum.text forKey:@"phoneNumber"];
//                [[NSUserDefaults standardUserDefaults] synchronize];
//                NSString* myNum = [[PFUser currentUser] objectForKey:@"phoneNumber"];
//                NSLog(@"Phone number is set to %@", myNum);
//            }
//        }];

    }
//    [[RootViewController current] openNavControllerWithID:@"LocationPics" fromID:self.navigationController.title];
    [self dismissViewControllerAnimated:YES completion:nil];
    [chatDelegate didRequestPhone];
//    [delegate didRequestPhone];
}

- (IBAction)dismissKeyboard:(id)sender {
    [ccText resignFirstResponder];
    [phoneNum resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)note
{
//    if ([RootViewController current].screenHeight <= 480) {
//        [UIView animateWithDuration:.2 animations:^{
//            loginView.center = CGPointMake(loginView.center.x, loginView.center.y - 44);
//        }];
//    }
}

- (void)keyboardWillHide:(NSNotification *)note
{
//    [UIView animateWithDuration:.2 animations:^{
//        loginView.center = viewOrigCenter;
//    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return true;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
		case MessageComposeResultCancelled:
        {
            NSLog(@"Cancelled");
        }
            break;
		case MessageComposeResultFailed:
        {
            NSLog(@"Failed");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Hoodcons" message:nil delegate:self cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
            [alert show];
        }
            
			break;
		case MessageComposeResultSent:
        {
            NSLog(@"Sent");
        }
			break;
		default:
			break;
	}
    
//	[self dismissModalViewControllerAnimated:YES];
}

@end
