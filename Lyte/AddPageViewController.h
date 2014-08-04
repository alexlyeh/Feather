//
//  AddPageViewController.h
//  Lyte
//
//  Created by Alex Yeh on 4/21/14.
//  Copyright (c) 2014 Alex Yeh. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface AddPageViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
{
    IBOutlet UIImageView *pagePhoto;
    IBOutlet UITextField *name;
    IBOutlet UITextField *pageNum;
    IBOutlet UIPickerView *namePicker;
    BOOL alreadyUp;
}

- (IBAction)useCamera:(id)sender;
- (IBAction)useCameraRoll:(id)sender;
- (IBAction)go:(id)sender;

@property BOOL newMedia;
@property (nonatomic, retain) IBOutlet UIPickerView *namePicker;
@property (nonatomic, retain) IBOutlet UIImageView *pagePhoto;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextField *pageNum;

@end
