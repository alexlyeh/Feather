//
//  LibraryCollectionViewController.m
//  lyte
//
//  Created by Alex Yeh on 4/19/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "LibraryCollectionViewController.h"
#import "Book.h"
#import "Page.h"
#import "LyteData.h"
#import "PageCollectionViewController.h"
#import "AppDelegate.h"

@interface LibraryCollectionViewController ()

@end

@implementation LibraryCollectionViewController
@synthesize deleter;
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
    imageArray = [[NSMutableArray alloc]init];
    
    LyteData *lyteData = [LyteData sharedManager];
    lyteData.libraryCollection = self;
    isDeleteActive = FALSE;
    [deleter setTarget: self];
    [deleter setAction: @selector(activateDelete)];
}

-(void)viewWillAppear:(BOOL)animated{


}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    LyteData *lyteData = [LyteData sharedManager];
    return [lyteData.library count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    @autoreleasepool {
    static NSString *identifier = @"CollectionCell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    LyteData *lyteData = [LyteData sharedManager];
    Book *newBook = [lyteData.library objectAtIndex:indexPath.row];
    Page *coverPage;
    
    coverPage = [newBook.hasPages firstObject];
    
    UILabel *title = (UILabel *)[cell viewWithTag:99];
    title.text = newBook.title;
    
    UIImageView *gridImageView = (UIImageView *)[cell viewWithTag:100];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
        
        dispatch_async(dispatch_get_main_queue(), ^{


            if(indexPath.row >= [imageArray count]){
                NSNumber *pageN = [NSNumber numberWithInt: [coverPage.pageNumber intValue]];
                UIImage *coverPhoto = [self getImage:newBook :pageN];
                [imageArray addObject:coverPhoto];
                [UIView transitionWithView: gridImageView
                              duration:0.3f
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                gridImageView.image = [self imageWithImage:coverPhoto scaledToSize:CGSizeMake(125, 175)];
                            } completion:nil];
        
            }else{
                gridImageView.image = [self imageWithImage:[imageArray objectAtIndex:indexPath.row] scaledToSize:CGSizeMake(125, 175)];
            }
        });
        
    });
    
//    if(![cellArray containsObject:cell]){
//    
//            [cellArray addObject: cell];
//    }
//        
    return cell;
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

- (void) deleteFiles: (Book *)deletedBook {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSError *err;
    for(Page *p in deletedBook.hasPages){
        NSString *filePath = [documentsDirectory stringByAppendingPathComponent: deletedBook.title];
        filePath = [filePath stringByAppendingString:[p.pageNumber stringValue]];
        filePath = [filePath stringByAppendingString:@".jpeg"];
        BOOL success = [fileManager removeItemAtPath:filePath error:&err];
        NSLog(@"%d", success);
    }
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    [fetchRequest setEntity:[NSEntityDescription entityForName:@"Book" inManagedObjectContext:context]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"title == %@", deletedBook.title]];
    NSError* error = nil;
    NSArray* results = [context executeFetchRequest:fetchRequest error:&error];
    for (NSManagedObject *product in results) {
        [context deleteObject:product];
    }
    [context save:&error];
}

-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIImage*)getImage: (Book *)book : (NSNumber *) pageNumber{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,     NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *getImagePath = [documentsDirectory stringByAppendingPathComponent:book.title];
    getImagePath = [getImagePath stringByAppendingString: [pageNumber stringValue]];
    getImagePath = [getImagePath stringByAppendingString:@".jpeg"];
    UIImage *img = [UIImage imageWithContentsOfFile:getImagePath];
    return img;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if(isDeleteActive){
        selectedIndexPath = indexPath.row;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Wait" message:@"Are you sure you want to delete this.  This action cannot be undone" delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
  
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0){
        LyteData *lyteData = [LyteData sharedManager];
        Book *b = [lyteData.library objectAtIndex: selectedIndexPath];
        [self deleteFiles: b];
        [imageArray removeObjectAtIndex: selectedIndexPath];
        [lyteData.library removeObjectAtIndex: selectedIndexPath];
        [self.collectionView performBatchUpdates:^{
            [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        } completion:nil];

    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
        if ([segue.identifier isEqualToString:@"PassBookSegue"]) {
            LyteData *lyteData = [LyteData sharedManager];
            Book * selectedBook = [lyteData.library objectAtIndex: [self.collectionView indexPathForCell: (UICollectionViewCell *)sender].row];
            PageCollectionViewController * pageCollection = (PageCollectionViewController*)segue.destinationViewController;
            for(Page *p in selectedBook.hasPages){
                NSLog(@"%i",[p.pageNumber intValue]);
            }
            NSLog(@"%@", selectedBook.title);
            NSLog(@" ");
            pageCollection.pageSet = selectedBook.hasPages;
            pageCollection.header = selectedBook.title;
            pageCollection.book = selectedBook;
        }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return !isDeleteActive;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
