//
//  AppDelegate.h
//  FaceBoardDome
//
//  Created by blue on 12-12-20.
//  Copyright (c) 2012年 Blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood
//

#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>

@class ViewController;
@class HomeController;
@class ChatViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) ViewController *viewController;
@property (strong, nonatomic) HomeController *homeController;
@property (strong, nonatomic) ChatViewController *chatViewController;
@property (nonatomic, strong) NSString *comeoutpurchasestr;
@property (nonatomic, strong) NSString *comeinpurchasestr;
@property (nonatomic, assign) BOOL restore_flag;
@property (nonatomic, assign) BOOL byPhone;

@property (nonatomic, assign) ABAddressBookRef addressBookRef;
@property (nonatomic, assign) NSString *myPhoneNum;
@property (nonatomic, assign) NSString *myInstallID;
@property (nonatomic, assign) NSString *currRoomID;
@property (nonatomic, strong) NSArray *contacts;
@property (nonatomic, strong) NSMutableDictionary *numToContactsDict;
@property (nonatomic, strong) NSArray *contactNumKeys;
@property (nonatomic, strong) NSMutableArray *selectedContacts;
@property (nonatomic, strong) NSArray *filteredContacts;

-(void)showHome;
-(void)showKeyBoard;
-(void)showKeyBoard2;
@end
