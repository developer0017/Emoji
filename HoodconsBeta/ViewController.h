//
//  ViewController.h
//  FaceBoardDome
//
//  Created by blue on 12-12-20.
//  Copyright (c) 2012年 Blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood
//


#import <UIKit/UIKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "FaceBoard.h"

#import "MessageListCell.h"

#import "MessageView.h"
#import "THContactPickerView.h"
#import "THContactPickerTableViewCell.h"

#import "SETextView.h"


#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? \
        CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)


@interface ViewController : UIViewController < UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, FaceBoardDelegate, THContactPickerDelegate, ABPersonViewControllerDelegate > {

    BOOL isFirstShowKeyboard;

    BOOL isButtonClicked;

    BOOL isKeyboardShowing;

    BOOL isSystemBoardShow;


    CGFloat keyboardHeight;

    NSMutableArray *messageList;

    NSMutableDictionary *sizeList;

    FaceBoard *faceBoard;

    IBOutlet UIView *hdrView;
    
    IBOutlet UIButton *doneBtn;

    IBOutlet THContactPickerView *contactPickerView;

    IBOutlet UIView *toolBar;
    
    IBOutlet UIImageView *toolBarBkg;

    IBOutlet UITextView *textView;

    IBOutlet UIButton *keyboardButton;

    IBOutlet UIButton *sendButton;

    IBOutlet UITableView *messageListView;
                                                   
    IBOutlet MessageView *msgView;

    IBOutlet UIView *btmBar;
    
}

@property (strong, nonatomic) IBOutlet UIImageView *backImg;

@property (nonatomic, strong) UITableView *contactTV;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;
@property (nonatomic, strong) NSArray *parseUsers;
@property (nonatomic, strong) NSArray *parseUserNums;
@property (nonatomic, strong) NSArray *parseMatchingContacts;
@property (nonatomic, strong) MessageView *tmpMsgView;


@property (nonatomic, strong) IBOutlet MessageListCell *tmpCell;

@property (nonatomic, strong) UINib *cellNib;

@property (nonatomic, assign) BOOL lessThan7;

- (void)didRequestPhone;
- (void)hideDoneBtn:(BOOL)hide;

@end
