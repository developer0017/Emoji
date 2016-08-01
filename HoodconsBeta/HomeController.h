//
//  HomeController.h
//  Hoodcons
//
//  Created by Jeremiah McAllister on 10/26/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>

@interface HomeController : UIViewController<ABPeoplePickerNavigationControllerDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>
{
    IBOutlet UIButton *restoreBtn;
    IBOutlet UIButton *messageBtn;
    IBOutlet UIButton *storeBtn;
    IBOutlet UIButton *shareBtn;
    
    IBOutlet UIImageView *homeIcon;
    IBOutlet UIWebView *webViewBkg;

    NSString *userphone;
    NSString *useremail;
    
    
    ABPeoplePickerNavigationController *picker;
}

@end
