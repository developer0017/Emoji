//
//  ContactObject.h
//  Hoodcons
//
//  Created by SKY on 12/8/14.
//  Copyright (c) 2014 Blue. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactObject : NSObject

@property (strong, nonatomic) NSString                              *contactfirstname;
@property (strong, nonatomic) NSString                              *contactlastname;
@property (strong, nonatomic) NSString                              *phone;
@property (strong, nonatomic) NSString                              *email;
@property (strong, nonatomic) NSString                              *searchField;
@property (strong, nonatomic) NSString                              *sortField;
@property (strong, nonatomic) UIImage                               *contactImg;
@end
