//
//  NSTextField+UILabel.h
//  UISectionedTableViewDemo
//
//  Created by James Womack on 7/10/12.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NSTextField (UILabel)

@property (nonatomic,assign) NSTextAlignment textAlignment;
@property (nonatomic,assign) NSString* text;

@end
