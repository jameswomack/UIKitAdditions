//
//  NSDictionary+RKAdditions.m
//  Emogrammer
//
//  Created by James Womack on 7/9/12.
//  Copyright (c) 2012 James Womack. All rights reserved.
//

#import "NSDictionary+RKAdditions.h"

@implementation NSDictionary (RKAdditions)

+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ... {
	va_list args;
  va_start(args, firstKey);
	NSMutableArray* keys = [NSMutableArray array];
	NSMutableArray* values = [NSMutableArray array];
  for (id key = firstKey; key != nil; key = va_arg(args, id)) {
		id value = va_arg(args, id);
    [keys addObject:key];
		[values addObject:value];		
  }
  va_end(args);
  
  return [self dictionaryWithObjects:values forKeys:keys];
}
@end


