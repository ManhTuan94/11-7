//
//  elipse.h
//  demoPhoto
//
//  Created by TechmasterVietNam on 6/6/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PixellateImage.h"
#import "MaskShape.h"
@interface ViewController : UIViewController<UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate,UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rectangle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *circle;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *ellipse;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
- (void)centerScrollViewContents;
@end
