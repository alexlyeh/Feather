//
//  NewBookViewController.m
//  lyte
//
//  Created by Alex Yeh on 4/18/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "NewBookViewController.h"
#import "Book.h"
#import "Page.h"
#import "LyteData.h"
#import "AppDelegate.h"

@interface NewBookViewController ()

@end

@implementation NewBookViewController
@synthesize name, pagePhoto;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    name.delegate = self;
    
}

-(void)viewWillAppear:(BOOL)animated{
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void) useCamera:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = YES;
    }
}

- (void) useCameraRoll:(id)sender
{
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType =
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
        imagePicker.allowsEditing = NO;
        [self presentViewController:imagePicker
                           animated:YES completion:nil];
        _newMedia = NO;
    }
}

#pragma mark -
#pragma mark UIImagePickerControllerDelegate

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = info[UIImagePickerControllerMediaType];
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        pagePhoto.image = image;
        
//        if (_newMedia)
//            UIImageWriteToSavedPhotosAlbum(image,
//                                           self,
//                                           @selector(image:finishedSavingWithError:contextInfo:),
//                                           nil);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Code here to support video if enabled
    }
}

-(void)image:(UIImage *)image finishedSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
    }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)go:(id)sender {
    
    if(pagePhoto.image != nil && ![name.text isEqualToString:nil] && ![name.text isEqualToString:@""]){
        
        LyteData *lyteData = [LyteData sharedManager];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        BOOL isNew = TRUE;
        
        for (int x = 0; x < [lyteData.library count]; x++){
            Book *tempBook = [lyteData.library objectAtIndex:x];
            if([tempBook.title isEqualToString: name.text]){
                isNew = FALSE;
            }
        }

        if(isNew){
            
            [self.navigationController popViewControllerAnimated:YES];
            

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSManagedObject *bookEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Book" inManagedObjectContext:context];
                    [bookEntity setValue:name.text forKey:@"title"];
                    Book *newBook = (Book *)bookEntity;
        
                    UIImage *image = [self imageWithImage:pagePhoto.image scaledToSize:CGSizeMake(320,480)];
                    NSManagedObject *pageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                    NSString *imagePath = [self saveImage:image :newBook];
                    [pageEntity setValue:imagePath forKey:@"imageURL"];
                    
                    NSNumber *zero = [NSNumber numberWithInt:0];
                    [pageEntity setValue:zero forKey:@"pageNumber"];
                    
                    Page *newPage = (Page *)pageEntity;
        
                    [newBook addHasPagesObject:newPage];
                    [lyteData.library addObject:newBook];
                    
                    NSError *error;
                    [context save:&error];
                    
                    name.text = nil;
                    pagePhoto.image = nil;
                    

                });
            });
            
            
       }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"This book already exists!"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];

        }

    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                              message:@"You seem to have left out some info"
                                              delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];

   }
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

- (NSString *)saveImage: (UIImage *)image : (Book *)newBook {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent: newBook.title];
    savedImagePath = [savedImagePath stringByAppendingString:@"0.jpeg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    [imageData writeToFile:savedImagePath atomically:NO];
    return savedImagePath;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
