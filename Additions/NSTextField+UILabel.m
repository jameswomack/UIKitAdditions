//
//  NSTextField+UILabel.m
//  UISectionedTableViewDemo
//
//  Created by James Womack on 7/10/12.
//  Copyright (c) 2012 Mochi Development, Inc. All rights reserved.
//

#import "NSTextField+UILabel.h"

@implementation NSTextField (UILabel)

@dynamic textAlignment, text;

- (NSTextAlignment)textAlignment
{
  return self.alignment;
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment
{
  self.alignment = textAlignment;
}

- (void)setText:(NSString *)text
{
  [self setStringValue:text];
}

- (NSString *)text
{
  return [self stringValue];
}

@end
