//
//  ChatViewController.h
//  Hoodcons
//
//  Created by Jeremiah McAllister on 12/2/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FaceBoard.h"

#import "MessageListCell.h"

#import "MessageView.h"
#import "THContactPickerView.h"
#import "THContactPickerTableViewCell.h"


#import "JSQMessagesCollectionView.h"
#import "JSQMessagesCollectionViewFlowLayout.h"
#import "JSQMessagesInputToolbar.h"

#import "JSQMessages.h"

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


@interface ChatViewController : UIViewController <JSQMessagesCollectionViewDataSource,JSQMessagesCollectionViewDelegateFlowLayout, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, FaceBoardDelegate, THContactPickerDelegate, ABPersonViewControllerDelegate , UIActionSheetDelegate, UIImagePickerControllerDelegate>

{
    BOOL isFirstShowKeyboard;
    
    BOOL isButtonClicked;
    
    BOOL isKeyboardShowing;
    
    BOOL isSystemBoardShow;
    
    int line_number_count ;
    CGFloat keyboardHeight;
    
    NSMutableArray *messageList;
    
    NSMutableDictionary *sizeList;
    
    FaceBoard *faceBoard;
    
    IBOutlet UIView *hdrView;
    
    IBOutlet UIButton *doneBtn;
    
    IBOutlet THContactPickerView *contactPickerView;
    
    IBOutlet UIView *toolBar;
    
    IBOutlet UIImageView *toolBarBkg;
    
    IBOutlet UITextView *txtView;
    
    IBOutlet UIButton *keyboardButton;
    
    IBOutlet UIButton *sendButton;
    
    IBOutlet UITableView *messageListView;
    
    IBOutlet MessageView *msgView;
    
    IBOutlet UIView *btmBar;
    
    
}

- (id)initWith:(NSString *)roomId_;

@property (nonatomic, assign) NSArray *sendMsg;

@property (strong, nonatomic) IBOutlet UIImageView *backImg;
@property (nonatomic, strong) UITableView *contactTV;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableDictionary *numToContactsDict;
@property (nonatomic, strong) NSArray *contactNumKeys;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) MessageView *tmpMsgView;


@property (nonatomic, strong) IBOutlet MessageListCell *tmpCell;

@property (nonatomic, strong) UINib *cellNib;

@property (nonatomic, assign) BOOL lessThan7;

- (NSString *)getRoomID;
- (void)getContacts;
- (void)didRequestPhone;
- (void)hideDoneBtn:(BOOL)hide;
- (void)loadPush:(NSDictionary *)userInfo;
- (void)setNewRoomID:(NSString *)newRoomId;
- (void)updateRoomWithNewID;
- (void)gotostorecontroller;

/**
 *  Returns the collection view object managed by this view controller.
 *  This view controller is the collection view's data source and delegate.
 */

@property (weak, nonatomic, readonly) JSQMessagesCollectionView *collectionView;

/**
 *  Returns the input toolbar view object managed by this view controller.
 *  This view controller is the toolbar's delegate.
 */
@property (weak, nonatomic, readonly) JSQMessagesInputToolbar *inputToolbar;

/**
 *  The display name of the current user who is sending messages.
 *  This value does not have to be unique.
 *
 *  @discussion This value must not be `nil`. The default value is `@"JSQDefaultSender"`.
 */
@property (copy, nonatomic) NSString *senderDisplayName;

/**
 *  The string identifier that uniquely identifies the current user sending messages.
 *
 *  @discussion This property is used to determine if a message is incoming or outgoing.
 *  All message data objects returned by `collectionView:messageDataForItemAtIndexPath:` are
 *  checked against this identifier.
 *  This value must not be `nil`. The default value is `@"JSQDefaultSender"`.
 */
@property (copy, nonatomic) NSString *senderId;

/**
 *  Specifies whether or not the view controller should automatically scroll to the most recent message
 *  when the view appears and when sending, receiving, and composing a new message.
 *
 *  @discussion The default value is `YES`, which allows the view controller to scroll automatically to the most recent message.
 *  Set to `NO` if you want to manage scrolling yourself.
 */
@property (assign, nonatomic) BOOL automaticallyScrollsToMostRecentMessage;

/**
 *  The collection view cell identifier to use for dequeuing outgoing message collection view cells
 *  in the collectionView for text messages.
 *
 *  @discussion This cell identifier is used for outgoing text message data items.
 *  The default value is the string returned by `[JSQMessagesCollectionViewCellOutgoing cellReuseIdentifier]`.
 *  This value must not be `nil`.
 *
 *  @see JSQMessagesCollectionViewCellOutgoing.
 *
 *  @warning Overriding this property's default value is *not* recommended.
 *  You should only override this property's default value if you are proividing your own cell prototypes.
 *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
 *  completely overriding many delegate and data source methods for the collectionView,
 *  including `collectionView:cellForItemAtIndexPath:`.
 */
@property (copy, nonatomic) NSString *outgoingCellIdentifier;

/**
 *  The collection view cell identifier to use for dequeuing outgoing message collection view cells
 *  in the collectionView for media messages.
 *
 *  @discussion This cell identifier is used for outgoing media message data items.
 *  The default value is the string returned by `[JSQMessagesCollectionViewCellOutgoing mediaCellReuseIdentifier]`.
 *  This value must not be `nil`.
 *
 *  @see JSQMessagesCollectionViewCellOutgoing.
 *
 *  @warning Overriding this property's default value is *not* recommended.
 *  You should only override this property's default value if you are proividing your own cell prototypes.
 *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
 *  completely overriding many delegate and data source methods for the collectionView,
 *  including `collectionView:cellForItemAtIndexPath:`.
 */
@property (copy, nonatomic) NSString *outgoingMediaCellIdentifier;

/**
 *  The collection view cell identifier to use for dequeuing incoming message collection view cells
 *  in the collectionView for text messages.
 *
 *  @discussion This cell identifier is used for incoming text message data items.
 *  The default value is the string returned by `[JSQMessagesCollectionViewCellIncoming cellReuseIdentifier]`.
 *  This value must not be `nil`.
 *
 *  @see JSQMessagesCollectionViewCellIncoming.
 *
 *  @warning Overriding this property's default value is *not* recommended.
 *  You should only override this property's default value if you are proividing your own cell prototypes.
 *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
 *  completely overriding many delegate and data source methods for the collectionView,
 *  including `collectionView:cellForItemAtIndexPath:`.
 */
@property (copy, nonatomic) NSString *incomingCellIdentifier;

/**
 *  The collection view cell identifier to use for dequeuing incoming message collection view cells
 *  in the collectionView for media messages.
 *
 *  @discussion This cell identifier is used for incoming media message data items.
 *  The default value is the string returned by `[JSQMessagesCollectionViewCellIncoming mediaCellReuseIdentifier]`.
 *  This value must not be `nil`.
 *
 *  @see JSQMessagesCollectionViewCellIncoming.
 *
 *  @warning Overriding this property's default value is *not* recommended.
 *  You should only override this property's default value if you are proividing your own cell prototypes.
 *  These prototypes must be registered with the collectionView for reuse and you are then responsible for
 *  completely overriding many delegate and data source methods for the collectionView,
 *  including `collectionView:cellForItemAtIndexPath:`.
 */
@property (copy, nonatomic) NSString *incomingMediaCellIdentifier;

/**
 *  Specifies whether or not the view controller should show the typing indicator for an incoming message.
 *
 *  @discussion Setting this property to `YES` will animate showing the typing indicator immediately.
 *  Setting this property to `NO` will animate hiding the typing indicator immediately. You will need to scroll
 *  to the bottom of the collection view in order to see the typing indicator. You may use `scrollToBottomAnimated:` for this.
 */
@property (assign, nonatomic) BOOL showTypingIndicator;

/**
 *  Specifies whether or not the view controller should show the "load earlier messages" header view.
 *
 *  @discussion Setting this property to `YES` will show the header view immediately.
 *  Settings this property to `NO` will hide the header view immediately. You will need to scroll to
 *  the top of the collection view in order to see the header.
 */
@property (assign, nonatomic) BOOL showLoadEarlierMessagesHeader;

/**
 *  Specifies an additional inset amount to be added to the collectionView's contentInsets.top value.
 *
 *  @discussion Use this property to adjust the top content inset to account for a custom subview at the top of your view controller.
 */
@property (assign, nonatomic) CGFloat topContentAdditionalInset;

#pragma mark - Class methods

/**
 *  Returns the `UINib` object initialized for a `JSQMessagesViewController`.
 *
 *  @return The initialized `UINib` object or `nil` if there were errors during initialization
 *  or the nib file could not be located.
 *
 *  @discussion You may override this method to provide a customized nib. If you do,
 *  you should also override `messagesViewController` to return your
 *  view controller loaded from your custom nib.
 */
+ (UINib *)nib;

/**
 *  Creates and returns a new `JSQMessagesViewController` object.
 *
 *  @discussion This is the designated initializer for programmatic instantiation.
 *
 *  @return An initialized `JSQMessagesViewController` object if successful, `nil` otherwise.
 */
+ (instancetype)messagesViewController;

#pragma mark - Messages view controller

/**
 *  This method is called when the user taps the send button on the inputToolbar
 *  after composing a message with the specified data.
 *
 *  @param button            The send button that was pressed by the user.
 *  @param text              The message text.
 *  @param senderId          The message sender identifier.
 *  @param senderDisplayName The message sender display name.
 *  @param date              The message date.
 */
- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date;

/**
 *  This method is called when the user taps the accessory button on the `inputToolbar`.
 *
 *  @param sender The accessory button that was pressed by the user.
 */
- (void)didPressAccessoryButton:(UIButton *)sender;

/**
 *  Completes the "sending" of a new message by animating and resetting the `inputToolbar`,
 *  animating the addition of a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message
 *  as specified by `automaticallyScrollsToMostRecentMessage`.
 *
 *  @discussion You should call this method at the end of `didPressSendButton:withMessage:`
 *  after adding the new message to your data source and performing any related tasks.
 *
 *  @see `automaticallyScrollsToMostRecentMessage`.
 *  @see `didPressSendButton: withMessage:`.
 */
- (void)finishSendingMessage;

/**
 *  Completes the "receiving" of a new message by animating the typing indicator,
 *  animating the addition of a new collection view cell in the collection view,
 *  reloading the collection view, and scrolling to the newly sent message
 *  as specified by `automaticallyScrollsToMostRecentMessage`.
 *
 *  @discussion You should call this method after adding a new "received" message
 *  to your data source and performing any related tasks.
 *
 *  @see `automaticallyScrollsToMostRecentMessage`.
 */
- (void)finishReceivingMessage;

/**
 *  Scrolls the collection view such that the bottom most cell is completely visible, above the `inputToolbar`.
 *
 *  @param animated Pass `YES` if you want to animate scrolling, `NO` if it should be immediate.
 */
- (void)scrollToBottomAnimated:(BOOL)animated;



@end
