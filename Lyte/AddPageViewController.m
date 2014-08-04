//
//  AddPageViewController.m
//  Lyte
//
//  Created by Alex Yeh on 4/21/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import "AddPageViewController.h"
#import "Book.h"
#import "Page.h"
#import "LyteData.h"
#import "AppDelegate.h"

@interface AddPageViewController ()

@end

@implementation AddPageViewController
@synthesize pagePhoto, pageNum, name, namePicker;

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
    name.delegate = self;
    pageNum.delegate = self;
    alreadyUp = FALSE;
}

- (void) viewWillAppear:(BOOL)animated{
    [self.namePicker reloadAllComponents];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    LyteData *lyteData = [LyteData sharedManager];
    return [lyteData.library count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    LyteData *lyteData = [LyteData sharedManager];
    if (lyteData.library != nil){
    Book * b = [lyteData.library objectAtIndex:row];
    return b.title;
    }else{
        return @"";
    }
}

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    
    LyteData *lyteData = [LyteData sharedManager];
    if (lyteData.library != nil){
    Book *b = [lyteData.library objectAtIndex: row];
    name.text = b.title;
    }
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == name){
        [textField resignFirstResponder];
        if(alreadyUp == FALSE){
            //[textField resignFirstResponder];
            LyteData *lyteData = [LyteData sharedManager];
            if (lyteData.library != nil){
                Book * b = [lyteData.library objectAtIndex: 0];
                textField.text = b.title;
            }
            CGRect newPickerFrame = CGRectMake(namePicker.frame.origin.x, (namePicker.frame.origin.y - namePicker.frame.size.height-40), namePicker.frame.size.width, namePicker.frame.size.height);
            [UIView animateWithDuration:0.4 animations:^{ namePicker.frame = newPickerFrame;}];
            alreadyUp = TRUE;
        }
        return NO;
    }else{
       return YES;
    }
    
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [pageNum resignFirstResponder];
    [name resignFirstResponder];
    if(alreadyUp == TRUE){
        CGRect newPickerFrame = CGRectMake(namePicker.frame.origin.x, (namePicker.frame.origin.y + namePicker.frame.size.height+50), namePicker.frame.size.width, namePicker.frame.size.height);
        [UIView animateWithDuration:0.4 animations:^{ namePicker.frame = newPickerFrame;}];
        alreadyUp = FALSE;
    }
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

- (IBAction)go:(id)sender {
    
    if(pagePhoto.image != nil && name.text != nil && pageNum.text != nil){
        
        LyteData *lyteData = [LyteData sharedManager];
        
        AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *context = [appDelegate managedObjectContext];
        
        Book *selectedBook = nil;

        for (int x = 0; x < [lyteData.library count]; x++){
            Book *tempBook = [lyteData.library objectAtIndex:x];
            if([tempBook.title isEqualToString: name.text]){
                selectedBook = tempBook;
            }
        }
        
        if (selectedBook != nil){
            
            [self.navigationController popViewControllerAnimated:YES];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
                
                dispatch_async(dispatch_get_main_queue(), ^{

        
                    UIImage *image = [self imageWithImage:pagePhoto.image scaledToSize:CGSizeMake(320,480)];
                    NSManagedObject *pageEntity = [NSEntityDescription insertNewObjectForEntityForName:@"Page" inManagedObjectContext:context];
                    NSNumber *num = [NSNumber numberWithInt:[pageNum.text intValue]];
                    NSString *imagePath = [self saveImage:image :selectedBook :num];
                    [pageEntity setValue:imagePath forKey:@"imageURL"];
                    [pageEntity setValue: num forKey:@"pageNumber"];
                    Page *newPage = (Page *)pageEntity;
        
                    [selectedBook addHasPagesObject:newPage];

                    NSError *error;
                    [context save:&error];
                    
                    
                    name.text = nil;
                    pagePhoto.image = nil;
                });
            });



        }else{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                            message:@"Lyte could not find the collection"
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
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (NSString *)saveImage: (UIImage *)image : (Book *)newBook : (NSNumber *)pageN {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent: newBook.title];
    savedImagePath = [savedImagePath stringByAppendingString: [pageN stringValue]];
    savedImagePath = [savedImagePath stringByAppendingString: @".jpeg"];
    NSData *imageData = UIImageJPEGRepresentation(image, 0.9);
    [imageData writeToFile:savedImagePath atomically:NO];
    return savedImagePath;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
