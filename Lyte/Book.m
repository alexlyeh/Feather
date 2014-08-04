//
//  Book.m
//  Lyte
//
//  Created by Alex Yeh on 5/6/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "Book.h"
#import "Page.h"


@implementation Book

@dynamic title;
@dynamic hasPages;

- (void)addHasPagesObject:(Page *)value {
    NSMutableOrderedSet* tempSet = [NSMutableOrderedSet orderedSetWithOrderedSet:self.hasPages];
    [tempSet addObject:value];
    self.hasPages = tempSet;
}

@end
