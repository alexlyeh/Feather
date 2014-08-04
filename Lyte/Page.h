//
//  Page.h
//  Lyte
//
//  Created by Alex Yeh on 5/6/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Book;

@interface Page : NSManagedObject

@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSNumber * pageNumber;
@property (nonatomic, retain) Book *relationship;

@end
