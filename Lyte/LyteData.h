//
//  LyteData.h
//  lyte
//
//  Created by Alex Yeh on 4/18/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LibraryCollectionViewController.h"
#import "PageCollectionViewController.h"

@interface LyteData : NSObject{
    NSMutableArray *library;
    LibraryCollectionViewController *libraryCollection;
}

@property (nonatomic, retain) NSMutableArray *library;
@property (nonatomic, retain) LibraryCollectionViewController *libraryCollection;
@property (nonatomic, retain) PageCollectionViewController *pageCollection;
+ (id)sharedManager;

@end
