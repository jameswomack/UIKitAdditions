//
//  UITableViewCell.m
//  UISectionedTableView
//
//  Created by Dimitri Bouniol on 5/1/11.
//  Copyright 2011 Mochi Development, Inc. All rights reserved.
//  
//  Copyright (c) 2011 Dimitri Bouniol, Mochi Development, Inc.
//  
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//  
//  Mochi Dev, and the Mochi Development logo are copyright Mochi Development, Inc.
//  
//  Also, it'd be super awesome if you credited this page in your about screen :)
//  

#import "UITableViewCell.h"

@implementation UITableViewCell

@synthesize reuseIdentifier, alternatedRow, selected, textLabel, imageView;

- (id)init
{
    return [self initWithReuseIdentifier:nil];
}

- (void)drawRect:(NSRect)dirtyRect
{
    if (selected) {
      [[NSColor alternateSelectedControlColor] setFill];
    } else if (alternatedRow) {
      [[NSColor colorWithCalibratedRed:0.9294 green:0.9529 blue:0.9961 alpha:1] setFill];
    } else {
      [[NSColor whiteColor] setFill];
    }
    [NSBezierPath fillRect:dirtyRect];
}

- (void)setAlternatedRow:(BOOL)yn
{
    BOOL oldValue = selected;
    alternatedRow = yn;
    [self setNeedsDisplay:(oldValue != selected)];
}

- (void)setSelected:(BOOL)yn
{
    BOOL oldValue = selected;
    selected = yn;
    [self setNeedsDisplay:(oldValue != selected)];
    
    if (yn) {
      [textLabel setTextColor:[NSColor alternateSelectedControlTextColor]];
    } else {
      [textLabel setTextColor:[NSColor blackColor]];
    }
}

- (id)initWithReuseIdentifier:(NSString *)anIdentifier
{
    if ((self = [super initWithFrame:NSMakeRect(0, 0, 100, 18)])) {
      self.reuseIdentifier = anIdentifier;
      
      textLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(30, 2, [self bounds].size.width-30, 14)];
      [[textLabel cell] setLineBreakMode:NSLineBreakByTruncatingTail];
      [textLabel setAutoresizingMask:NSViewWidthSizable];
      [textLabel setEditable:NO];
      [textLabel setSelectable:NO];
      [textLabel setDrawsBackground:NO];
      [textLabel setBezeled:NO];
      [textLabel setTextColor:[NSColor blackColor]];
      [textLabel setFont:[NSFont systemFontOfSize:11]];
      [self addSubview:textLabel];
      
      self.imageView = [[NSImageView alloc] initWithFrame:NSMakeRect(0, 2, 28, 28)];
      [self addSubview:self.imageView];
    }
    
    return self;
}

- (void)setText:(NSString *)text
{
    [textLabel setStringValue:text];
}

- (NSString *)text
{
    return [textLabel stringValue];
}

- (NSRect)frameAdjustments
{
    return NSZeroRect;
}

+ (id)cellWithReuseIdentifier:(NSString *)reuseIdentifier
{
  return [[self alloc] initWithReuseIdentifier:reuseIdentifier];
}

- (void)layoutSubviews;
{
  [self.layer layoutSublayers];
}


@end
