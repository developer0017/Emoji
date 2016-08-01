//
//  StoreDetailVIewController.h
//  Hoodcons
//
//  Created by SKY on 12/8/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GrayPageControl.h"
#import "MBProgressHUD.h"
@interface StoreDetailVIewController : UIViewController<UIScrollViewDelegate, MBProgressHUDDelegate>
{
    NSDictionary *_faceMap;
    int firstitemcategory_number;
    int lastitemcategory_number;
    GrayPageControl *facePageControl;
}
@property (nonatomic,retain) MBProgressHUD *HUD;
@property(nonatomic, retain) IBOutlet UIScrollView*detailscrollview;
@property(nonatomic, retain) IBOutlet UIButton *backbtn;
@property(nonatomic, retain) IBOutlet UIButton *purchasebtn;
@property(strong, nonatomic) NSString *iap_string;
- (IBAction)backbtnclick:(id)sender;
- (IBAction)storebtnclick:(id)sender;
@end
