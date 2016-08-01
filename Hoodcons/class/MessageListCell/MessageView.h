//
//  MessageView.h
//  FaceBoardDome
//
//  Created by kangle1208 on 13-12-12.
//  Copyright (c) 2013年 Blue. All rights reserved.
//


#import <UIKit/UIKit.h>


#define KFacialSizeWidth    32

#define KFacialSizeHeight   32

#define KCharacterWidth     3


#define VIEW_LINE_HEIGHT    27

#define VIEW_LEFT           12

#define VIEW_RIGHT          8

#define VIEW_TOP            5


#define VIEW_WIDTH_MAX      210
//#define VIEW_WIDTH_MAX      166

@interface MessageView : UIView {

    CGFloat upX;

    CGFloat upY;

    CGFloat lastPlusSize;

    CGFloat viewWidth;

    CGFloat viewHeight;

    BOOL isLineReturn;
}


@property (nonatomic, strong) NSMutableArray *data;


- (void)showMessage:(NSArray *)message;

@end
