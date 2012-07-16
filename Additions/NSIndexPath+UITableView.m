//
//  NSIndexPath+UITableView.m
//  UISectionedTableViewDemo
//
//  Created by James Womack on 7/10/12.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import "NSIndexPath+UITableView.h"

@implementation NSIndexPath (UITableView)
@dynamic section, row;

+ (NSIndexPath *)indexPathForRow:(NSInteger)row inSection:(NSInteger)section;
{
  NSIndexPath* ip = [NSIndexPath indexPathWithIndex:section];
  ip = [ip indexPathByAddingIndex:row];
  return ip;
}

- (NSUInteger)row
{
  NSUInteger indexes[2];
  [self getIndexes:(NSUInteger*)&indexes];
  return indexes[1];
}

- (NSUInteger)section
{
  NSUInteger indexes[2];
  [self getIndexes:(NSUInteger*)&indexes];
  return indexes[0];
}

@end

