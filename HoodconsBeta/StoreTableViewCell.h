//
//  StoreTableViewCell.h
//  Hoodcons
//
//  Created by Jeremiah McAllister on 11/21/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreTableViewCell : UITableViewCell
{

}

@property (strong, nonatomic) IBOutlet UILabel *catTitle;
- (void)initWithTitle:(NSString *)title;

@end
