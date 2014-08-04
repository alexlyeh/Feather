//
//  PageCollectionViewController.m
//  Lyte
//
//  Created by Alex Yeh on 4/22/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "PageCollectionViewController.h"
#import "Book.h"
#import "Page.h"
#import "LyteData.h"
#import "AppDelegate.h"
#import "IDMPhoto.h"
#import "IDMPhotoBrowser.h"

@implementation PageCollectionViewController
@synthesize pageSet, header, deleter, book;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    cellArray = [[NSMutableArray alloc]init];
	pageArray = [[NSMutableArray alloc]init];
    for (Page *p in pageSet){
        [pageArray addObject: p];
    }
    
    [pageArray sortUsingComparator:
        ^NSComparisonResult(id obj1, id obj2){
         
            Page *p1 = (Page*)obj1;
            Page *p2 = (Page*)obj2;
            if ([p1.pageNumber intValue] > [p2.pageNumber intValue]) {
                return (NSComparisonResult)NSOrderedDescending;
            }
         
            if ([p1.pageNumber intValue] < [p2.pageNumber intValue]) {
                return (NSComparisonResult)NSOrderedAscending;
            }
            return (NSComparisonResult)NSOrderedSame;
     }];
    
    imageArray = [[NSMutableArray alloc]init];
    
    isDeleteActive = FALSE;
    [deleter setTarget: self];
    [deleter setAction: @selector(activateDelete)];

    
}

-(void)viewWillAppear:(BOOL)animated{
 
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return [pageArray count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    static NSString *identifier = @"CollectionCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    Page *coverPage = [pageArray objectAtIndex: indexPath.row];
    
    UILabel *num = (UILabel *)[cell viewWithTag:100];
    if ([coverPage.pageNumber intValue] == 0){
        num.text = @"cover";
    }else{
        num.text = [coverPage.pageNumber stringValue];
    }
    
    UIImageView *gridImageView = (UIImageView *)[cell viewWithTag:99];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            if(indexPath.row >= [imageArray count]){
                NSNumber *pageN = [NSNumber numberWithInt: [coverPage.pageNumber intValue]];
                UIImage *coverPhoto = [self getImage:pageN];
                [imageArray addObject:coverPhoto];
                [UIView transitionWithView: gridImageView
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                gridImageView.image =  [self imageWithImage:coverPhoto scaledToSize:CGSizeMake(61, 90)];
                            } completion:nil];
            }else{
                gridImageView.image = [self imageWithImage:[imageArray objectAtIndex:indexPath.row] scaledToSize: CGSizeMake(61, 90)];
            }
        });
        
    });

    
//    if ([selectedIndexPath isEqual:indexPath]) {
//        cell.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(141/255.0) blue:(106/255.0) alpha:1.0];
//    } else {
//        cell.backgroundColor = [UIColor colorWithRed:(255/255.0) green:(141/255.0) blue:(106/255.0) alpha:0.0];
//        
//    }
    
    [cellArray addObject: cell];
    
    return cell;
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)getImage: (NSNumber *) pageNumber{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:header];
    getImagePath = [getImagePath stringByAppendingString: [pageNumber stringValue]];
    getImagePath = [getImagePath stringByAppendingString:@".jpeg"];
    NSLog(@"%@", getImagePath);
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(isDeleteActive){
        selectedIndexPath = indexPath.row;
        UIAlertView *alert;
        
        if(indexPath.row != 0){
            alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this.  This action cannot be undone" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        }else{
            alert = [[UIAlertView alloc] initWithTitle:@"Hey"
                                                message:@"Don't delete the cover page!"
                                                delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        }
        
        [alert show];
    }else{
        NSMutableArray *photos = [[NSMutableArray alloc]init];

        for (int i = 0; i < [imageArray count]; i++) {
            IDMPhoto *photo = [IDMPhoto photoWithImage:[imageArray objectAtIndex:i]];
            [photos addObject: photo];
        }
    
        IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos: photos];
        [browser setInitialPageIndex:indexPath.row];
        [self presentViewController:browser animated:YES completion:nil];
    }
    
}

- (void) activateDelete {
    
    if(!isDeleteActive){
        deleter.title = @"View";
        isDeleteActive = TRUE;
    }else{
        deleter.title = @"Edit";
        isDeleteActive = FALSE;
    }
    
}

- (void) deleteFiles: (Page *)deletedPage {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *err;
    NSString *filePath = deletedPage.imageURL;
    BOOL success = [fileManager removeItemAtPath:filePath error:&err];
    NSLog(@"WEWEFWEF %d", success);
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Page" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"imageURL == %@", deletedPage.imageURL]];
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fetchRequest error:&error];
    
    for (NSManagedObject *product in results) {
        NSLog(@"%@", product);
        [context deleteObject:product];
    }
    //x[book removeHasPagesObject: deletedPage];
    [context save:&error];
    
    
    if ([context save:&error]) {
        NSLog(@"Successfully saved the context.");
    } else {
        NSLog(@"Failed to save the context. Error = %@", error);
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        Page *p = [pageArray objectAtIndex: selectedIndexPath];
        [self deleteFiles: p];
        [imageArray removeObjectAtIndex: selectedIndexPath];
        [pageArray removeObjectAtIndex: selectedIndexPath];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];
    }
}

#pragma mark - IDMPhotoBrowser Delegate

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)pageIndex
{
    id <IDMPhoto> photo = [photoBrowser photoAtIndex:pageIndex];
    NSLog(@"Did dismiss photoBrowser with photo index: %d, photo caption: %@", pageIndex, photo.caption);
}

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex
{
    id <IDMPhoto> photo = [photoBrowser photoAtIndex:photoIndex];
    NSLog(@"Did dismiss actionSheet with photo index: %d, photo caption: %@", photoIndex, photo.caption);
    
    NSString *title = [NSString stringWithFormat:@"Option %d", buttonIndex+1];
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(25, 25, 15, 15);
}


@end
