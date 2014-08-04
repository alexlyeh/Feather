//
//  LibraryCollectionViewController.h
//  lyte
//
//  Created by Alex Yeh on 4/19/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LibraryCollectionViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIAlertViewDelegate> {
    
    NSMutableArray *cellArray;
    NSMutableArray *imageArray;
    IBOutlet UIBarButtonItem *deleter;
    BOOL isDeleteActive;
    int selectedIndexPath;
    
}
//@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *deleter;


@end
