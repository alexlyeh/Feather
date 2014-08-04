//
//  LyteData.m
//  lyte
//
//  Created by Alex Yeh on 4/18/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "LyteData.h"

@implementation LyteData
@synthesize library, libraryCollection, pageCollection;
// LyteData *lyteData = [LyteData sharedManager];

+ (id)sharedManager {
    static LyteData *lyteData = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        lyteData = [[self alloc] init];
    });
    return lyteData;
}

- (id)init {
    if (self = [super init]) {
        library = [[NSMutableArray alloc]init];
    }
    return self;
}


@end
