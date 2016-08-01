//
//  FaceBoard.h
//
//  Created by blue on 12-9-26.
//  Copyright (c) 2012年 blue. All rights reserved.
//  Email - 360511404@qq.com
//  http://github.com/bluemood


#import <UIKit/UIKit.h>

#import "FaceButton.h"

#import "GrayPageControl.h"

#import "SETextView.h"


#define FACE_NAME_HEAD  @"/s"

// 表情转义字符的长度（ /s占2个长度，xxx占3个长度，共5个长度 ）
#define FACE_NAME_LEN   5


@protocol FaceBoardDelegate <NSObject>

@optional

- (void)textViewDidChange:(UITextView *)textView;

@end


@interface FaceBoard : UIView<UIScrollViewDelegate>{

    UIImageView *faceViewBkg;
    
    UIScrollView *faceView;

    GrayPageControl *facePageControl;

    NSArray *category_itemarray;
    
    
    NSDictionary *_faceMap;
    NSMutableDictionary* category_dictionary;
    
    NSUserDefaults *userdefaults;
    
    NSString *purchase_string;
    UIAlertView *alertview;
}


@property (nonatomic, weak) id<FaceBoardDelegate> delegate;


@property (nonatomic, strong) UITextField *inputTextField;

@property (nonatomic, strong) UITextView *inputTextView;

@property (nonatomic, strong) SETextView *imgTextView;
@property (nonatomic, retain) id parentController;

- (void)backFace;
- (void)categoryload;

@end
