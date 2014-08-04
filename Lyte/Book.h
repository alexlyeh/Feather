//
//  Book.h
//  Lyte
//
//  Created by Alex Yeh on 5/6/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Page;

@interface Book : NSManagedObject

@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSOrderedSet *hasPages;
@end

@interface Book (CoreDataGeneratedAccessors)

- (void)insertObject:(Page *)value inHasPagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromHasPagesAtIndex:(NSUInteger)idx;
- (void)insertHasPages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeHasPagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInHasPagesAtIndex:(NSUInteger)idx withObject:(Page *)value;
- (void)replaceHasPagesAtIndexes:(NSIndexSet *)indexes withHasPages:(NSArray *)values;
- (void)addHasPagesObject:(Page *)value;
- (void)removeHasPagesObject:(Page *)value;
- (void)addHasPages:(NSOrderedSet *)values;
- (void)removeHasPages:(NSOrderedSet *)values;
@end
