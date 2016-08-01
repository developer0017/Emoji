//
//  ContactsViewController.h
//  Hoodcons
//
//  Created by SKY on 12/8/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ContactObject.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MFMailComposeViewController.h>
#import <MessageUI/MFMessageComposeViewController.h>
@interface ContactsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIActionSheetDelegate>
{
    NSArray *searchResults;
    BOOL sort;
}
@property (strong, nonatomic) ContactObject                  *selectuser;
@property(strong, nonatomic) NSMutableArray *contacts;
@property(nonatomic, retain) IBOutlet UITableView *contactlisttbl;
@end
