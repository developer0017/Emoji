//
//  StoreTableViewCell.m
//  Hoodcons
//
//  Created by Jeremiah McAllister on 11/21/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import "StoreTableViewCell.h"


@implementation StoreTableViewCell
@synthesize catTitle;

- (void)awakeFromNib {
    // Initialization code
}

- (void)initWithTitle:(NSString *)title
{
    self.catTitle.text = title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
