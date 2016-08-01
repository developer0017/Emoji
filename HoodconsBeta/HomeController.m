//
//  HomeController.m
//  Hoodcons
//
//  Created by Jeremiah McAllister on 10/26/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import "HomeController.h"

#import "ViewController.h"
#import "AppDelegate.h"
#import "StoreViewController.h"
#import "ContactsViewController.h"
#import "ChatViewController.h"

@interface HomeController () <UIAlertViewDelegate>
{
    NSString *myPhoneNum;
    NSString *myInstallID;
    BOOL byPhone;
    BOOL lessThan8;
}

@end

@implementation HomeController

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
    NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float < 8.0) {
        lessThan8 = YES;
    } else {
        lessThan8 = NO;
    }
    
    CGRect screen = [UIScreen mainScreen].bounds;
    CGFloat screenH = screen.size.height;
    CGFloat hAdj = 0;
    if (screenH < 568) {
        hAdj = 68;
    }
    CGFloat topOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]){
        topOffset += self.topLayoutGuide.length;
    }
//    if (lessThan8) {
//        topOffset += 20;
//    }
    hAdj -= topOffset;
//    CGFloat libBtnTop = libBtn.frame.origin.y;
    CGRect frame = messageBtn.frame;
    frame.origin.y = frame.origin.y - hAdj;
    messageBtn.frame = frame;
    frame = storeBtn.frame;
    frame.origin.y = frame.origin.y - hAdj;
    storeBtn.frame = frame;
    frame = shareBtn.frame;
    frame.origin.y = frame.origin.y - hAdj;
    shareBtn.frame = frame;
    
    CGPoint center = CGPointMake(screen.size.width/2, screenH/2);
//    if (screenH < 568) {
//        center = CGPointMake(screen.size.width/2, screenH/2 - hAdj);
//    }
    homeIcon.center = center;
    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Hoodconshomescreen-Video" ofType:@"gif"];
    
    NSData *bkgGif = [NSData dataWithContentsOfFile:filePath];
    
    [webViewBkg loadData:bkgGif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    
    byPhone = YES;
}


- (IBAction)sharebtnclick:(id)sender
{
//    ContactsViewController *contactcontroller = [[ContactsViewController alloc]initWithNibName:@"ContactsViewController" bundle:nil];
//    [self presentViewController:contactcontroller animated:YES completion:nil];
    
    picker =
    [[ABPeoplePickerNavigationController alloc] init];
    picker.peoplePickerDelegate = self;
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person {
    
    ABMultiValueRef emailNumbers = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonEmailProperty);
    CFRelease(emailNumbers);
    useremail = (__bridge NSString*)ABMultiValueCopyValueAtIndex(emailNumbers, 0);
    
    
    ABMultiValueRef phoneNumbers = (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
    CFRelease(phoneNumbers);
    userphone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phoneNumbers, 0);
 
    NSLog(@"email=%@", useremail);
    NSLog(@"phone=%@", userphone);
    
    UIActionSheet *actionSheet;
    actionSheet = [[UIActionSheet alloc]
                   initWithTitle:NSLocalizedString(@"Invite your friends in Hoodcons",@"")
                   delegate:self
                   cancelButtonTitle:nil
                   destructiveButtonTitle:NSLocalizedString(@"Cancel",@"")
                   otherButtonTitles:NSLocalizedString(@"Invite Via E-mail",@""),NSLocalizedString(@"Invite Via SMS",@""),nil];
    
    actionSheet.tag = 1;
    actionSheet.alpha = 1.0;
    [actionSheet showFromRect:CGRectMake(0, self.view.frame.size.height-60, self.view.frame.size.width, 60) inView:self.view animated:YES];
    
    return NO;
    
}

- (void)peoplePickerNavigationControllerDidCancel:
(ABPeoplePickerNavigationController *)peoplePicker
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)peoplePickerNavigationController:
(ABPeoplePickerNavigationController *)peoplePicker
      shouldContinueAfterSelectingPerson:(ABRecordRef)person
                                property:(ABPropertyID)property
                              identifier:(ABMultiValueIdentifier)identifier
{
    return NO;
}


- (void)loadKeyboardView
{
    ChatViewController *svc = [[ChatViewController alloc] initWithNibName:@"ChatViewController" bundle:nil];
    [self presentViewController:svc animated:YES completion:nil];
    
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate showKeyBoard2];
}

- (IBAction)msgPressed:(id)sender {
    [self loadKeyboardView];
}

- (IBAction)storePressed:(UIButton *)sender {
    StoreViewController *svc = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    [self presentViewController:svc animated:YES completion:nil];
}


-(void)listSysFonts
{
    // List all fonts on iPhone
    NSArray *familyNames = [[NSArray alloc] initWithArray:[UIFont familyNames]];
    NSArray *fontNames;
    NSInteger indFamily, indFont;
    for (indFamily=0; indFamily<[familyNames count]; ++indFamily)
    {
        NSLog(@"Family name: %@", [familyNames objectAtIndex:indFamily]);
        fontNames = [[NSArray alloc] initWithArray:
                     [UIFont fontNamesForFamilyName:
                      [familyNames objectAtIndex:indFamily]]];
        for (indFont=0; indFont<[fontNames count]; ++indFont)
        {
            NSLog(@"    Font name: %@", [fontNames objectAtIndex:indFont]);
        }
    }
    if ([familyNames containsObject:@"Hoodcons"]){
        NSLog(@"!!!!! HOODCONS FOUND !!!!!!!!!!");
    } else {
        NSLog(@"!!!!! HOODCONS NOT FOUND !!!!!!!!!!");
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)sendMail {
    
    if ([MFMailComposeViewController canSendMail]) {
        
        MFMailComposeViewController *mailViewController = [[MFMailComposeViewController alloc] init];
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        mailViewController.mailComposeDelegate = self;
        mailViewController.title = @"Invite Friend";
        [mailViewController setToRecipients:[NSArray arrayWithObjects:useremail, nil]];
        [mailViewController setSubject:@"Hoodcons SMS"];
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [mailViewController setMessageBody:@"Hoodcons SMS: Download Hoodcons! Emoji's from the street!. FREE download  from https://itunes.apple.com/us/app/hoodcons/id949461768?ls=1&mt=8" isHTML:NO];
        
        [picker presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Device is unable to send e-mail in its current state." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
	
	if (actionSheet.tag == 1) {
		if (buttonIndex == 0){
			
		}
		else if (buttonIndex == 1){
			[self sendMail];
			
		}
		else if (buttonIndex == 2){
			[self sendSMS];
		}
	}
}



- (void)sendSMS {
    
    if ([MFMessageComposeViewController canSendText]) {
        
        MFMessageComposeViewController *mailViewController = [[MFMessageComposeViewController alloc] init];
        mailViewController.navigationBar.tintColor = [UIColor blackColor];
        mailViewController.messageComposeDelegate = self;
        [mailViewController setRecipients:[NSArray arrayWithObjects:userphone, nil]];
        mailViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        mailViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        mailViewController.title = @"Invite Friend";
        mailViewController.body = @"Hoodcons SMS: Download Hoodcons! Emoji's from the street!. FREE download  from https://itunes.apple.com/us/app/hoodcons/id949461768?ls=1&mt=8";
        
       [picker presentViewController:mailViewController animated:YES completion:nil];
    }
    
    else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"Device is unable to send SMS in its current state." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        
    }
}


#pragma mark Mail Delegate

-(void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
}

@end
