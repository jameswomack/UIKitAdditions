//
//  UISectionedTableView.m
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

#import "UISectionedTableView.h"
#import "UITableViewCell.h"
#import "NSIndexPath+UITableView.h"

@implementation UISectionedTableView

@synthesize dataSource, delegate, rowHeight, headerHeight, selectedRow, selectedSection;

- (id)initWithFrame:(NSRect)frameRect
{
  if ((self = [super initWithFrame:frameRect])) {
    dequeuedCells = [[NSMutableSet alloc] init];
    cellSections = [[NSMutableArray alloc] init];
    headerCells = [[NSMutableArray alloc] init];
    
    rowHeight = 30;
    headerHeight = 18;
    
    selectedRow = NSNotFound;
    selectedSection = NSNotFound;
  }
  
  return self;
}

-(BOOL) acceptsFirstResponder
{
  NSLog(@"Map Accepting.");
  return YES;
}

-(BOOL) becomeFirstResponder
{
  NSLog(@"Map Becoming.");
  
  return YES;
  
}


- (void)keyDown:(NSEvent*)event {
  [self.delegate keyDown:event];
}


- (void)selectRow:(NSUInteger)row inSection:(NSUInteger)section
{
  selectedRow = row;
  selectedSection = section;
  
  if (selectedSection != NSNotFound && selectedSection < [cellSections count]) {
    if (selectedRow != NSNotFound && selectedRow < [[cellSections objectAtIndex:selectedSection] count]) {
      UITableViewCell *cell = [[cellSections objectAtIndex:selectedSection] objectAtIndex:selectedRow];
      if ((NSNull *)cell != [NSNull null]) {
        cell.selected = YES;
      }
    }
  }
}

- (void)deselectRow:(NSUInteger)row inSection:(NSUInteger)section
{
  if (selectedSection != NSNotFound && selectedSection < [cellSections count]) {
    if (selectedRow != NSNotFound && selectedRow < [[cellSections objectAtIndex:selectedSection] count]) {
      NSIndexPath* indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:selectedSection];
      UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
      cell.selected = NO;
    }
  }
  
  if (row == selectedRow && section == selectedSection) {
    selectedRow = NSNotFound;
    selectedSection = NSNotFound;
  }
}

- (void)awakeFromNib
{
  [self reloadData];
}

- (BOOL)isOpaque
{
  return YES;
}

- (void)drawRect:(NSRect)dirtyRect
{
  [[NSColor whiteColor] setFill];
  NSRectFill(dirtyRect);
}

- (void)dealloc
{
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (NSView *)hitTest:(NSPoint)aPoint
{
  if ([[[NSApplication sharedApplication] currentEvent] type] != NSScrollWheel &&
    [[[NSApplication sharedApplication] currentEvent] type] != NSEventTypeBeginGesture &&
    [[[NSApplication sharedApplication] currentEvent] type] != NSEventTypeEndGesture) {
    return [super hitTest:aPoint];
  }

  return self;
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSPoint click = [self convertPoint:[theEvent locationInWindow] fromView:nil];
  
  for (int section = 0; section < [cellSections count]; section++) {
    NSArray *rows = [cellSections objectAtIndex:section];
    for (int row = 0; row < [rows count]; row++) {
      id cell = [rows objectAtIndex:row];
      if (cell != [NSNull null] && NSPointInRect(click, [(NSView *)cell frame])) {
        if (section != selectedSection || row != selectedRow) {
          [self deselectRow:selectedRow inSection:selectedSection];
          
          [(UITableViewCell *)cell setSelected:YES];
          selectedRow = row;
          selectedSection = section;
          NSIndexPath* indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:selectedSection];
          
          [self tableView:self didSelectRowAtIndexPath:indexPath];
        } else if ([[NSApp currentEvent] modifierFlags]&NSShiftKeyMask || [[NSApp currentEvent] modifierFlags]&NSCommandKeyMask) {
          [self deselectRow:selectedRow inSection:selectedSection];
          NSIndexPath* indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
          
          [self tableView:self didSelectRowAtIndexPath:indexPath];
        }
        
        return;
      }
    }
  }
  
  [self deselectRow:selectedRow inSection:selectedSection];
  NSIndexPath* indexPath = [NSIndexPath indexPathForRow:NSNotFound inSection:NSNotFound];
  [self tableView:self didSelectRowAtIndexPath:indexPath]; // nothing selected
}


- (IBAction)reloadData:(id)sender
{
  [self reloadData];
}

- (void)reloadData
{
  if ([self superview] != clipView && [[self superview] isMemberOfClass:[NSClipView class]]) {
    clipView = (NSClipView *)[self superview];
    
    [clipView setPostsBoundsChangedNotifications:YES];
    [clipView setPostsFrameChangedNotifications:YES];
    [clipView setCopiesOnScroll:NO];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                         selector:@selector(viewBoundsChanged:)
                           name:NSViewBoundsDidChangeNotification
                           object:clipView];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                         selector:@selector(viewFrameChanged:)
                           name:NSViewFrameDidChangeNotification
                           object:clipView];
  }
  
  NSScrollView *scrollView = (NSScrollView *)[clipView superview];
  [scrollView setLineScroll:rowHeight];
  [scrollView setBackgroundColor:[NSColor whiteColor]];
  [scrollView setDrawsBackground:YES];
  
  calculatedHeight = 0;
  
  NSUInteger numberOfSections = [self numberOfSectionsInTableView:self];
  
  if (numberOfSections > [cellSections count]) {
    for (NSUInteger section = [cellSections count]; section < numberOfSections; section++) {
      NSUInteger numberOfRows = [self tableView:self numberOfRowsInSection:section];
      NSMutableArray *cellRows = [[NSMutableArray alloc] initWithCapacity:numberOfRows];
      [cellSections addObject:cellRows];
      [headerCells addObject:[NSNull null]];
    }
  } else if (numberOfSections < [cellSections count]) {
    NSUInteger difference = [cellSections count]-numberOfSections;
    for (NSUInteger section = 0; section < difference; section++) {
      id headerCell = [headerCells lastObject];
      if (headerCell != [NSNull null]) {
        [headerCell removeFromSuperview];
      }
      [headerCells removeLastObject];
      NSArray *cellRows = [cellSections lastObject];
      for (id cell in cellRows) {
        if (cell != [NSNull null]) {
          [cell removeFromSuperview];
        }
      }
      [cellSections removeLastObject];
    }
  }
  
//  for (id view in headerCells) {
//    if (view != [NSNull null]) {
//      [(NSView *)view removeFromSuperview];
//    }
//  }
//  
//  for (NSArray *views in cellSections) {
//    for (id view in views) {
//      if (view != [NSNull null]) {
//        [(NSView *)view removeFromSuperview];
//      }
//    }
//  }
  
//  [cellSections release];
//  cellSections = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
//  [headerCells release];
//  headerCells = [[NSMutableArray alloc] initWithCapacity:numberOfSections];
  
  for (NSUInteger section = 0; section < [cellSections count]; section++) {
    id headerCell = [headerCells objectAtIndex:section];
    if (headerCell != [NSNull null]) {
      //[dequeuedCells addObject:headerCell];
      [self setHeaderCell:nil forSection:section];
      //[headerCells replaceObjectAtIndex:section withObject:[NSNull null]];
    }
    
    NSMutableArray *cellRows = [cellSections objectAtIndex:section];
    
    NSUInteger numberOfRows = [self tableView:self numberOfRowsInSection:section];
    calculatedHeight += headerHeight + rowHeight*numberOfRows;
    
    if (numberOfRows > [cellRows count]) {
      for (NSUInteger row = [cellRows count]; row < numberOfRows; row++) {
        [cellRows addObject:[NSNull null]];
      }
    } else if (numberOfRows < [cellRows count]) {
      NSUInteger difference = [cellRows count]-numberOfRows;
      for (NSUInteger row = 0; row < difference; row++) {
        id cell = [cellRows lastObject];
        if (cell != [NSNull null]) {
          [dequeuedCells addObject:cell];
          [cell removeFromSuperview];
        }
        [cellRows removeLastObject];
      }
    }
    
    for (NSUInteger row = 0; row < numberOfRows; row++) {
      id cell = [cellRows objectAtIndex:row];
      if (cell != [NSNull null]) {
        [dequeuedCells addObject:cell];
        [cell setHidden:YES];
        [cellRows replaceObjectAtIndex:row withObject:[NSNull null]];
      }
    }
  }
  
  if (selectedSection != NSNotFound || selectedRow!= NSNotFound) {
    if (selectedSection > numberOfSections || selectedRow > [self tableView:self numberOfRowsInSection:selectedSection]) {
      [self deselectRow:selectedRow inSection:selectedSection];
      NSIndexPath* indexPath = [NSIndexPath indexPathForRow:selectedRow inSection:selectedSection];
      
      [self tableView:self didSelectRowAtIndexPath:indexPath];
    }
  }
  
  [self layoutSubviews];
}

- (void)viewBoundsChanged:(NSNotification *)aNotification
{
  [self layoutSubviews];
}

- (void)viewFrameChanged:(NSNotification *)aNotification
{
  [self layoutSubviews];
}

- (void)layoutSubviews
{
  if ([clipView frame].size.height > calculatedHeight) {
    [self setFrame:NSMakeRect(0, 0, [clipView frame].size.width, [clipView frame].size.height)];
  } else {
    [self setFrame:NSMakeRect(0, 0, [clipView frame].size.width, calculatedHeight)];
  }
  
  CGFloat offset = calculatedHeight - [clipView frame].size.height - [clipView bounds].origin.y;
  if (offset < 0) offset = 0;
  
  CGFloat clipHeight = [clipView frame].size.height;
  CGFloat actualHeight = [self frame].size.height;
  CGFloat cellWidth = [self frame].size.width;
  
  NSUInteger numberOfSections = [cellSections count];
  
  CGFloat cellOrigin = 0;
  
  UITableViewCell *recentHeader = nil;
  NSRect cellFrame;
  
  for (int section = 0; section < numberOfSections; section++) {
    NSUInteger numberOfRows = [[cellSections objectAtIndex:section] count];
    if (cellOrigin + headerHeight + rowHeight * numberOfRows < offset || cellOrigin >= offset+clipHeight) {
      [self setHeaderCell:nil forSection:section];
    } else {
      UITableViewCell *cell = [self headerCellForSection:section];
      
      if (!cell) {
        cell = [self tableView:self cellForHeaderOfSection:section];
        [self setHeaderCell:cell forSection:section];
      }
      
      if ([cell superview] != self) {
        [self addSubview:cell];
      }
      
      [cell setHidden:NO];
      
      if (cellOrigin >= offset) {
        cellFrame = NSMakeRect(0, actualHeight-cellOrigin-headerHeight, cellWidth, headerHeight);
      } else if (cellOrigin + rowHeight * numberOfRows < offset) {
        cellFrame = NSMakeRect(0, actualHeight-cellOrigin-rowHeight * numberOfRows-headerHeight, cellWidth, headerHeight);
      } else {
        cellFrame = NSMakeRect(0, actualHeight-offset-headerHeight, cellWidth, headerHeight);
      }
      
      NSRect cellFrameAdjustments = cell.frameAdjustments;
      
      cellFrame.origin.x += cellFrameAdjustments.origin.x;
      cellFrame.origin.y += cellFrameAdjustments.origin.y;
      cellFrame.size.width += cellFrameAdjustments.size.width;
      cellFrame.size.height += cellFrameAdjustments.size.height;
      
      [cell setFrame:cellFrame];
      
      if (recentHeader == nil)
        recentHeader = cell;
    }
    
    cellOrigin += headerHeight;
    
    for (int row = 0; row < numberOfRows; row++) {
      if (cellOrigin + rowHeight < offset || cellOrigin >= offset+clipHeight) {
        [self setCell:nil forRow:row inSection:section];
      } else {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
        if (!cell) {
          cell = [self tableView:self cellForRowAtIndexPath:indexPath];
          [self setCell:cell forRow:row inSection:section];
        }
        
        if ([cell superview] != self) {
          [self addSubview:cell positioned:NSWindowBelow relativeTo:nil];
        }
        
        [cell setHidden:NO];
        cell.selected = (section == selectedSection && row == selectedRow);
        cell.alternatedRow = row % 2;
        
        cellFrame = NSMakeRect(0, actualHeight-cellOrigin-rowHeight, cellWidth, rowHeight);
        
        NSRect cellFrameAdjustments = cell.frameAdjustments;
        
        cellFrame.origin.x += cellFrameAdjustments.origin.x;
        cellFrame.origin.y += cellFrameAdjustments.origin.y;
        cellFrame.size.width += cellFrameAdjustments.size.width;
        cellFrame.size.height += cellFrameAdjustments.size.height;
        
        [cell setFrame:cellFrame];
        [cell setNeedsDisplay:YES];
      }
      cellOrigin += rowHeight;
    }
  }
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
  UITableViewCell *dequeuedCell = nil;
  for (UITableViewCell *aCell in dequeuedCells) {
    if ([aCell.reuseIdentifier isEqualToString:identifier]) {
      dequeuedCell = aCell;
      break;
    }
  }
  if (dequeuedCell) {
    [dequeuedCells removeObject:dequeuedCell];
  }
  return dequeuedCell;
}

- (NSUInteger)tableView:(UISectionedTableView *)tableView numberOfRowsInSection:(NSUInteger)section
{
  NSInteger returnValue = 0;
  
  if (dataSource && [dataSource respondsToSelector:@selector(tableView:numberOfRowsInSection:)])
    returnValue = [dataSource tableView:tableView numberOfRowsInSection:section];
  
  return returnValue;
}

- (UITableViewCell *)tableView:(UISectionedTableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  UITableViewCell *returnValue = nil;
  
  if (dataSource && [dataSource respondsToSelector:@selector(tableView:cellForRowAtIndexPath:)])
  {
    returnValue = [dataSource tableView:tableView cellForRowAtIndexPath:indexPath];
  }    
  
  return returnValue;
}

- (UITableViewCell *)tableView:(UISectionedTableView *)tableView cellForHeaderOfSection:(NSUInteger)section
{
  UITableViewCell *returnValue = nil;
  
  if (dataSource && [dataSource respondsToSelector:@selector(tableView:cellForHeaderOfSection:)])
    returnValue = [dataSource tableView:tableView cellForHeaderOfSection:section];
  
  return returnValue;
}

- (NSUInteger)numberOfSectionsInTableView:(UISectionedTableView *)tableView
{
  NSInteger returnValue = 1;
  
  if (dataSource && [dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)])
    returnValue = [dataSource numberOfSectionsInTableView:tableView];
  
  return returnValue;
}

- (void)tableView:(UISectionedTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  if (delegate && [delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)])
    [delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
}


- (UITableViewCell *)headerCellForSection:(NSUInteger)section
{
  id cell = [headerCells objectAtIndex:section];
  
  if (cell == [NSNull null]) {
    cell = nil;
  }
  
  return cell;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  id cell = nil;
  
  if (indexPath) {
    cell = [[cellSections objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
  }
  
  if (cell == [NSNull null]) {
    cell = nil;
  }
  
  return cell;
}

- (void)setHeaderCell:(UITableViewCell *)cell forSection:(NSUInteger)section
{
  id oldCell = [headerCells objectAtIndex:section];
  
  if (cell) {
    [headerCells replaceObjectAtIndex:section withObject:cell];
  } else {
    [headerCells replaceObjectAtIndex:section withObject:[NSNull null]];
  }
  
  if (oldCell && oldCell != [NSNull null]) {
    [dequeuedCells addObject:oldCell];
    
    [oldCell removeFromSuperview];
  }
  
}

- (void)setCell:(UITableViewCell *)cell forRow:(NSUInteger)row inSection:(NSUInteger)section
{
  id oldCell = [[cellSections objectAtIndex:section] objectAtIndex:row];
  
  if (cell) {
    [[cellSections objectAtIndex:section] replaceObjectAtIndex:row withObject:cell];
  } else {
    [[cellSections objectAtIndex:section] replaceObjectAtIndex:row withObject:[NSNull null]];
  }
  
  if (oldCell && oldCell != [NSNull null]) {
    [dequeuedCells addObject:oldCell];
    
    [oldCell removeFromSuperview];
  }
}

@end
