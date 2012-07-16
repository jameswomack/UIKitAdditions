//
//  NSIndexPath+UITableView.h
//  UISectionedTableViewDemo
//
//  Created by James Womack on 7/10/12.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSIndexPath (UITableView)

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@property(nonatomic,readonly) NSUInteger section;
@property(nonatomic,readonly) NSUInteger row;

@end
