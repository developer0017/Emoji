//
//  MessageListCell.h
//  InsurancePlatform
//
//  Created by kangle1208 on 13-12-10.
//  Copyright (c) 2013年 CENTRIN. All rights reserved.
//


#import <UIKit/UIKit.h>

#import "MessageView.h"


#define MSG_CELL_MIN_HEIGHT 70

#define MSG_VIEW_MIN_HEIGHT 32


@interface MessageListCell : UITableViewCell


@property (nonatomic, strong) IBOutlet UIImageView *frdIconView;

@property (nonatomic, strong) IBOutlet UIImageView *ownIconView;

@property (nonatomic, strong) IBOutlet UILabel *frdNameLabel;

@property (nonatomic, strong) IBOutlet UIImageView *msgBgView;

@property (nonatomic, strong) IBOutlet MessageView *messageView;


- (void)refreshForFrdMsg:(NSMutableArray *)message withSize:(CGSize)size;
- (void)refreshForFrdMsg:(NSMutableArray *)message withName:(NSString *)name withSize:(CGSize)size;

- (void)refreshForOwnMsg:(NSMutableArray *)message withSize:(CGSize)size;


@end
