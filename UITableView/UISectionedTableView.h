//
//  UISectionedTableView.h
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

#import <Foundation/Foundation.h>
#import "UISectionedTableViewDataSource.h"
#import "UISectionedTableViewDelegate.h"

@class UITableViewCell;

@interface UISectionedTableView : NSView <UISectionedTableViewDataSource, UISectionedTableViewDelegate> {
    NSMutableArray *cellSections;
    NSMutableArray *headerCells;
    NSMutableSet *dequeuedCells;
    
    NSClipView *clipView;
    CGFloat calculatedHeight;
}

@property (assign,nonatomic) IBOutlet NSObject<UISectionedTableViewDataSource>* dataSource;
@property (assign, nonatomic) IBOutlet NSObject<UISectionedTableViewDelegate>* delegate;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) CGFloat headerHeight;
@property (nonatomic, readonly) NSUInteger selectedRow;
@property (nonatomic, readonly) NSUInteger selectedSection;

- (void)reloadData;
- (IBAction)reloadData:(id)sender;
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;

- (void)tableView:(UISectionedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deselectRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)selectRow:(NSUInteger)row inSection:(NSUInteger)section;
- (void)layoutSubviews;
- (UITableViewCell *)headerCellForSection:(NSUInteger)section;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath*)indexPath;
- (void)setHeaderCell:(UITableViewCell *)cell forSection:(NSUInteger)section;
- (void)setCell:(UITableViewCell *)cell forRow:(NSUInteger)row inSection:(NSUInteger)section;

@end
