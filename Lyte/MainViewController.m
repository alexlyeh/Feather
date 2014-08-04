//
//  MainViewController.m
//  lyte
//
//  Created by Alex Yeh on 4/17/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "MainViewController.h"
#import "AppDelegate.h"
#import "LyteData.h"
#import "Book.h"
#import "Page.h"
@interface MainViewController ()

@end

@implementation MainViewController

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
	AppDelegate *appDelegate =
    [[UIApplication sharedApplication] delegate];
    
    LyteData *lyteData = [LyteData sharedManager];
    
    NSManagedObjectContext *context =
    [appDelegate managedObjectContext];
    
    NSEntityDescription *bookEntity =
    [NSEntityDescription entityForName:@"Book"
                inManagedObjectContext:context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity: bookEntity];
    
    NSError *error;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    NSLog(@"Book Objects Stored: %i", [objects count]);
    
    for(int i = 0; i < [objects count]; i++){
        Book *newBook = [objects objectAtIndex:i];
        [lyteData.library addObject: newBook];
    }
    
    

}

- (void) viewWillAppear:(BOOL)animated {
    LyteData *lyteData = [LyteData sharedManager];
    [lyteData.libraryCollection.collectionView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
