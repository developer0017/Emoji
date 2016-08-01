//
//  ChatViewController.m
//  Hoodcons
//
//  Created by Jeremiah McAllister on 12/2/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//


#import "ProgressHUD.h"

#import "AppConstant.h"
#import "AppDelegate.h"
#import "camera.h"
#import "messages.h"

#import "utilities.h"

#import "ChatViewController.h"
#import <AddressBook/AddressBook.h>
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "SMSViewController.h"
#import "MessagesViewController.h"
#import "THContact.h"

#import "JSQMessagesViewController.h"

#import "JSQMessagesKeyboardController.h"

#import "JSQMessagesCollectionViewFlowLayoutInvalidationContext.h"

#import "JSQMessageData.h"
#import "JSQMessageBubbleImageDataSource.h"
#import "JSQMessageAvatarImageDataSource.h"

#import "JSQMessagesCollectionViewCellIncoming.h"
#import "JSQMessagesCollectionViewCellOutgoing.h"

#import "JSQMessagesTypingIndicatorFooterView.h"
#import "JSQMessagesLoadEarlierHeaderView.h"

#import "JSQMessagesToolbarContentView.h"
#import "JSQMessagesInputToolbar.h"
#import "JSQMessagesComposerTextView.h"

#import "JSQMessagesTimestampFormatter.h"

#import "NSString+JSQMessages.h"
#import "UIColor+JSQMessages.h"
#import "UIDevice+JSQMessages.h"
#import "StoreViewController.h"

static void * kJSQMessagesKeyValueObservingContext = &kJSQMessagesKeyValueObservingContext;

@interface ChatViewController () <MFMessageComposeViewControllerDelegate, UIAlertViewDelegate>
{
    NSTimer *timer;
    BOOL isLoading;
    BOOL byPhone;
    BOOL userChecked;
    
    
    NSString *currMsg;
    NSArray *currMessageRange;
    UIAlertView *choiceAlert;
    UIAlertView *pushAlert;
    UIAlertView *pushAlertWRoom;
    
    NSString *roomId;
    NSString *newRoomID;
    BOOL hoodconsSession;
    
    NSMutableArray *users;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
    
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;
    
    JSQMessagesAvatarImage *placeholderImageData;
}

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, assign) NSString *myPhoneNum;
@property (nonatomic, assign) NSString *myInstallID;

@property (weak, nonatomic) IBOutlet JSQMessagesCollectionView *collectionView;

@property (weak, nonatomic) UIView *snapshotView;

@property (strong, nonatomic) JSQMessagesKeyboardController *keyboardController;

@property (assign, nonatomic) BOOL jsq_isObserving;

@property (strong, nonatomic) NSIndexPath *selectedIndexPathForMenu;

- (void)jsq_configureMessagesViewController;

- (NSString *)jsq_currentlyComposedMessageText;

- (void)jsq_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification;
- (void)jsq_didReceiveMenuWillShowNotification:(NSNotification *)notification;
- (void)jsq_didReceiveMenuWillHideNotification:(NSNotification *)notification;

- (void)jsq_updateKeyboardTriggerPoint;
- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant;

- (void)jsq_handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer;

- (BOOL)jsq_inputToolbarHasReachedMaximumHeight;
- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy;
- (void)jsq_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy;
- (void)jsq_scrollComposerTextViewToBottomAnimated:(BOOL)animated;

- (void)jsq_updateCollectionViewInsets;
- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom;

- (BOOL)jsq_isMenuVisible;

- (void)jsq_addObservers;
- (void)jsq_removeObservers;

- (void)jsq_registerForNotifications:(BOOL)registerForNotifications;

- (void)jsq_addActionToInteractivePopGestureRecognizer:(BOOL)addAction;

@end

#define kKeyboardHeight 216.0
//#define kKeyboardHeight 0.0

@implementation ChatViewController

@synthesize sendMsg;
@synthesize tmpCell, cellNib;
@synthesize backImg;
@synthesize tmpMsgView;
@synthesize lessThan7;
@synthesize myPhoneNum;
@synthesize myInstallID;
@synthesize numToContactsDict, contactNumKeys;


#pragma mark - View lifecycle

- (id)initWith:(NSString *)roomId_
{
    self = [super init];
    roomId = roomId_;
    return self;
}

-(void)setNewRoomID:(NSString *)newRoomId
{
    newRoomID = newRoomId;
}

-(NSString *)getRoomID
{
    return roomId;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    line_number_count = 0;
    [toolBar setHidden:NO];
    // Do any additional setup after loading the view from its nib.
    if (sendMsg) {
        NSLog(@"Message To Send: %@", sendMsg);
        NSString *jsonStr = ArrayToJSONString(sendMsg);
        NSLog(@"JSON To Send: %@", jsonStr);
    }
   
    
//    [[[self class] nib] instantiateWithOwner:self options:nil];
    
    [self jsq_configureMessagesViewController];
    [self jsq_registerForNotifications:YES];
    
    users = [[NSMutableArray alloc] init];
    messages = [[NSMutableArray alloc] init];
    avatars = [[NSMutableDictionary alloc] init];
    
    myPhoneNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"phoneNumber"];
    myInstallID = [[NSUserDefaults standardUserDefaults] objectForKey:@"installID"];
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    
    placeholderImageData = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"blank_avatar"] diameter:30.0];
    
    [self hoodconsSetup];
    
    isLoading = NO;
    if (roomId) {
        [self loadMessages];
        
        ClearMessageCounter(roomId);
    }
    
    [self.view layoutIfNeeded];
    
    NSLog(@"View Will Appear");
    
    [faceBoard categoryload];
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
    
    CGRect frame = self.collectionView.frame;
    //    frame.size.height = self.view.frame.size.height - 64;
    frame.size.height = self.view.frame.size.height - toolBar.frame.size.height - hdrView.frame.size.height - contactPickerView.frame.size.height - iOSadj;
    frame.origin.y = hdrView.frame.size.height + contactPickerView.frame.size.height;
    self.collectionView.frame = frame;
    
    [self.collectionView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.25]];
    
    frame = toolBar.frame;
    
    frame.origin.y = self.view.frame.size.height - frame.size.height - iOSadj;
    toolBar.frame = frame;
    
    [self getContacts];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self refreshContacts];
    });
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    
    if (self.automaticallyScrollsToMostRecentMessage) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self scrollToBottomAnimated:NO];
            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
        });
    }

    
    
    [self jsq_addObservers];
    [self jsq_addActionToInteractivePopGestureRecognizer:YES];
    [self.keyboardController beginListeningForKeyboard];
    
    
    
    if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
        [self.snapshotView removeFromSuperview];
    }
    
    //    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    
    if (newRoomID) {
        [self updateRoomWithNewID];
    }

    
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear:animated];
//    [self.view layoutIfNeeded];
//    
//    NSLog(@"View Will Appear");
//    
//    [faceBoard categoryload];
//    if (iPhone5) {
//        
//        self.view.frame = CGRectMake(0, 0, 320, 568);
//        self.backImg.frame = CGRectMake(0, 0, 320, 568);
//    }
//    else{
//        
//        self.view.frame = CGRectMake(0, 0, 320, 480);
//        self.backImg.frame = CGRectMake(0, 0, 320, 480);
//    }
//    int iOSadj = 0;
//    if (lessThan7) {
//        iOSadj += 20;
//    }
//    
//    CGRect frame = self.collectionView.frame;
//    //    frame.size.height = self.view.frame.size.height - 64;
//    frame.size.height = self.view.frame.size.height - toolBar.frame.size.height - hdrView.frame.size.height - contactPickerView.frame.size.height - iOSadj;
//    frame.origin.y = hdrView.frame.size.height + contactPickerView.frame.size.height;
//    self.collectionView.frame = frame;
//
//    [self.collectionView setBackgroundColor:[UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.25]];
//    
//    frame = toolBar.frame;
//   
//    frame.origin.y = self.view.frame.size.height - frame.size.height - iOSadj;
//    toolBar.frame = frame;
//    
//    [self getContacts];
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self refreshContacts];
//    });
//
//    [self.collectionView.collectionViewLayout invalidateLayout];
//    
//    if (self.automaticallyScrollsToMostRecentMessage) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self scrollToBottomAnimated:NO];
//            [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
//        });
//    }
//    
////    [self jsq_updateKeyboardTriggerPoint];
//}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
//    
//    
//    [self jsq_addObservers];
//    [self jsq_addActionToInteractivePopGestureRecognizer:YES];
//    [self.keyboardController beginListeningForKeyboard];
//    
//    if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
//        [self.snapshotView removeFromSuperview];
//    }
//    
////    timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
//    self.collectionView.collectionViewLayout.springinessEnabled = YES;
//    
//    if (newRoomID) {
//        [self updateRoomWithNewID];
//    }
//}

- (void)viewWillDisappear:(BOOL)animated
{
//    [super viewWillDisappear:animated];
//    [self jsq_addActionToInteractivePopGestureRecognizer:NO];
//    self.collectionView.collectionViewLayout.springinessEnabled = NO;
//    roomId = nil;
//    [contactPickerView removeAllContacts];
}

- (void)viewDidDisappear:(BOOL)animated
{
//    [super viewDidDisappear:animated];
//    [self jsq_removeObservers];
//    [self.keyboardController endListeningForKeyboard];
////    [self jsq_setToolbarBottomLayoutGuideConstant:0.0f];
//    
//    [timer invalidate];
}

//- (void)viewDidLayoutSubviews {
//    [super viewDidLayoutSubviews];
//    CGFloat topOffset = hdrView.frame.size.height;
//    //    if ([self respondsToSelector:@selector(topLayoutGuide)]){
//    //        topOffset += self.topLayoutGuide.length;
//    //    }
//    CGRect frame = contactPickerView.frame;
//    frame.origin.y = topOffset;
//    contactPickerView.frame = frame;
//    [self adjustTableViewFrame:NO];
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"MEMORY WARNING: %s", __PRETTY_FUNCTION__);
}

- (void)handleTapGesture {
    NSLog(@"MsgView tapped");
    // Show textField
    //    textView.hidden = NO;
    [txtView becomeFirstResponder];
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
    
    [self jsq_registerForNotifications:NO];
    [self jsq_removeObservers];
    
    _collectionView.dataSource = nil;
    _collectionView.delegate = nil;
    _collectionView = nil;
    _inputToolbar = nil;
    
    //    _toolbarHeightConstraint = nil;
    //    _toolbarBottomLayoutGuide = nil;
    
    _senderId = nil;
    _senderDisplayName = nil;
    _outgoingCellIdentifier = nil;
    _incomingCellIdentifier = nil;
    
    [_keyboardController endListeningForKeyboard];
    _keyboardController = nil;
}

- (void)gotostorecontroller
{
    StoreViewController *svc = [[StoreViewController alloc] initWithNibName:nil bundle:nil];
    [self presentViewController:svc animated:YES completion:nil];

}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

#pragma mark - Set up methods


- (void)hoodconsSetup
{
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
        faceBoard.inputTextView = txtView;
    }
    
    if ( !messageList ) {
        
        messageList = [[NSMutableArray alloc] init];
    }
    else
        [messageList removeAllObjects];
    
    if ( !sizeList ) {
        
        sizeList = [[NSMutableDictionary alloc] init];
    }
    else
        [sizeList removeAllObjects];
    
    self.cellNib = [UINib nibWithNibName:@"MessageListCell" bundle:nil];
    
    //textView.contentInset = UIEdgeInsetsMake(6.0f, 6.0f, 6.0f, 6.0f);
    [txtView.layer setCornerRadius:6];
    [txtView.layer setMasksToBounds:YES];
    txtView.layer.borderColor = [[UIColor whiteColor] CGColor];
    txtView.layer.borderWidth = 1.0f;
    
    [msgView.layer setCornerRadius:6];
    [msgView.layer setMasksToBounds:YES];
    msgView.layer.borderColor = [[UIColor whiteColor] CGColor];
    msgView.layer.borderWidth = 1.0f;
    
    contactPickerView.delegate = self;
    [contactPickerView setPlaceholderString:@"To:"];
    [contactPickerView setBackgroundColor:[UIColor clearColor]];
    
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
    
    [self getContacts];
    
    [doneBtn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    [self hideDoneBtn:YES];
    
//    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
//    tapGesture.numberOfTapsRequired = 1;
//    tapGesture.numberOfTouchesRequired = 1;
//    [msgView addGestureRecognizer:tapGesture];
    
    isFirstShowKeyboard = YES;
    hoodconsSession = NO;
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    byPhone = appDelegate.byPhone;
    userChecked = NO;
    //    myPhoneNum = nil;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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

-(void)checkForPhone
{
    if (!myPhoneNum || [myPhoneNum isEqualToString:@""]) {
        SMSViewController *vc = [[SMSViewController alloc] initWithNibName:nil bundle:nil];
//        vc.delegate = self;
        vc.chatDelegate = self;
        [self presentViewController:vc animated:YES completion:nil];
        userChecked = YES;
    }
}


-(void)getContactsFromAddressBook
{
    CFErrorRef error = NULL;
    self.contacts = [[NSMutableArray alloc]init];
      
    ABAddressBookRef addressBook = ABAddressBookCreateWithOptions(NULL, &error);
    if (addressBook) {
        NSArray *allContacts = (__bridge_transfer NSArray*)ABAddressBookCopyArrayOfAllPeople(addressBook);
        numToContactsDict = [[NSMutableDictionary alloc] init];
        NSString *phoneDigs;
        
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
                phoneDigs = [[contact.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
                [numToContactsDict setObject:contact forKey:phoneDigs];
            }
        }
           if(addressBook) {
               CFRelease(addressBook);
           }
        
           [self.contactTV reloadData];
        
    }
}

- (void) refreshContacts
{
    for (THContact* contact in self.contacts)
    {
        [self refreshContact: contact];
    }
    [self.contactTV reloadData];
    [self updateAppDelContacts];
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

- (void)updateAppDelContacts
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.contacts = self.contacts;
//    appDelegate.selectedContacts = self.selectedContacts;
//    appDelegate.filteredContacts = self.filteredContacts;
    appDelegate.numToContactsDict = self.numToContactsDict;
    appDelegate.contactNumKeys = self.contactNumKeys;
}


#pragma mark - ViewController
/** ################################ ViewController ################################ **/

- (IBAction)backPressed:(UIButton *)sender {
//    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    [appDelegate showHome];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)hideDoneBtn:(BOOL)hide
{
    doneBtn.hidden = hide;
    self.contactTV.hidden = hide;
}


- (IBAction)faceBoardClick:(id)sender {
    
    isButtonClicked = YES;
    
    if ( isKeyboardShowing ) {
        
        [txtView resignFirstResponder];
    }
    else {
        
        if ( isFirstShowKeyboard ) {
            
            isFirstShowKeyboard = NO;
            
            isSystemBoardShow = NO;
        }
        
        if ( !isSystemBoardShow ) {
            
            txtView.inputView = faceBoard;
        }
        
        [txtView becomeFirstResponder];
    }
}

- (IBAction)faceBoardHide:(id)sender {
    BOOL needReload = NO;
    if ( ![txtView.text isEqualToString:@""] ) {
        currMsg = txtView.text;
        needReload = YES;
        
        NSMutableArray *messageRange = [[NSMutableArray alloc] init];
        [self getMessageRange:txtView.text :messageRange];
//        [messageList addObject:messageRange];
        
        currMessageRange = [NSArray arrayWithArray:messageRange];
        NSArray *sendArr;
        if (myPhoneNum) {
            sendArr = [NSArray arrayWithObjects:myPhoneNum, currMessageRange, nil];
        } else {
            sendArr = [NSArray arrayWithObjects:@"NONUMREG", currMessageRange, nil];
        }
        [messageList addObject:sendArr];
    }
    
    
    [txtView resignFirstResponder];
    
    isFirstShowKeyboard = YES;
    
    isButtonClicked = NO;
    
//    txtView.inputView = nil;
    
    [keyboardButton setImage:[UIImage imageNamed:@"001.png"]
                    forState:UIControlStateNormal];
    
    if ( needReload ) {
        [messageListView reloadData];
        
        if (messageList.count > 0 ) {
            [messageListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList.count - 1
                                                                       inSection:0]
                                   atScrollPosition:UITableViewScrollPositionBottom
                                           animated:NO];
        }
        
        if (hoodconsSession) {
            [self sendCurrMessage];
        } else {
             [self sendSMS:currMsg wMsgList:messageList];

        }
    }
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
        
        if ( ![txtView.inputView isEqual:faceBoard] ) {
            
            isSystemBoardShow = NO;
            
            txtView.inputView = faceBoard;
        }
        else {
            
            isSystemBoardShow = YES;
            
            txtView.inputView = nil;
        }
        
        [txtView becomeFirstResponder];
    } else {
        self.contactTV.hidden = YES;
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
    
    NSString *userNum = nil;
    NSMutableArray *message = [[NSMutableArray alloc] init];
    NSArray *msgArray = [messageList objectAtIndex:indexPath.row];
    if (msgArray.count > 1) {
        message = msgArray[1];
        userNum = msgArray[0];
    } else if (msgArray.count > 0) {
        message = msgArray[0];
    }
    
    NSValue *sizeValue = [sizeList objectForKey:indexPath];
    CGSize size = [sizeValue CGSizeValue];
    
    if ([userNum isEqualToString:myPhoneNum] || [userNum isEqualToString:@"NONUMREG"]) {
        [cell refreshForOwnMsg:message withSize:size];
    } else {
        NSString *userName = nil;
        if (userNum) {
            THContact *contact = [numToContactsDict objectForKey:userNum];
            if (contact) {
                userName = contact.fullName;
            }
        }
        if (userName) {
            [cell refreshForFrdMsg:message withName:userName withSize:size];
        } else {
            [cell refreshForFrdMsg:message withSize:size];
        }
    }
    
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
        
        // Update window title
        self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
        
        // Set checkbox image
        checkboxImageView.image = image;
        // Reset the filtered contacts
        self.filteredContacts = self.contacts;
        // Refresh the tableview
        [self updateRoomID];
        [self.contactTV reloadData];
    }
}

#pragma mark - MFMessageComposeViewControllerDelegate

- (void)sendSMS:(NSString *)message wMsgList:(NSArray *)msgList {
    if (![MFMessageComposeViewController canSendText]) {
        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Your Device Doesn't Support SMS" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [errorAlert show];
        return;
    }
    
    UIImage *lastImg = nil;
    NSInteger lastRow = msgList.count - 1;

    NSIndexPath *lastIdx = [NSIndexPath indexPathForRow:lastRow inSection:0];
    MessageListCell *lastCell = (MessageListCell *)[messageListView cellForRowAtIndexPath:lastIdx];
    
    
    if (lastCell) {

//        UIGraphicsBeginImageContext(lastCell.messageView.bounds.size);
        if(line_number_count <= 3)
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(260, 140), NO, 0.0);
        else if(line_number_count >3)
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(260, lastCell.bounds.size.height), NO, 0.0);
        [lastCell.messageView.layer renderInContext:UIGraphicsGetCurrentContext()];
        lastImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
//        UIImageWriteToSavedPhotosAlbum(lastImg, self, nil, nil);
    }
    NSLog(@"height%f",lastCell.bounds.size.height);
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
    if (lastImg) {
        
        NSData *attach = nil;
        
        attach = UIImagePNGRepresentation(lastImg);
    
        NSString* uti = (NSString *)kUTTypeData;
        
        [messageController addAttachmentData:attach typeIdentifier:uti filename:@"file.png"];
    }
    [toolBar setHidden:YES];
    [self presentViewController:messageController animated:YES completion:nil];
    if (!lastImg) {
        [messageController setBody:message];
    } else {
        [messageController setBody:@""];
    }
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
            txtView.text = nil;
            [self textViewDidChange:txtView];
            txtView.inputView = nil;
            break;
        }
            
        case MessageComposeResultSent:
            txtView.text = nil;
            [self textViewDidChange:txtView];
            txtView.inputView = nil;
            break;
            
        default:
            txtView.text = nil;
            [self textViewDidChange:txtView];
            txtView.inputView = nil;
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
        self.contactTV.hidden = NO;
    }
    [self updateRoomID];
    [self.contactTV reloadData];
}

- (void)contactPickerDidResize:(THContactPickerView *)contactPickerView {
    //    if (self.contactTV.hidden) {
    //        self.contactTV.hidden = NO;
    //    }
    [self adjustTableViewFrame:YES];
    [self updateRoomID];
}

- (void)contactPickerDidRemoveContact:(id)contact {
    [self.selectedContacts removeObject:contact];
    //    if (self.contactTV.hidden) {
    //        self.contactTV.hidden = NO;
    //    }
    
    NSUInteger index = [self.contacts indexOfObject:contact];
    UITableViewCell *cell = [self.contactTV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    //cell.accessoryType = UITableViewCellAccessoryNone;
    
    // Set unchecked image
    UIImageView *checkboxImageView = (UIImageView *)[cell viewWithTag:104];
    UIImage *image;
    image = [UIImage imageNamed:@"icon-checkbox-unselected-25x25"];
    checkboxImageView.image = image;
    
    // Update window title
    self.title = [NSString stringWithFormat:@"Add Members (%lu)", (unsigned long)self.selectedContacts.count];
    [self updateRoomID];
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
    [self updateRoomID];
    [self.contactTV reloadData];
}

- (void)updateRoomID
{
    NSString *phoneDigs;
    NSString *oldRoomID = [NSString stringWithFormat:@"%@", roomId];
    NSMutableArray *currIDs = [[NSMutableArray alloc] init];
    if (self.selectedContacts.count > 0) {
//        NSArray *allParseKeys = [parseUserNumDict allKeys];
        for (THContact* contact in self.selectedContacts)
        {
            phoneDigs = [[contact.phone componentsSeparatedByCharactersInSet:[[NSCharacterSet decimalDigitCharacterSet] invertedSet]] componentsJoinedByString:@""];
            [currIDs addObject:phoneDigs];
//            if ([allParseKeys containsObject:phoneDigs]) {
//                PFUser *user = [parseUserNumDict objectForKey:phoneDigs];
//                if (user[@"installID"]) {
//                    [currIDs addObject:user[@"installID"]];
//                }
//            }
        }
        if (currIDs.count > 0) {
            if (![currIDs containsObject:myPhoneNum]) {
                [currIDs addObject:myPhoneNum];
            }
        }
    }
    if (currIDs.count > 0) {
        [currIDs sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
        roomId = [currIDs componentsJoinedByString:@"_"];
    } else {
        roomId = nil;
    }
    if (![roomId isEqualToString:oldRoomID]) {
        hoodconsSession = NO;
    }
    
    NSLog(@"Room ID is now: %@", roomId);
    [messageList removeAllObjects];
    [messageListView reloadData];
    [messages removeAllObjects];
    [self loadMessages];
}

- (void)updateRoomWithNewID
{
    roomId = newRoomID;
    NSLog(@"Room ID is now: %@", roomId);
    NSArray *numList = [roomId componentsSeparatedByString:@"_"];
    NSMutableArray *contactList = [[NSMutableArray alloc] init];
    for (NSString *phoneNum in numList) {
        if (![phoneNum isEqualToString:myPhoneNum]   && [contactNumKeys containsObject:phoneNum]) {
            THContact *contact = [numToContactsDict objectForKey:phoneNum];
            [contactList addObject:contact];
            [contactPickerView addContact:contact withName:contact.fullName];
        }
    }
    self.selectedContacts = contactList;
    [self.contactTV reloadData];
    
    [messageList removeAllObjects];
    [messageListView reloadData];
    [messages removeAllObjects];
    newRoomID = nil;
    [self loadMessages];
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
}


#pragma mark - Backend methods

- (void)loadPush:(NSDictionary *)userInfo;
{
    NSDictionary *aps = userInfo[@"aps"];
    NSString *jsonString = aps[@"alert"];
    NSString *phoneNum = nil;
    NSString *pUserName = nil;
    newRoomID = nil;
    
    NSArray *msgArray = JSONStringToArray(jsonString);
    NSInteger entryCnt = msgArray.count;
    NSString *alertMsg;
    if (entryCnt == 3) {
        newRoomID = msgArray[0];
        phoneNum = msgArray[1];
    } else if (entryCnt == 2) {
        phoneNum = msgArray[0];
    }
    
    if (phoneNum) {
        pUserName = phoneNum;
        if ([contactNumKeys containsObject:phoneNum]) {
            THContact *contact = [numToContactsDict objectForKey:phoneNum];
            if (contact) {
                pUserName = contact.fullName;
            }
        }
    } else {
        pUserName = @"Hoodcons User";
    }
    if (newRoomID) {
        alertMsg = [NSString stringWithFormat:@"Message received from %@\nWould you like to view it", pUserName];
        pushAlertWRoom = [[UIAlertView alloc] initWithTitle:@"Incoming" message:alertMsg delegate:self cancelButtonTitle:@"NO" otherButtonTitles: @"YES", nil];
        [pushAlertWRoom show];
    } else {
        alertMsg = [NSString stringWithFormat:@"Message received from %@", pUserName];
        pushAlert = [[UIAlertView alloc] initWithTitle:@"Incoming" message:alertMsg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [pushAlert show];
    }

}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)loadMessages
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (isLoading == NO)
    {
        if (roomId) {
            isLoading = YES;
            JSQMessage *message_last = [messages lastObject];
            
            PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
            [query whereKey:PF_CHAT_ROOMID equalTo:roomId];
            if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
//            [query includeKey:PF_CHAT_USER];
            [query orderByDescending:PF_CHAT_CREATEDAT];
            [query setLimit:50];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
             {
                 if (error == nil)
                 {
                     NSLog(@"%lu messages received", (unsigned long)objects.count);
                     for (PFObject *object in [objects reverseObjectEnumerator])
                     {
                         [self addMessage:object];
                     }
                     isLoading = NO;
                     if ([objects count] != 0 || messages.count == 0) [self finishReceivingMessage];
                 }
                 else [ProgressHUD showError:@"Network error."];
                 isLoading = NO;
             }];
        } else {
            [self finishReceivingMessage];
            isLoading = NO;
        }
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)addMessage:(PFObject *)object
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
//    PFUser *me = [PFUser currentUser];
    PFUser *user = object[PF_CHAT_USER];
    [users addObject:user];
    PFQuery *query = [PFUser query];
    PFUser *fullUser = (PFUser *)[query getObjectWithId:user.objectId];

    NSString *displayName = @"Hoodcons User";
    if ([fullUser.username isEqualToString:myPhoneNum]) {
        displayName = @"Me";
    } else {
        if ([contactNumKeys containsObject:fullUser.username]) {
            THContact *contact = [numToContactsDict objectForKey:fullUser.username];
            displayName = [contact fullName];
        }
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (object[PF_CHAT_PICTURE] == nil)
    {
        NSString *pRoomID = nil;
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:displayName date:object.createdAt text:object[PF_CHAT_TEXT]];
        [messages addObject:message];
        
        NSMutableArray *msgArray = [NSMutableArray arrayWithArray: JSONStringToArray(object[PF_CHAT_TEXT])];
        NSLog(@"%lu items in array",(unsigned long)msgArray.count);
        if (msgArray.count >= 3) {
            pRoomID = [msgArray objectAtIndex:0];
            [msgArray removeObjectAtIndex:0];
        }
//        NSArray *addArray = [NSArray arrayWithObject:msgArray];
        
        [messageList addObject:msgArray];
//        [messageListView reloadData];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (object[PF_CHAT_PICTURE] != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:user[PF_USER_FULLNAME]
                                                              date:object.createdAt media:mediaItem];
        [messages addObject:message];
        //-----------------------------------------------------------------------------------------------------------------------------------------
        PFFile *filePicture = object[PF_CHAT_PICTURE];
        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 mediaItem.image = [UIImage imageWithData:imageData];
//                 [self.collectionView reloadData];
             }
         }];
    }
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)sendMessage:(NSString *)text Picture:(UIImage *)picture
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFFile *filePicture = nil;
    //---------------------------------------------------------------------------------------------------------------------------------------------
    if (picture != nil)
    {
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) NSLog(@"sendMessage picture save error.");
         }];
    }
    //---------------------------------------------------------------------------------------------------------------------------------------------
    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_ROOMID] = roomId;
    object[PF_CHAT_TEXT] = text;
    if (filePicture != nil) object[PF_CHAT_PICTURE] = filePicture;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
         else [ProgressHUD showError:@"Network error."];;
     }];
    //---------------------------------------------------------------------------------------------------------------------------------------------
    UpdateMessageCounter(roomId, text);
    //---------------------------------------------------------------------------------------------------------------------------------------------
    [self finishSendingMessage];
}

- (void)sendCurrMessage
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [messageList removeLastObject];
    if (roomId) {
        PFUser *user = [PFUser currentUser];
        if (user)
        {
            PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
            object[PF_CHAT_USER] = user;
            object[PF_CHAT_ROOMID] = roomId;
            //    object[PF_CHAT_TEXT] = text;
            NSArray *sendMessage = [[NSArray alloc] initWithObjects:roomId, user.username, currMessageRange, nil];
//            NSString *jsonString = ArrayToJSONString(currMessageRange);
            NSString *jsonString = ArrayToJSONString(sendMessage);
            object[PF_CHAT_TEXT] = jsonString;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (error == nil)
                 {
                     [self loadMessages];
                     //             [JSQSystemSoundPlayer jsq_playMessageSentSound];
                     [messageListView reloadData];
                 }
                 //         else [ProgressHUD showError:@"Network error."];;
             }];
            //---------------------------------------------------------------------------------------------------------------------------------------------
            UpdateMessageCounter(roomId, jsonString);
            currMessageRange = nil;
            txtView.text = nil;
            [self textViewDidChange:txtView];
            txtView.inputView = nil;
            //---------------------------------------------------------------------------------------------------------------------------------------------
            [self finishSendingMessage];
        }
        
    } else {
        UIAlertView *failAlert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"You must select Hoodcon users in order to send in-App" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [failAlert show];
        hoodconsSession = NO;
    }
    
}

#pragma mark - JSQMessagesViewController method overrides

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    [self sendMessage:text Picture:nil];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)didPressAccessoryButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Take photo", @"Choose existing photo", nil];
    [action showInView:self.view];
}

#pragma mark - JSQMessages CollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return messages[indexPath.item];
}
//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message = messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return outgoingBubbleImageData;
    }
    return incomingBubbleImageData;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    PFUser *user = users[indexPath.item];
    if (avatars[user.objectId] == nil)
    {
        PFFile *fileThumbnail = user[PF_USER_THUMBNAIL];
        [fileThumbnail getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
//                 [self.collectionView reloadData];
             }
         }];
        return placeholderImageData;
    }
    else return avatars[user.objectId];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    return nil;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message = messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return nil;
    }
    
    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = messages[indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return nil;
        }
    }
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return nil;
}

#pragma mark - UICollectionView DataSource

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return [messages count];
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    if (cell == nil) {
        [collectionView layoutIfNeeded];
        cell = (JSQMessagesCollectionViewCell *)[self collectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
    
    cell.delegate = collectionView;
    
    JSQMessage *message = messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    return 0.0f;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    JSQMessage *message = messages[indexPath.item];
    if ([message.senderId isEqualToString:self.senderId])
    {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0)
    {
        JSQMessage *previousMessage = messages[indexPath.item-1];
        if ([previousMessage.senderId isEqualToString:message.senderId])
        {
            return 0.0f;
        }
    }
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"didTapLoadEarlierMessagesButton");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"didTapAvatarImageView");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"didTapMessageBubbleAtIndexPath");
}

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - UIActionSheetDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0)	ShouldStartCamera(self, YES);
        if (buttonIndex == 1)	ShouldStartPhotoLibrary(self, YES);
    }
}

#pragma mark - UIImagePickerControllerDelegate

//-------------------------------------------------------------------------------------------------------------------------------------------------
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
//-------------------------------------------------------------------------------------------------------------------------------------------------
{
    UIImage *picture = info[UIImagePickerControllerEditedImage];
    [self sendMessage:@"[Picture message]" Picture:picture];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesViewController class])
                          bundle:[NSBundle mainBundle]];
}

+ (instancetype)messagesViewController
{
    return [[[self class] alloc] initWithNibName:NSStringFromClass([JSQMessagesViewController class])
                                          bundle:[NSBundle mainBundle]];
}


#pragma mark - Initialization

- (void)jsq_configureMessagesViewController
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.jsq_isObserving = NO;
    
//    self.toolbarHeightConstraint.constant = kJSQMessagesInputToolbarHeightDefault;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
//    self.inputToolbar.delegate = self;
    self.inputToolbar.contentView.textView.placeHolder = NSLocalizedStringFromTable(@"New Message", @"JSQMessages", @"Placeholder text for the message input text view");
    self.inputToolbar.contentView.textView.delegate = self;
    
    self.senderId = @"JSQDefaultSender";
    self.senderDisplayName = @"JSQDefaultSender";
    
    self.automaticallyScrollsToMostRecentMessage = YES;
    
    self.outgoingCellIdentifier = [JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier];
    self.outgoingMediaCellIdentifier = [JSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier];
    
    self.incomingCellIdentifier = [JSQMessagesCollectionViewCellIncoming cellReuseIdentifier];
    self.incomingMediaCellIdentifier = [JSQMessagesCollectionViewCellIncoming mediaCellReuseIdentifier];
    
    self.showTypingIndicator = NO;
    
    self.showLoadEarlierMessagesHeader = NO;
    
    self.topContentAdditionalInset = 0.0f;
    
    [self jsq_updateCollectionViewInsets];
    
//    self.keyboardController = [[JSQMessagesKeyboardController alloc] initWithTextView:self.inputToolbar.contentView.textView
//                                                                          contextView:self.view
//                                                                 panGestureRecognizer:self.collectionView.panGestureRecognizer
//                                                                             delegate:self];
}


#pragma mark - Setters

- (void)setShowTypingIndicator:(BOOL)showTypingIndicator
{
    if (_showTypingIndicator == showTypingIndicator) {
        return;
    }
    
    _showTypingIndicator = showTypingIndicator;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
}

- (void)setShowLoadEarlierMessagesHeader:(BOOL)showLoadEarlierMessagesHeader
{
    if (_showLoadEarlierMessagesHeader == showLoadEarlierMessagesHeader) {
        return;
    }
    
    _showLoadEarlierMessagesHeader = showLoadEarlierMessagesHeader;
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView.collectionViewLayout invalidateLayout];
//    [self.collectionView reloadData];
}

- (void)setTopContentAdditionalInset:(CGFloat)topContentAdditionalInset
{
    _topContentAdditionalInset = topContentAdditionalInset;
    [self jsq_updateCollectionViewInsets];
}


#pragma mark - View rotation

- (BOOL)shouldAutorotate
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
//    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
//        return UIInterfaceOrientationMaskAllButUpsideDown;
//    }
    return UIInterfaceOrientationMaskPortrait;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}


#pragma mark - Messages view controller

//- (void)didPressSendButton:(UIButton *)button
//           withMessageText:(NSString *)text
//                  senderId:(NSString *)senderId
//         senderDisplayName:(NSString *)senderDisplayName
//                      date:(NSDate *)date
//{
//    NSAssert(NO, @"Error! required method not implemented in subclass. Need to implement %s", __PRETTY_FUNCTION__);
//}

//- (void)didPressAccessoryButton:(UIButton *)sender { }

- (void)finishSendingMessage
{
    UITextView *textView = self.inputToolbar.contentView.textView;
    textView.text = nil;
    [textView.undoManager removeAllActions];
    
    [self.inputToolbar toggleSendButtonEnabled];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:textView];
    
//    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
//    [self.collectionView reloadData];
    
//    if (self.automaticallyScrollsToMostRecentMessage) {
//        [self scrollToBottomAnimated:YES];
//    }
    [messageListView reloadData];
}

- (void)finishReceivingMessage
{
//    self.showTypingIndicator = NO;
//    
//    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
//    [self.collectionView reloadData];
//    [self.collectionView layoutIfNeeded];
//    
//    if (self.automaticallyScrollsToMostRecentMessage && ![self jsq_isMenuVisible]) {
//        [self scrollToBottomAnimated:YES];
//    }
    
    [messageListView reloadData];
    
    if (messageList.count > 0) {
        [messageListView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:messageList.count - 1
                                                                   inSection:0]
                               atScrollPosition:UITableViewScrollPositionBottom
                                       animated:NO];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated
{
    if ([self.collectionView numberOfSections] == 0) {
        return;
    }
    
    NSInteger items = [self.collectionView numberOfItemsInSection:0];
    
    if (items == 0) {
        return;
    }
    
    CGFloat collectionViewContentHeight = [self.collectionView.collectionViewLayout collectionViewContentSize].height;
    BOOL isContentTooSmall = (collectionViewContentHeight < self.collectionView.bounds.size.height);
    
    if (isContentTooSmall) {
        //  workaround for the first few messages not scrolling
        //  when the collection view content size is too small, `scrollToItemAtIndexPath:` doesn't work properly
        //  this seems to be a UIKit bug, see #256 on GitHub
        [self.collectionView scrollRectToVisible:CGRectMake(0.0, collectionViewContentHeight - 1.0f, 1.0f, 1.0f)
                                        animated:animated];
        return;
    }
    
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:items - 1 inSection:0]
                                atScrollPosition:UICollectionViewScrollPositionTop
                                        animated:animated];
}


#pragma mark - JSQMessages collection view data source

- (UICollectionReusableView *)collectionView:(JSQMessagesCollectionView *)collectionView
           viewForSupplementaryElementOfKind:(NSString *)kind
                                 atIndexPath:(NSIndexPath *)indexPath
{
    if (self.showTypingIndicator && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [collectionView dequeueTypingIndicatorFooterViewForIndexPath:indexPath];
    }
    else if (self.showLoadEarlierMessagesHeader && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [collectionView dequeueLoadEarlierMessagesViewHeaderForIndexPath:indexPath];
    }
    
    return nil;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    if (!self.showTypingIndicator) {
        return CGSizeZero;
    }
    
    return CGSizeMake([collectionViewLayout itemWidth], kJSQMessagesTypingIndicatorFooterViewHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    if (!self.showLoadEarlierMessagesHeader) {
        return CGSizeZero;
    }
    
    return CGSizeMake([collectionViewLayout itemWidth], kJSQMessagesLoadEarlierHeaderViewHeight);
}

#pragma mark - Collection view delegate

- (BOOL)collectionView:(JSQMessagesCollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //  disable menu for media messages
    id<JSQMessageData> messageItem = [collectionView.dataSource collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
    if ([messageItem isMediaMessage]) {
        return NO;
    }
    
    self.selectedIndexPathForMenu = indexPath;
    
    //  textviews are selectable to allow data detectors
    //  however, this allows the 'copy, define, select' UIMenuController to show
    //  which conflicts with the collection view's UIMenuController
    //  temporarily disable 'selectable' to prevent this issue
    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];
    selectedCell.textView.selectable = NO;
    
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    
    return NO;
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        id<JSQMessageData> messageData = [self collectionView:collectionView messageDataForItemAtIndexPath:indexPath];
        [[UIPasteboard generalPasteboard] setString:[messageData text]];
    }
}

#pragma mark - Collection view delegate flow layout

- (CGSize)collectionView:(JSQMessagesCollectionView *)collectionView
                  layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

//- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
//                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 1.0f;
//}
//
//- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
//                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 1.0f;
//}
//
//- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
//                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 1.0f;
//}
//
//- (void)collectionView:(JSQMessagesCollectionView *)collectionView
// didTapAvatarImageView:(UIImageView *)avatarImageView
//           atIndexPath:(NSIndexPath *)indexPath { }
//
//- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath { }
//
//- (void)collectionView:(JSQMessagesCollectionView *)collectionView
// didTapCellAtIndexPath:(NSIndexPath *)indexPath
//         touchLocation:(CGPoint)touchLocation { }

#pragma mark - Input toolbar delegate

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressLeftBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressAccessoryButton:sender];
    }
    else {
        [self didPressSendButton:sender
                 withMessageText:[self jsq_currentlyComposedMessageText]
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
}

- (void)messagesInputToolbar:(JSQMessagesInputToolbar *)toolbar didPressRightBarButton:(UIButton *)sender
{
    if (toolbar.sendButtonOnRight) {
        [self didPressSendButton:sender
                 withMessageText:[self jsq_currentlyComposedMessageText]
                        senderId:self.senderId
               senderDisplayName:self.senderDisplayName
                            date:[NSDate date]];
    }
    else {
        [self didPressAccessoryButton:sender];
    }
}

- (NSString *)jsq_currentlyComposedMessageText
{
    //  add a space to accept any auto-correct suggestions
    NSString *text = self.inputToolbar.contentView.textView.text;
    self.inputToolbar.contentView.textView.text = [text stringByAppendingString:@" "];
    return [self.inputToolbar.contentView.textView.text jsq_stringByTrimingWhitespace];
}

#pragma mark - Text view delegate

- (BOOL)textViewShouldBeginEditing:(UITextView *)tView
{
    if (tView == txtView) {
        NSLog(@"Emoji Text Selected");
    } else {
        NSLog(@"Other Text Selected");
    }
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
//    if (textView != self.inputToolbar.contentView.textView) {
//        return;
//    }
//    
//    [textView becomeFirstResponder];
//
//    if (self.automaticallyScrollsToMostRecentMessage) {
//        [self scrollToBottomAnimated:YES];
//    }
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

- (void)textViewDidChange:(UITextView *)textView
{
//    if (textView != self.inputToolbar.contentView.textView) {
//        return;
//    }
    
//    [self.inputToolbar toggleSendButtonEnabled];
    
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
//    if ( size.height >= 88 ) {
//        
//        size.height = 88;
//    }
    if ( size.height <= 32 ) {
        
        size.height = 32;
    }
    
    NSLog(@"%f, %f",size.height, msgView.frame.size.height);
    //    if ( size.height != textView.frame.size.height ) {
    if ( size.height != msgView.frame.size.height ) {
         NSLog(@"%f, %f",size.height, msgView.frame.size.height);
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

//- (void)textViewDidEndEditing:(UITextView *)textView
//{
////    if (textView != self.inputToolbar.contentView.textView) {
////        return;
////    }
//    
//    [textView resignFirstResponder];
//}


#pragma mark - text view sizing


- (void)getMessageRange:(NSString*)message :(NSMutableArray*)array {
    
    NSRange range = [message rangeOfString:FACE_NAME_HEAD];
    
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
 *
 */
- (void)getContentSize:(NSIndexPath *)indexPath {
    NSArray *currMsgRng = [messageList objectAtIndex:indexPath.row];
    NSArray *messageRange;
    if (currMsgRng.count > 1) {
        messageRange = currMsgRng[1];
    } else {
        messageRange = currMsgRng[0];
    }
//    messageRange = currMsgRng;
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
                                        constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT)];
                    
                    if ( upX > ( VIEW_WIDTH_MAX - 15) ) {
                        
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
        line_number_count = viewHeight / (VIEW_LINE_HEIGHT+VIEW_TOP);
        NSValue *sizeValue = [NSValue valueWithCGSize:CGSizeMake( viewWidth, viewHeight )];
        //        [sizeList setObject:sizeValue forKey:indexPath];
        
        NSLog(@"linecount=%d",line_number_count);
        return sizeValue;
    }
}

- (void)displayMsgView
{
    NSString *cMsg;
    
    cMsg = txtView.text;
    
    NSMutableArray *messageRange = [[NSMutableArray alloc] init];
    [self getMessageRange:txtView.text :messageRange];
    
    [msgView showMessage:messageRange];
}

- (void)adjustTableViewFrame:(BOOL)animated {
    int iOSadj = 0;
    if (lessThan7) {
        iOSadj += 20;
    }
    CGRect frame = self.contactTV.frame;
    // This places the table view right under the text field
    frame.origin.y = hdrView.frame.origin.y + hdrView.frame.size.height + contactPickerView.frame.size.height;
    // Calculate the remaining distance
    frame.size.height = self.view.frame.size.height - hdrView.frame.size.height - contactPickerView.frame.size.height - kKeyboardHeight;
    
    frame = self.collectionView.frame;
    //    frame.size.height = self.view.frame.size.height - 64;
    frame.size.height = self.view.frame.size.height - toolBar.frame.size.height - hdrView.frame.size.height - contactPickerView.frame.size.height - iOSadj;
    frame.origin.y = hdrView.frame.size.height + contactPickerView.frame.size.height;
    self.collectionView.frame = frame;
//    messageListView.frame = frame;
    
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

#pragma mark - Notifications

- (void)jsq_handleDidChangeStatusBarFrameNotification:(NSNotification *)notification
{
    if (self.keyboardController.keyboardIsVisible) {
//        [self jsq_setToolbarBottomLayoutGuideConstant:CGRectGetHeight(self.keyboardController.currentKeyboardFrame)];
    }
}

- (void)jsq_didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIMenuControllerWillShowMenuNotification
                                                  object:nil];
    
    UIMenuController *menu = [notification object];
    [menu setMenuVisible:NO animated:NO];
    
    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    CGRect selectedCellMessageBubbleFrame = [selectedCell convertRect:selectedCell.messageBubbleContainerView.frame toView:self.view];
    
    [menu setTargetRect:selectedCellMessageBubbleFrame inView:self.view];
    [menu setMenuVisible:YES animated:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(jsq_didReceiveMenuWillShowNotification:)
                                                 name:UIMenuControllerWillShowMenuNotification
                                               object:nil];
}

- (void)jsq_didReceiveMenuWillHideNotification:(NSNotification *)notification
{
    if (!self.selectedIndexPathForMenu) {
        return;
    }
    
    //  per comment above in 'shouldShowMenuForItemAtIndexPath:'
    //  re-enable 'selectable', thus re-enabling data detectors if present
    JSQMessagesCollectionViewCell *selectedCell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedIndexPathForMenu];
    selectedCell.textView.selectable = YES;
    self.selectedIndexPathForMenu = nil;
}

#pragma mark - Key-value observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == kJSQMessagesKeyValueObservingContext) {
        
        if (object == self.inputToolbar.contentView.textView
            && [keyPath isEqualToString:NSStringFromSelector(@selector(contentSize))]) {
            
            CGSize oldContentSize = [[change objectForKey:NSKeyValueChangeOldKey] CGSizeValue];
            CGSize newContentSize = [[change objectForKey:NSKeyValueChangeNewKey] CGSizeValue];
            
            CGFloat dy = newContentSize.height - oldContentSize.height;
            
            [self jsq_adjustInputToolbarForComposerTextViewContentSizeChange:dy];
            [self jsq_updateCollectionViewInsets];
            if (self.automaticallyScrollsToMostRecentMessage) {
                [self scrollToBottomAnimated:NO];
            }
        }
    }
}

#pragma mark - Keyboard controller delegate

- (void)keyboardController:(JSQMessagesKeyboardController *)keyboardController keyboardDidChangeFrame:(CGRect)keyboardFrame
{
    CGFloat heightFromBottom = CGRectGetMaxY(self.collectionView.frame) - CGRectGetMinY(keyboardFrame);
    
    heightFromBottom = MAX(0.0f, heightFromBottom);
    
//    [self jsq_setToolbarBottomLayoutGuideConstant:heightFromBottom];
}

- (void)jsq_setToolbarBottomLayoutGuideConstant:(CGFloat)constant
{
//    self.toolbarBottomLayoutGuide.constant = constant;
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
    
    [self jsq_updateCollectionViewInsets];
}

- (void)jsq_updateKeyboardTriggerPoint
{
    self.keyboardController.keyboardTriggerPoint = CGPointMake(0.0f, CGRectGetHeight(self.inputToolbar.bounds));
}

#pragma mark - Gesture recognizers

- (void)jsq_handleInteractivePopGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
                [self.snapshotView removeFromSuperview];
            }
            
            [self.keyboardController endListeningForKeyboard];
            
            if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
                [self.inputToolbar.contentView.textView resignFirstResponder];
//                [UIView animateWithDuration:0.0
//                                 animations:^{
//                                     [self jsq_setToolbarBottomLayoutGuideConstant:0.0f];f
//                                 }];
                
                UIView *snapshot = [self.view snapshotViewAfterScreenUpdates:YES];
                [self.view addSubview:snapshot];
                self.snapshotView = snapshot;
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateFailed:
            [self.keyboardController beginListeningForKeyboard];
            
            if ([UIDevice jsq_isCurrentDeviceBeforeiOS8]) {
                [self.snapshotView removeFromSuperview];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Input toolbar utilities

- (BOOL)jsq_inputToolbarHasReachedMaximumHeight
{
    return (CGRectGetMinY(self.inputToolbar.frame) == self.topLayoutGuide.length);
}

- (void)jsq_adjustInputToolbarForComposerTextViewContentSizeChange:(CGFloat)dy
{
    BOOL contentSizeIsIncreasing = (dy > 0);
    
    if ([self jsq_inputToolbarHasReachedMaximumHeight]) {
        BOOL contentOffsetIsPositive = (self.inputToolbar.contentView.textView.contentOffset.y > 0);
        
        if (contentSizeIsIncreasing || contentOffsetIsPositive) {
            [self jsq_scrollComposerTextViewToBottomAnimated:YES];
            return;
        }
    }
    
    CGFloat toolbarOriginY = CGRectGetMinY(self.inputToolbar.frame);
    CGFloat newToolbarOriginY = toolbarOriginY - dy;
    
    //  attempted to increase origin.Y above topLayoutGuide
    if (newToolbarOriginY <= self.topLayoutGuide.length) {
        dy = toolbarOriginY - self.topLayoutGuide.length;
        [self jsq_scrollComposerTextViewToBottomAnimated:YES];
    }
    
    [self jsq_adjustInputToolbarHeightConstraintByDelta:dy];
    
    [self jsq_updateKeyboardTriggerPoint];
    
    if (dy < 0) {
        [self jsq_scrollComposerTextViewToBottomAnimated:NO];
    }
}

- (void)jsq_adjustInputToolbarHeightConstraintByDelta:(CGFloat)dy
{
//    self.toolbarHeightConstraint.constant += dy;
//    
//    if (self.toolbarHeightConstraint.constant < kJSQMessagesInputToolbarHeightDefault) {
//        self.toolbarHeightConstraint.constant = kJSQMessagesInputToolbarHeightDefault;
//    }
    
    [self.view setNeedsUpdateConstraints];
    [self.view layoutIfNeeded];
}

- (void)jsq_scrollComposerTextViewToBottomAnimated:(BOOL)animated
{
    UITextView *textView = self.inputToolbar.contentView.textView;
    CGPoint contentOffsetToShowLastLine = CGPointMake(0.0f, textView.contentSize.height - CGRectGetHeight(textView.bounds));
    
    if (!animated) {
        textView.contentOffset = contentOffsetToShowLastLine;
        return;
    }
    
    [UIView animateWithDuration:0.01
                          delay:0.01
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         textView.contentOffset = contentOffsetToShowLastLine;
                     }
                     completion:nil];
}

#pragma mark - Collection view utilities

- (void)jsq_updateCollectionViewInsets
{
    [self jsq_setCollectionViewInsetsTopValue:self.topLayoutGuide.length + self.topContentAdditionalInset
                                  bottomValue:CGRectGetMaxY(self.collectionView.frame) - CGRectGetMinY(self.inputToolbar.frame)];
}

- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom
{
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

- (BOOL)jsq_isMenuVisible
{
    //  check if cell copy menu is showing
    //  it is only our menu if `selectedIndexPathForMenu` is not `nil`
    return self.selectedIndexPathForMenu != nil && [[UIMenuController sharedMenuController] isMenuVisible];
}

#pragma mark - Utilities

- (void)jsq_addObservers
{
    if (self.jsq_isObserving) {
        return;
    }
    
    [self.inputToolbar.contentView.textView addObserver:self
                                             forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                options:NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew
                                                context:kJSQMessagesKeyValueObservingContext];
    
    self.jsq_isObserving = YES;
}

- (void)jsq_removeObservers
{
    if (!_jsq_isObserving) {
        return;
    }
    
    @try {
        [_inputToolbar.contentView.textView removeObserver:self
                                                forKeyPath:NSStringFromSelector(@selector(contentSize))
                                                   context:kJSQMessagesKeyValueObservingContext];
    }
    @catch (NSException * __unused exception) { }
    
    _jsq_isObserving = NO;
}

- (void)jsq_registerForNotifications:(BOOL)registerForNotifications
{
    if (registerForNotifications) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_handleDidChangeStatusBarFrameNotification:)
                                                     name:UIApplicationDidChangeStatusBarFrameNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_didReceiveMenuWillShowNotification:)
                                                     name:UIMenuControllerWillShowMenuNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(jsq_didReceiveMenuWillHideNotification:)
                                                     name:UIMenuControllerWillHideMenuNotification
                                                   object:nil];
    }
    else {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIApplicationDidChangeStatusBarFrameNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillShowMenuNotification
                                                      object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIMenuControllerWillHideMenuNotification
                                                      object:nil];
    }
}

- (void)jsq_addActionToInteractivePopGestureRecognizer:(BOOL)addAction
{
    if (self.navigationController.interactivePopGestureRecognizer) {
        [self.navigationController.interactivePopGestureRecognizer removeTarget:nil
                                                                         action:@selector(jsq_handleInteractivePopGestureRecognizer:)];
        
        if (addAction) {
            [self.navigationController.interactivePopGestureRecognizer addTarget:self
                                                                          action:@selector(jsq_handleInteractivePopGestureRecognizer:)];
        }
    }
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
//            [self openChatView];
            if (myPhoneNum) {
                hoodconsSession = YES;
                [self sendCurrMessage];
            } else if (byPhone && !userChecked) {
                [self checkForPhone];
            }
        } else if ([btnTitle isEqualToString:@"What's App"]) {
            UIAlertView *aView = [[UIAlertView alloc] initWithTitle:@"Sorry" message:@"What's App is not available yet" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [aView show];
        }
    } else if (alertView == pushAlertWRoom) {
        NSString *btnTitle = [alertView buttonTitleAtIndex:buttonIndex];
        if ([btnTitle isEqualToString:@"YES"]) {
            [self updateRoomWithNewID];
        }
    } else {
        NSLog(@"It was not choice alert");
    }
    
}

@end
