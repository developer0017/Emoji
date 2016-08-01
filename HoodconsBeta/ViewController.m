//
//  ViewController.m
//  FaceBoardDome
//
//  Created by blue on 12-12-20.
//  Copyright (c) 2012年 Blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood
//

#import <Parse/Parse.h>
#import "ProgressHUD.h"

#import "ViewController.h"
#import "AppConstant.h"
#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "ProgressHUD.h"
#import "utilities.h"
#import "messages.h"
#import "pushnotification.h"

#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SMSViewController.h"
#import "MessagesViewController.h"
#import "ChatViewController.h"
#import "THContact.h"
#import "SETextView.h"


UIBarButtonItem *barButton;

@interface ViewController () <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>
{
    BOOL byPhone;
    BOOL userChecked;

    NSString *currMsg;
    UIImage *currImg;
    UIAlertView *choiceAlert;
    
    NSTimer *timer;
    BOOL isLoading;

    NSArray *currMessageRange;
    
    NSString *roomId;
    
    NSMutableArray *users;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
    
//    JSQMessagesBubbleImage *outgoingBubbleImageData;
//    JSQMessagesBubbleImage *incomingBubbleImageData;
//    
//    JSQMessagesAvatarImage *placeholderImageData;
}

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, assign) NSString *myPhoneNum;
@property (nonatomic, assign) NSString *myInstallID;

@end

#define kKeyboardHeight 216.0
//#define kKeyboardHeight 0.0

@implementation ViewController


@synthesize tmpCell, cellNib;
@synthesize backImg;
@synthesize tmpMsgView;
@synthesize lessThan7;
@synthesize myPhoneNum;
@synthesize myInstallID;
@synthesize parseUsers, parseUserNums, parseMatchingContacts;


- (void)viewDidLoad {

    [super viewDidLoad];
    
    NSLog(@"System Version is %@",[[UIDevice currentDevice] systemVersion]);
	NSString *ver = [[UIDevice currentDevice] systemVersion];
    float ver_float = [ver floatValue];
    if (ver_float < 7.0) {
        lessThan7 = YES;
    } else {
        lessThan7 = NO;
    }

    if ( !faceBoard) {

        faceBoard = [[FaceBoard alloc] init];
        faceBoard.delegate = self;
        faceBoard.inputTextView = textView;
    }

    if ( !messageList ) {

        messageList = [[NSMutableArray alloc] init];
    }

    if ( !sizeList ) {

        sizeList = [[NSMutableDictionary alloc] init];
    }

    self.cellNib = [UINib nibWithNibName:@"MessageListCell" bundle:nil];

    //textView.contentInset = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
    [textView.layer setCornerRadius:6];
    [textView.layer setMasksToBounds:YES];
    textView.layer.borderColor = [[UIColor whiteColor] CGColor];
    textView.layer.borderWidth = 1.0f;
    
    [msgView.layer setCornerRadius:6];
    [msgView.layer setMasksToBounds:YES];
    msgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    msgView.layer.borderWidth = 1.0f;
    
    contactPickerView.delegate = self;
    [contactPickerView setPlaceholderString:@"To:"];
    [contactPickerView setBackgroundColor:[UIColor clearColor]];
    
//    barButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(done:)];
//    [barButton setTintColor:[UIColor whiteColor]];
//    barButton.enabled = FALSE;
//    self.navigationItem.rightBarButtonItem = barButton;
    
    // Fill the rest of the view with the table view
    self.contactTV = [[UITableView alloc] initWithFrame:CGRectMake(0, contactPickerView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - hdrView.frame.size.height - contactPickerView.frame.size.height - kKeyboardHeight) style:UITableViewStylePlain];
    self.contactTV.delegate = self;
    self.contactTV.dataSource = self;
    
    [self.contactTV registerNib:[UINib nibWithNibName:@"THContactPickerTableViewCell" bundle:nil] forCellReuseIdentifier:@"ContactCell"];
    
    [self.contactTV setBackgroundColor:[UIColor clearColor]];
    
    [self.contactTV setSeparatorColor:[UIColor clearColor]];
    [self.contactTV setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    [self.view insertSubview:self.contactTV aboveSubview:contactPickerView];
    self.contactTV.hidden = YES;
    
//    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
//        if (granted) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [self getContactsFromAddressBook];
//            });
//        } else {
//            // TODO: Show alert
//        }
//    });
//    [self getParseUsers];
    [self getContacts];

    [doneBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];

    [self hideDoneBtn:YES];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [msgView addGestureRecognizer:tapGesture];
    
    isFirstShowKeyboard = YES;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    byPhone = appDelegate.byPhone;
    userChecked = NO;
    myPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    myInstallID = [[NSUserDefaults standardUserDefaults] objectForKey:@"installID"];
//    myPhoneNum = nil;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardDidHide:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    NSLog(@"View Will Appear");
    
    if (iPhone5) {
        
        self.view.frame = CGRectMake(0, 0, 320, 568);
        self.backImg.frame = CGRectMake(0, 0, 320, 568);
    }
    else{
        
        self.view.frame = CGRectMake(0, 0, 320, 480);
        self.backImg.frame = CGRectMake(0, 0, 320, 480);
    }
    int iOSadj = 0;
    if (lessThan7) {
        iOSadj += 20;
    }
    
    CGRect frame = messageListView.frame;
    //    frame.size.height = self.view.frame.size.height - 64;
    frame.size.height = self.view.frame.size.height - toolBar.frame.size.height - iOSadj;
    messageListView.frame = frame;
    
    frame = toolBar.frame;
    //    frame.origin.y = self.view.frame.size.height - 64;
    frame.origin.y = self.view.frame.size.height - frame.size.height - iOSadj;
    toolBar.frame = frame;
    
    [self getContacts];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
}

- (void)viewDidAppear:(BOOL)animated {
    [PFUser logOut];
    [PFUser logInWithUsername:myPhoneNum password:myPhoneNum];
    PFUser *user = [PFUser currentUser];
    if (!user) {
        if (myPhoneNum) {
            [self getOrCreateUser];
        } else if (byPhone && !userChecked) {
            [self checkForPhone];
        }
    } else {
        NSLog(@"User was found with ID: %@", user.username);
        NSLog(@"The Device Installation ID was: %@", myInstallID);
        NSLog(@"Installation ID from Parse was: %@", user[@"installID"]);
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat topOffset = hdrView.frame.size.height;
    //    if ([self respondsToSelector:@selector(topLayoutGuide)]){
    //        topOffset += self.topLayoutGuide.length;
    //    }
    CGRect frame = contactPickerView.frame;
    frame.origin.y = topOffset;
    contactPickerView.frame = frame;
    [self adjustTableViewFrame:NO];
}


-(void)getContacts
{
    ABAddressBookRequestAccessWithCompletion(self.addressBookRef, ^(bool granted, CFErrorRef error) {
        if (granted) {
            dispatch_async(dispatch_get_main_queue(), ^{
//                [self getParseUsers];
                [self getContactsFromAddressBook];
            });
        } else {
            // TODO: Show alert
        }
    });
}

-(void)getParseUsers
{
    PFQuery *query = [PFUser query];
    NSArray *objects = [query findObjects];
    parseUsers = [NSArray arrayWithArray:objects];
    NSLog(@"%lu Parse Users found", (unsigned long)parseUsers.count);
    NSMutableArray *parseNums = [[NSMutableArray alloc] init];
    for (PFUser *user in parseUsers) {
        NSLog(@"adding %@ to parse nums", user.username);
        [parseNums addObject:user.username];
    }
    parseUserNums = [NSArray arrayWithArray:parseNums];
    NSLog(@"%lu Parse Users Numbers Added", (unsigned long)parseUserNums.count);

//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//        if (!error) {
////            NSLog(@"%lu Parse Users found", (unsigned long)objects.count);
//            parseUsers = [NSArray arrayWithArray:objects];
//            NSLog(@"%lu Parse Users found", (unsigned long)parseUsers.count);
//            NSMutableArray *parseNums = [[NSMutableArray alloc] init];
//            for (PFUser *user in parseUsers) {
//                NSLog(@"adding %@ to parse nums", user.username);
//                [parseNums addObject:user.username];
//            }
//            self.parseUserNums = [NSArray arrayWithArray:parseUserNums];
//        }
//    }];
}

-(void)getParseUsersByPhoneArray:(NSArray *)phoneNumList
{
    NSLog(@"Checking for %lu phone #s", (unsigned long)phoneNumList.count);
    PFQuery *query = [PFUser query];
    [query whereKey:@"username" containedIn:phoneNumList];
    NSArray *objects = [query findObjects];
    parseUsers = [NSArray arrayWithArray:objects];
    NSLog(@"%lu Parse Users found by phone#", (unsigned long)parseUsers.count);
    NSMutableArray *parseNums = [[NSMutableArray alloc] init];
    for (PFUser *user in parseUsers) {
        NSLog(@"adding %@ to parse nums", user.username);
        [parseNums addObject:user.username];
    }
    parseUserNums = [NSArray arrayWithArray:parseNums];
    NSLog(@"%lu Parse Users Numbers Added", (unsigned long)parseUserNums.count);
}

-(void)checkForPhone
{
    if (!myPhoneNum || [myPhoneNum isEqualToString:@""]) {
        SMSViewController *vc = [[SMSViewController alloc] initWithNibName:nil bundle:nil];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
        userChecked = YES;
    } else {
        NSLog(@"Phone number is saved as %@", myPhoneNum);
        [self getOrCreateUser];
    }
}

- (void)didRequestPhone
{
    myPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    if (myPhoneNum) {
        [self getOrCreateUser];
    }
}

-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
    BOOL queryAllParse = NO;
    
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:allContacts.count];
        NSMutableArray *parseMatchContacts = [[NSMutableArray alloc] init];
        NSMutableArray *phoneNums = [[NSMutableArray alloc] init];
        NSString *phoneDigs;
        
        if (queryAllParse) {
            [self getParseUsers];
        }
        
        NSUInteger i = 0;
        for (i = 0; i<[allContacts count]; i++)
        {
            THContact *contact = [[THContact alloc] init];
            ABRecordRef contactPerson = (__bridge ABRecordRef)allContacts[i];
            contact.recordId = ABRecordGetRecordID(contactPerson);
            
            // Get first and last names
            NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
            NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
            
            // Set Contact properties
            contact.firstName = firstName;
            contact.lastName = lastName;
            
            // Get mobile number
            ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
            contact.phone = [self getMobilePhoneProperty:phonesRef];
            if(phonesRef) {
                CFRelease(phonesRef);
            }
            
            // Get image if it exists
            NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
            contact.image = [UIImage imageWithData:imgData];
            if (!contact.image) {
                contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
            }
            
            if (contact.phone) {
                if (queryAllParse) {
                    NSLog(@"Adding contact with #: %@",contact.phone);
                    phoneDigs = [[contact.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    NSLog(@"Checking %@", phoneDigs);
                    if ([parseUserNums containsObject:phoneDigs]) {
                        [parseMatchContacts addObject:contact];
                    } else {
                        [mutableContacts addObject:contact];
                    }
                } else {
                    NSLog(@"Adding contact with #: %@",contact.phone);
                    [mutableContacts addObject:contact];
                    phoneDigs = [[contact.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                    NSLog(@"Adding %@", phoneDigs);
                    [phoneNums addObject:phoneDigs];
                }
            }
        }
        
        if(addressBook) {
            CFRelease(addressBook);
        }
        
        if (!queryAllParse) {
            [self getParseUsersByPhoneArray:phoneNums];
            NSMutableArray *mutableCopy = mutableContacts.mutableCopy;
            for (THContact *contact in mutableContacts) {
                phoneDigs = [[contact.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                if ([parseUserNums containsObject:phoneDigs]) {
                    [parseMatchContacts addObject:contact];
                    [mutableCopy removeObject:contact];
                }
            }
            mutableContacts = mutableCopy;
        }
        
        parseMatchingContacts = [NSArray arrayWithArray:parseMatchContacts];
        NSLog(@"Found %lu Matching Contacts", (unsigned long)parseMatchingContacts.count);
        
        NSMutableArray *finalContacts = [NSMutableArray arrayWithArray:parseMatchContacts];
        [finalContacts addObjectsFromArray:mutableContacts];
        
        self.contacts = [NSArray arrayWithArray:finalContacts];
        
//        self.contacts = [NSArray arrayWithArray:mutableContacts];
        self.selectedContacts = [NSMutableArray array];
        self.filteredContacts = self.contacts;

        [self.contactTV reloadData];
    }
    else
    {
        NSLog(@"Error");
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.contactTV reloadData];
}

- (void) refreshContact:(THContact*)contact
{
    
    ABRecordRef contactPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, (ABRecordID)contact.recordId);
    contact.recordId = ABRecordGetRecordID(contactPerson);
    
    // Get first and last names
    NSString *firstName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonFirstNameProperty);
    NSString *lastName = (__bridge_transfer NSString*)ABRecordCopyValue(contactPerson, kABPersonLastNameProperty);
    
    // Set Contact properties
    contact.firstName = firstName;
    contact.lastName = lastName;
    
    // Get mobile number
    ABMultiValueRef phonesRef = ABRecordCopyValue(contactPerson, kABPersonPhoneProperty);
    contact.phone = [self getMobilePhoneProperty:phonesRef];
    if(phonesRef) {
        CFRelease(phonesRef);
    }
    
    // Get image if it exists
    NSData  *imgData = (__bridge_transfer NSData *)ABPersonCopyImageData(contactPerson);
    contact.image = [UIImage imageWithData:imgData];
    if (!contact.image) {
        contact.image = [UIImage imageNamed:@"icon-avatar-60x60"];
    }
}

- (NSString *)getMobilePhoneProperty:(ABMultiValueRef)phonesRef
{
    for (int i=0; i < ABMultiValueGetCount(phonesRef); i++) {
        CFStringRef currentPhoneLabel = ABMultiValueCopyLabelAtIndex(phonesRef, i);
        CFStringRef currentPhoneValue = ABMultiValueCopyValueAtIndex(phonesRef, i);
        
        if(currentPhoneLabel) {
            if (CFStringCompare(currentPhoneLabel, kABPersonPhoneMobileLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
            
            if (CFStringCompare(currentPhoneLabel, kABHomeLabel, 0) == kCFCompareEqualTo) {
                return (__bridge NSString *)currentPhoneValue;
            }
        }
        if(currentPhoneLabel) {
            CFRelease(currentPhoneLabel);
        }
        if(currentPhoneValue) {
            CFRelease(currentPhoneValue);
        }
    }
    
    return nil;
}

- (void)getOrCreateUser
{
    [PFUser logOut];
    [PFUser logInWithUsername:myPhoneNum password:myPhoneNum];
    PFUser *user = [PFUser currentUser];
    if (user) {
        NSLog(@"User Found: %@", user.username);
        NSLog(@"Installation ID was %@", user[@"installID"]);
//        [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {code}];
    } else {
        user = [PFUser user];
        if (byPhone) {
            user.username = myPhoneNum;
            user.password = myPhoneNum;
        } else {
            user.username = myInstallID;
            user.password = myInstallID;
        }
        user[@"installID"] = myInstallID;
        if (user.username) {
            
            [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                NSString *alertMsg = nil;
                BOOL loggedIn = NO;
                if (error) {
                    if (error.code == 202) {
                        alertMsg =[NSString stringWithFormat:@"Welcome Back to Hoodcons"];
                        //                alertMsg = nil;
                        loggedIn = YES;
                    } else {
                        alertMsg = [[error userInfo] objectForKey:@"error"];
                    }
                } else {
                    alertMsg =[NSString stringWithFormat:@"User Logged In"];
                    loggedIn = YES;
                }
                if (alertMsg) {
                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:alertMsg message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Ok", nil];
                    [alertView show];
                }
            }];
        } else {
            NSLog(@"!!!!! No username to create user !!!!!");
        }
    }
}

#pragma mark - Gesture Recognizer

- (void)handleTapGesture {
    NSLog(@"MsgView tapped");
    // Show textField
    //    textView.hidden = NO;
    [textView becomeFirstResponder];
}


#pragma mark - Keyboard Notification

/** ################################ UIKeyboardNotification ################################ **/

- (void)keyboardWillShow:(NSNotification *)notification {

    isKeyboardShowing = YES;

    NSDictionary *userInfo = [notification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = messageListView.frame;
                         frame.size.height += keyboardHeight;
                         frame.size.height -= keyboardRect.size.height;
                         messageListView.frame = frame;
                         
                         frame = toolBar.frame;
                         frame.origin.y += keyboardHeight;
                         frame.origin.y -= keyboardRect.size.height;
                         toolBar.frame = frame;
                         
                         keyboardHeight = keyboardRect.size.height;
                     }];

    if ( isFirstShowKeyboard ) {
        
        isFirstShowKeyboard = NO;
        
//        isSystemBoardShow = !isButtonClicked;
    }

    if ( isSystemBoardShow ) {

        [keyboardButton setImage:[UIImage imageNamed:@"001.png"]
                       forState:UIControlStateNormal];
        isSystemBoardShow = NO;
    }
    else {

        [keyboardButton setImage:[UIImage imageNamed:@"board_system"]
                       forState:UIControlStateNormal];
        isSystemBoardShow = YES;
    }

    if ( messageList.count ) {

        [messageListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList.count - 1
                                                                   inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:NO];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {

    NSDictionary *userInfo = [notification userInfo];
    
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    
    [UIView animateWithDuration:animationDuration
                     animations:^{
                         CGRect frame = messageListView.frame;
                         frame.size.height += keyboardHeight;
                         messageListView.frame = frame;
                         
                         frame = toolBar.frame;
                         frame.origin.y += keyboardHeight;
                         toolBar.frame = frame;
                         
                         keyboardHeight = 0;
                     }];
}

- (void)keyboardDidHide:(NSNotification *)notification {

    isKeyboardShowing = NO;

    if ( isButtonClicked ) {

        isButtonClicked = NO;

        if ( ![textView.inputView isEqual:faceBoard] ) {

            isSystemBoardShow = NO;

            textView.inputView = faceBoard;
        }
        else {

            isSystemBoardShow = YES;

            textView.inputView = nil;
        }

        [textView becomeFirstResponder];
    } else {
        self.contactTV.hidden = YES;
    }
}

#pragma mark - ViewController
/** ################################ ViewController ################################ **/

- (IBAction)backPressed:(UIButton *)sender {
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    [appDelegate showHome];
}

- (void)hideDoneBtn:(BOOL)hide
{
    doneBtn.hidden = hide;
    self.contactTV.hidden = hide;
}


- (IBAction)faceBoardClick:(id)sender {

    isButtonClicked = YES;

    if ( isKeyboardShowing ) {

        [textView resignFirstResponder];
    }
    else {

        if ( isFirstShowKeyboard ) {
            
            isFirstShowKeyboard = NO;
            
            isSystemBoardShow = NO;
        }

        if ( !isSystemBoardShow ) {

            textView.inputView = faceBoard;
        }

        [textView becomeFirstResponder];
    }
}

- (IBAction)faceBoardHide:(id)sender {
    BOOL needReload = NO;
    if ( ![textView.text isEqualToString:@""] ) {
        currMsg = textView.text;
        needReload = YES;

        NSMutableArray *messageRange = [[NSMutableArray alloc] init];
        [self getMessageRange:textView.text :messageRange];
        [messageList addObject:messageRange];

//        messageRange = [[NSMutableArray alloc] init];
//        [self getMessageRange:textView.text :messageRange];
//        [messageList addObject:messageRange];
//        [messageRange release];
        
    }
//    UIGraphicsBeginImageContext(msgView.bounds.size);
//    [msgView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    currImg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSLog(@"Image Created");

    textView.text = nil;
    [self textViewDidChange:textView];

    [textView resignFirstResponder];

    isFirstShowKeyboard = YES;

    isButtonClicked = NO;

    textView.inputView = nil;

    [keyboardButton setImage:[UIImage imageNamed:@"001.png"]
                   forState:UIControlStateNormal];

    if ( needReload ) {

        [messageListView reloadData];

        [messageListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList.count - 1
                                                                   inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:NO];
        
        choiceAlert = [[UIAlertView alloc] initWithTitle:@"Choose" message:@"Which App To Use" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Hoodcons",@"iMessage",@"What's App",nil];
        [choiceAlert show];
//        [self sendSMS:currMsg wMsgList:messageList];
    }
    
//    [[UIApplication sharedApplication] openURL: [[NSURL alloc] initWithString:@"sms:"]];
    
}



/**
 * 解析输入的文本
 *
 * 根据文本信息分析出哪些是表情，哪些是文字
 */
- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
	NSRange range = [message rangeOfString:FACE_NAME_HEAD];
    
    //判断当前字符串是否存在表情的转义字符串
    if ( range.length > 0 ) {

        if ( range.location > 0 ) {

            [array addObject:[message substringToIndex:range.location]];

            message = [message substringFromIndex:range.location];

            if ( message.length > FACE_NAME_LEN ) {
                
                [array addObject:[message substringToIndex:FACE_NAME_LEN]];
                
                message = [message substringFromIndex:FACE_NAME_LEN];
                [self getMessageRange:message :array];
            }
            else
            // 排除空字符串
            if ( message.length > 0 ) {
                    
                [array addObject:message];
            }
        }
        else {

            if ( message.length > FACE_NAME_LEN ) {

                [array addObject:[message substringToIndex:FACE_NAME_LEN]];

                message = [message substringFromIndex:FACE_NAME_LEN];
                [self getMessageRange:message :array];
            }
            else
            // 排除空字符串
            if ( message.length > 0 ) {

                [array addObject:message];
            }
        }
    }
    else {
        
        [array addObject:message];
    }
}

/**
 *  获取文本尺寸
 */
- (void)getContentSize:(NSIndexPath *)indexPath {
    NSArray *messageRange = [messageList objectAtIndex:indexPath.row];
    NSValue *sizeValue = [self getContentSizeFrom:messageRange];
    [sizeList setObject:sizeValue forKey:indexPath];
}

- (NSValue *)getContentSizeFrom:(NSArray *)messageRange {

    @synchronized ( self ) {


        CGFloat upX;
        
        CGFloat upY;
        
        CGFloat lastPlusSize;
        
        CGFloat viewWidth;
        
        CGFloat viewHeight;
        
        BOOL isLineReturn;


//        NSArray *messageRange = [messageList objectAtIndex:indexPath.row];
        
        NSDictionary *faceMap = [[NSUserDefaults standardUserDefaults] objectForKey:@"FaceMap"];
        
        UIFont *font = [UIFont systemFontOfSize:16.0f];
        
        isLineReturn = NO;
        
        upX = VIEW_LEFT;
        upY = VIEW_TOP;
        
        for (int index = 0; index < [messageRange count]; index++) {
            
            NSString *str = [messageRange objectAtIndex:index];
            if ( [str hasPrefix:FACE_NAME_HEAD] ) {
                
                //NSString *imageName = [str substringWithRange:NSMakeRange(1, str.length - 2)];
                
                NSArray *imageNames = [faceMap allKeysForObject:str];
                NSString *imageName = nil;
                NSString *imagePath = nil;
 
                if ( imageNames.count > 0 ) {

                    imageName = [imageNames objectAtIndex:0];
                    imagePath = [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"];
                }
                
                if ( imagePath ) {
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KFacialSizeWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    upX += KFacialSizeWidth;
                    
                    lastPlusSize = KFacialSizeWidth;
                }
                else {
                    
                    for ( int index = 0; index < str.length; index++) {
                        
                        NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                        
                        CGSize size = [character sizeWithFont:font
                                            constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                        
                        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                            
                            isLineReturn = YES;
                            
                            upX = VIEW_LEFT;
                            upY += VIEW_LINE_HEIGHT;
                        }
                        
                        upX += size.width;
                        
                        lastPlusSize = size.width;
                    }
                }
            }
            else {
                
                for ( int index = 0; index < str.length; index++) {
                    
                    NSString *character = [str substringWithRange:NSMakeRange( index, 1 )];
                    
                    CGSize size = [character sizeWithFont:font
                                        constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];
                    
                    if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {
                        
                        isLineReturn = YES;
                        
                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }
                    
                    upX += size.width;
                    
                    lastPlusSize = size.width;
                }
            }
        }
        
        if ( isLineReturn ) {
            
            viewWidth = VIEW_WIDTH_MAX + VIEW_LEFT * 2;
        }
        else {
            
            viewWidth = upX + VIEW_LEFT;
        }
        
        viewHeight = upY + VIEW_LINE_HEIGHT + VIEW_TOP;

        NSValue *sizeValue = [NSValue valueWithCGSize:CGSizeMake( viewWidth, viewHeight )];
//        [sizeList setObject:sizeValue forKey:indexPath];
        return sizeValue;
    }
}


#pragma mark - Text View Delegate

/** ################################ UITextViewDelegate ################################ **/

- (BOOL)textViewShouldBeginEditing:(UITextView *)tView
{
    if (tView == textView) {
        NSLog(@"Emoji Text Selected");
    } else {
        NSLog(@"Other Text Selected");
    }
    return YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if( [text length] == 0 ) {
        
        if ( range.length > 1 ) {
            
            return YES;
        }
        else {
            
            [faceBoard backFace];
            
            return NO;
        }
    }
    else {
        
        return YES;
    }
}

- (void)textViewDidChange:(UITextView *)_textView {
    NSString *cMsg;
    
    cMsg = textView.text;
    
    NSMutableArray *messageRange = [[NSMutableArray alloc] init];
    [self getMessageRange:textView.text :messageRange];
    
    NSValue *msgSize = [self getContentSizeFrom:messageRange];
    CGSize size = [msgSize CGSizeValue];
    
//    CGFloat span = size.height - MSG_VIEW_MIN_HEIGHT;
//    CGFloat height = MSG_CELL_MIN_HEIGHT + span;

//    CGSize size = textView.contentSize;
    size.height -= 2;
    if ( size.height >= 88 ) {
        
        size.height = 88;
    }
    else if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
//    if ( size.height != textView.frame.size.height ) {
    if ( size.height != msgView.frame.size.height ) {
        
//        CGFloat span = size.height - textView.frame.size.height;
        CGFloat span = size.height - msgView.frame.size.height;
        
        CGRect frame = toolBar.frame;
        frame.origin.y -= span;
        frame.size.height += span;
        toolBar.frame = frame;
        
        frame = toolBarBkg.frame;
        frame.size.height = toolBar.frame.size.height;
        toolBarBkg.frame = frame;
        
        CGFloat centerY = frame.size.height / 2;
        
//        frame = textView.frame;
//        frame.size = size;
//        textView.frame = frame;
//        
//        CGPoint center = textView.center;
//        center.y = centerY;
//        textView.center = center;
        
        frame = msgView.frame;
        frame.size.height = size.height;
        msgView.frame = frame;
        
        CGPoint center = msgView.center;
        center.y = centerY;
        msgView.center = center;
        
        center = keyboardButton.center;
        center.y = centerY;
        keyboardButton.center = center;
        
        center = sendButton.center;
        center.y = centerY;
        sendButton.center = center;
        
        frame = btmBar.frame;
        frame.origin.y = toolBar.frame.size.height - btmBar.frame.size.height;
        btmBar.frame = frame;
    }
//    [self displayMsgView];
    [msgView showMessage: messageRange];
}

- (void)displayMsgView
{
    NSString *cMsg;
    
    cMsg = textView.text;
    
    NSMutableArray *messageRange = [[NSMutableArray alloc] init];
    [self getMessageRange:textView.text :messageRange];
    
    [msgView showMessage:messageRange];
}

- (void)adjustTableViewFrame:(BOOL)animated {
    CGRect frame = self.contactTV.frame;
    // This places the table view right under the text field
    frame.origin.y = hdrView.frame.origin.y + hdrView.frame.size.height + contactPickerView.frame.size.height;
    // Calculate the remaining distance
    frame.size.height = self.view.frame.size.height - hdrView.frame.size.height - contactPickerView.frame.size.height - kKeyboardHeight;
    
    if(animated) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        [UIView setAnimationDelay:0.1];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        
        self.contactTV.frame = frame;
        
        [UIView commitAnimations];
    }
    else{
        self.contactTV.frame = frame;
    }
}

#pragma mark - UITableViewDataSource
/** ################################ UITableViewDataSource ################################ **/

//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.contactTV) {
        return self.filteredContacts.count;
    }
    return messageList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.contactTV) {
        // Get the desired contact from the filteredContacts array
        THContact *contact = [self.filteredContacts objectAtIndex:indexPath.row];
        
        // Initialize the table view cell
        NSString *cellIdentifier = @"ContactCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
        if (cell == nil){
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        }
        
        // Get the UI elements in the cell;
        UILabel *contactNameLabel = (UILabel *)[cell viewWithTag:101];
        UILabel *mobilePhoneNumberLabel = (UILabel *)[cell viewWithTag:102];
        UIImageView *contactImage = (UIImageView *)[cell viewWithTag:103];
        UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
        
        // Assign values to to US elements
        contactNameLabel.text = [contact fullName];
        mobilePhoneNumberLabel.text = contact.phone;
        if(contact.image) {
            contactImage.image = contact.image;
        }
        contactImage.layer.masksToBounds = YES;
        contactImage.layer.cornerRadius = 20;
        
        // Set the checked state for the contact selection checkbox
        UIImage *image;
        if ([self.selectedContacts containsObject:[self.filteredContacts objectAtIndex:indexPath.row]]){
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
        } else {
            //cell.accessoryType = UITableViewCellAccessoryNone;
            image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
        }
        checkboxImageView.image = image;
        
//        // Assign a UIButton to the accessoryView cell property
//        cell.accessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        // Set a target and selector for the accessoryView UIControlEventTouchUpInside
//        [(UIButton *)cell.accessoryView addTarget:self action:@selector(viewContactDetail:) forControlEvents:UIControlEventTouchUpInside];
//        cell.accessoryView.tag = contact.recordId; //so we know which ABRecord in the IBAction method
        
        // // For custom accessory view button use this.
        //    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
        //    button.frame = CGRectMake(0.0f, 0.0f, 150.0f, 25.0f);
        //
        //    [button setTitle:@"Expand"
        //            forState:UIControlStateNormal];
        //
        //    [button addTarget:self
        //               action:@selector(viewContactDetail:)
        //     forControlEvents:UIControlEventTouchUpInside];
        //
        //    cell.accessoryView = button;
        
        return cell;
    }

    static NSString *CellIdentifier = @"MessageListCell";
    MessageListCell *cell = (MessageListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ( cell == nil ) {
        
        [self.cellNib instantiateWithOwner:self options:nil];
		cell = tmpCell;
		self.tmpCell = nil;
    }

    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [cell setBackgroundColor:[UIColor clearColor]];

    NSMutableArray *message = [messageList objectAtIndex:indexPath.row];
    NSValue *sizeValue = [sizeList objectForKey:indexPath];
    CGSize size = [sizeValue CGSizeValue];

//    if ( indexPath.row % 2 == 0 ) {
//
//        [cell refreshForOwnMsg:message withSize:size];
//    }
//    else {
//
//        [cell refreshForFrdMsg:message withSize:size];
//    }
    
    [cell refreshForOwnMsg:message withSize:size];
    
    return cell;
}

/** ################################ UITableViewDelegate ################################ **/

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.contactTV) {
        return 70;
    }

    NSValue *sizeValue = (NSValue *)[sizeList objectForKey:indexPath];
    if ( !sizeValue ) {

        [self getContentSize:indexPath];
        sizeValue = (NSValue *)[sizeList objectForKey:indexPath];
    }

    CGSize size = [sizeValue CGSizeValue];
    
    CGFloat span = size.height - MSG_VIEW_MIN_HEIGHT;
    CGFloat height = MSG_CELL_MIN_HEIGHT + span;

    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.contactTV) {
        // Hide Keyboard
        [contactPickerView resignKeyboard];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        // This uses the custom cellView
        // Set the custom imageView
        THContact *user = [self.filteredContacts objectAtIndex:indexPath.row];
        UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
        UIImage *image;
        
        if ([self.selectedContacts containsObject:user]){ // contact is already selected so remove it from ContactPickerView
            //cell.accessoryType = UITableViewCellAccessoryNone;
            [self.selectedContacts removeObject:user];
            [contactPickerView removeContact:user];
            // Set checkbox to "unselected"
            image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
        } else {
            // Contact has not been selected, add it to THContactPickerView
            //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            [self.selectedContacts addObject:user];
            [contactPickerView addContact:user withName:user.fullName];
            // Set checkbox to "selected"
            image = [UIImage imageNamed:@"icon-checkbox-selected-green-25x25"];
        }
        
        // Enable Done button if total selected contacts > 0
        if(self.selectedContacts.count > 0) {
            barButton.enabled = TRUE;
        }
        else
        {
            barButton.enabled = FALSE;
        }
        
        // Update window title
        self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
        
        // Set checkbox image
        checkboxImageView.image = image;
        // Reset the filtered contacts
        self.filteredContacts = self.contacts;
        // Refresh the tableview
        [self.contactTV reloadData];
    }
}

/** ################################  ################################ **/

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {
    
    [super viewDidUnload];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];



}


#pragma mark - Chat View Controller

- (void)openChatView
{
//    MessagesViewController *vc = [[MessagesViewController alloc] initWithNibName:nil bundle:nil];
    //        vc.delegate = self;
    ChatViewController *vc = [[ChatViewController alloc] initWithNibName:nil bundle:nil];
    vc.sendMsg = [messageList objectAtIndexedSubscript:messageList.count-1];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)sendSMS:(NSString *)message wMsgList:(NSArray *)msgList {
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Device Doesn't Support SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
        return;
    }
    NSString *sendMsg = @"";
    NSString *firstImgName = nil;
    NSArray *currMsgList = [msgList objectAtIndexedSubscript:msgList.count-1];
    for (NSString *msg in currMsgList) {
        NSLog(@"%@", msg);
        if ([msg rangeOfString:@"/s"].location == NSNotFound) {
            sendMsg = [NSString stringWithFormat:@"%@%@",sendMsg,msg];
        } else {
            if (!firstImgName) {
                NSString *imgNumStr = [msg stringByReplacingOccurrencesOfString:@"/s" withString:@""];
                firstImgName = [NSString stringWithFormat:@"%@.png", imgNumStr];
                NSLog(@"%@", firstImgName);
            }
        }
    }
    UIImage *lastImg = nil;
    NSIndexPath *lastIP = [NSIndexPath indexPathForRow:msgList.count-1 inSection:0];
    MessageListCell *lastCell = (MessageListCell *)[messageListView cellForRowAtIndexPath:lastIP];
    
    if (lastCell) {
        UIGraphicsBeginImageContext(lastCell.messageView.bounds.size);
        [lastCell.messageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        lastImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        NSLog(@"Image Created");
    }
    
//    UIGraphicsBeginImageContext(msgView.bounds.size);
//    [msgView.layer renderInContext:UIGraphicsGetCurrentContext()];
//    lastImg = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    NSLog(@"Image Created");
    
    
    NSArray *recipients = @[];
    if (self.selectedContacts.count > 0) {
        NSMutableArray *mutableContacts = [NSMutableArray arrayWithCapacity:self.selectedContacts.count];
        for (THContact* contact in self.selectedContacts)
        {
            [mutableContacts addObject:contact.phone];
        }
        recipients = [NSArray arrayWithArray:mutableContacts];
    }
    
    MFMessageComposeViewController *messageController = [[MFMessageComposeViewController alloc] init];
    messageController.messageComposeDelegate = self;
    [messageController setRecipients:recipients];
//    if (!lastImg) {
//        [messageController setBody:sendMsg];
//    } else {
//        [messageController setBody:@"\b\b"];
//    }
    
    if (firstImgName || lastImg) {
        NSData *attach = nil;
        if (lastImg) {
            attach = UIImageJPEGRepresentation(lastImg, 0.5);
        } else {
            attach = UIImageJPEGRepresentation([UIImage imageNamed:firstImgName], 0.5);
        }
        NSString* uti = (NSString *)kUTTypeMessage;
        [messageController addAttachmentData:attach typeIdentifier:uti filename:@"filename.jpg"];
    }
    [self presentViewController:messageController animated:YES completion:nil];
    if (!lastImg) {
        [messageController setBody:sendMsg];
    } else {
        [messageController setBody:@""];
    }
    lastImg = nil;
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    switch (result) {
        case MessageComposeResultCancelled:
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed To Send SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [failAlert show];
            break;
        }
            
        case MessageComposeResultSent:
            break;
            
        default:
            break;
    }
    [self removeAllContacts:nil];
    [self getContacts];
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - THContactPickerTextViewDelegate

- (void)contactPickerTextViewDidChange:(NSString *)textViewText {
    [self hideDoneBtn:NO];
    if ([textViewText isEqualToString:@""]){
        self.filteredContacts = self.contacts;
//        self.contactTV.hidden = YES;
    } else {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self.%@ contains[cd] %@ OR self.%@ contains[cd] %@ OR self.%@ contains[cd] %@", @"firstName", textViewText, @"lastName", textViewText, @"phone", textViewText];
        self.filteredContacts = [self.contacts filteredArrayUsingPredicate:predicate];
//        NSMutableArray *fContacts = [[NSMutableArray alloc] init];
//        for (THContact *contact in self.filteredContacts) {
//            if (![self.selectedContacts containsObject:contact]) {
//                [fContacts addObject:contact];
//            }
//        }
//        self.filteredContacts = fContacts;
//        if (self.filteredContacts.count > 0) {
//            self.contactTV.hidden = NO;
//        } else {
//            self.contactTV.hidden = YES;
//        }
        self.contactTV.hidden = NO;
    }
    [self.contactTV reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
//    if (self.contactTV.hidden) {
//        self.contactTV.hidden = NO;
//    }
    [self adjustTableViewFrame:YES];
    
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
//    if (self.contactTV.hidden) {
//        self.contactTV.hidden = NO;
//    }
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.contactTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Enable Done button if total selected contacts > 0
    if(self.selectedContacts.count > 0) {
        barButton.enabled = TRUE;
    }
    else
    {
        barButton.enabled = FALSE;
    }
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    checkboxImageView.image = image;
    
    // Update window title
    self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
}

- (void)contactPickerShouldHideDoneButton:(BOOL)hide
{
    [self hideDoneBtn:hide];
}

- (void)removeAllContacts:(id)sender
{
    [contactPickerView removeAllContacts];
    [self.selectedContacts removeAllObjects];
    self.filteredContacts = self.contacts;
    [self.contactTV reloadData];
}


#pragma mark ABPersonViewControllerDelegate

- (BOOL)personViewController:(ABPersonViewController *)personViewController shouldPerformDefaultActionForPerson:(ABRecordRef)person property:(ABPropertyID)property identifier:(ABMultiValueIdentifier)identifier
{
    return YES;
}


// This opens the apple contact details view: ABPersonViewController
//TODO: make a THContactPickerDetailViewController
- (IBAction)viewContactDetail:(UIButton*)sender {
    ABRecordID personId = (ABRecordID)sender.tag;
    ABPersonViewController *view = [[ABPersonViewController alloc] init];
    view.addressBook = self.addressBookRef;
    view.personViewDelegate = self;
    view.displayedPerson = ABAddressBookGetPersonWithRecordID(self.addressBookRef, personId);
    
    
    [self.navigationController pushViewController:view animated:YES];
}

// TODO: send contact object
- (void)done:(id)sender
{
    self.contactTV.hidden = YES;
    [contactPickerView resignKeyboard];
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Done!"
//                                                        message:@"Now do whatevet you want!"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"Ok"
//                                              otherButtonTitles:nil];
//    [alertView show];
}

#pragma mark - Parse messaging

- (void)sendMessage:(NSArray *)msgArray
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_ROOMID] = roomId;
//    object[PF_CHAT_TEXT] = text;
    NSString *jsonString = ArrayToJSONString(msgArray);
    object[PF_CHAT_TEXT] = jsonString;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
//             [JSQSystemSoundPlayer jsq_playMessageSentSound];
//             [self loadMessages];
             [messageListView reloadData];
         }
//         else [ProgressHUD showError:@"Network error."];;
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    SendPushNotification(roomId, jsonString);
    UpdateMessageCounter(roomId, jsonString);
    //---------------------------------------------------------------------------------------------------------------------------------------------
//    [self finishSendingMessage];
}


#pragma mark - Alert View

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView == choiceAlert) {
        NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
        NSLog(@"%@ picked", btnTitle);
        if ([btnTitle isEqualToString:@"iMessage"]) {
            [self sendSMS:currMsg wMsgList:messageList];
        } else if ([btnTitle isEqualToString:@"Hoodcons"]) {
//            UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Success" message:@"Should Go To In App Messaging" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [aView show];
            [self openChatView];
        } else if ([btnTitle isEqualToString:@"What's App"]) {
            UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"What's App is not available yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [aView show];
        }
    } else {
        NSLog(@"It was not choice alert");
    }
    
}


@end
