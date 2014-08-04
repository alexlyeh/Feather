//
//  NewBookViewController.h
//  lyte
//
//  Created by Alex Yeh on 4/18/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface NewBookViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate>
{
    IBOutlet UIImageView *pagePhoto;
    IBOutlet UITextField *name;
}

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
- (IBAction)go:(id)sender;

@property BOOL newMedia;
@property (nonatomic, retain) IBOutlet UIImageView *pagePhoto;
@property (nonatomic, retain) IBOutlet UITextField *name;

@end
