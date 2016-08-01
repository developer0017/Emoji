//
//  StoreViewController.h
//  Hoodcons
//
//  Created by Jeremiah McAllister on 11/21/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface StoreViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>
{
    
}
@property (strong, nonatomic) IBOutlet UIButton *backBtn;
@property (strong, nonatomic) IBOutlet UIButton *restorebtn;
@property (strong, nonatomic) IBOutlet UITableView *tbl;

@property (nonatomic,retain) MBProgressHUD *HUD;
@end
