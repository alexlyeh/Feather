//
//  PageCollectionViewController.h
//  Lyte
//
//  Created by Alex Yeh on 4/22/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDMPhotoBrowser.h"
#import "Book.h"

@interface PageCollectionViewController : UICollectionViewController <IDMPhotoBrowserDelegate, UIAlertViewDelegate>{
    NSOrderedSet *pageSet;
    NSString *header;
    NSMutableArray *pageArray;
    NSMutableArray *cellArray;
    NSMutableArray *imageArray;
    IBOutlet UIBarButtonItem *deleter;
    BOOL isDeleteActive;
    int selectedIndexPath;
    Book *book;
}
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleter;
@property (nonatomic, strong) NSOrderedSet *pageSet;
@property (nonatomic, strong) NSString *header;
@property (nonatomic, strong) Book *book;

@end
