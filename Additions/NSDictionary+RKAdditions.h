//
//  NSDictionary+RKAdditions.h
//  Emogrammer
//
//  Created by James Womack on 7/9/12.
//  Copyright (c) 2012 James Womack. All rights reserved.
//

#import <Foundation/Foundation.h>

#define $array(...)   ((NSArray *)[NSArray arrayWithObjects:__VA_ARGS__,nil])
#define $map(...)     ((NSDictionary *)[NSDictionary dictionaryWithKeysAndObjects:__VA_ARGS__,nil])

@interface NSDictionary (RKAdditions)

+ (id)dictionaryWithKeysAndObjects:(id)firstKey, ...;

@end
