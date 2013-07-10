//
//  ViewController.m
//  demoPhoto
//
//  Created by TechmasterVietNam on 5/31/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "ViewController.h"
#import "GPUImage.h"
#import <QuartzCore/QuartzCore.h>
@class PixellateImage;
@interface ViewController () {
    UIImage *originalImage;
    int num;
    CGPoint touchPoint;
    UISlider* sliderRotate;
    CGRect rotated;
    float height;
    float width;
    float x;
    float y;
}
@property(strong,nonatomic) UIImageView* originalImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property(readwrite,nonatomic) UIImageView* layer_pixellate;
@property(readwrite,nonatomic) MaskShape* layer_1;
@property(readwrite,nonatomic) UIView* layer_2;
@property (nonatomic, retain) UIPinchGestureRecognizer * pinchGesture;
@property (nonatomic, retain) UIRotationGestureRecognizer * rotateGesture;

@end
@implementation ViewController
@synthesize originalImageView,scrollView,layer_pixellate,layer_1,layer_2;

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    CGRect scrollViewFrame = scrollView.frame;
    CGFloat scaleWidth = scrollViewFrame.size.width / scrollView.contentSize.width;
    CGFloat scaleHeight = scrollViewFrame.size.height / scrollView.contentSize.height;
    CGFloat minScale = MIN(scaleWidth, scaleHeight);
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 1.0f;
    self.scrollView.zoomScale =minScale;
    
    [self centerScrollViewContents];
}

- (void)centerScrollViewContents {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = originalImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0;
    }
    
    originalImageView.frame = contentsFrame;
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return originalImageView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *output = [[UIBarButtonItem alloc] initWithTitle:@"Save" style:UIBarButtonItemStylePlain
                                                              target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = output;
    
    UIBarButtonItem *input = [[UIBarButtonItem alloc] initWithTitle:@"Album" style:UIBarButtonItemStylePlain
                                                             target:self action:@selector(input)];
    self.navigationItem.leftBarButtonItem = input;
    
    UIButton *camera = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    
    [[camera layer] setCornerRadius:7.0f];
    
    [camera setImage:[UIImage imageNamed:@"camera.png"] forState:UIControlStateNormal];
//    [camera addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = camera;
    
}

-(void)input{
    UIImagePickerController *photoPicker = [[UIImagePickerController alloc] init];
    photoPicker.delegate = self;
    photoPicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:photoPicker animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)photoPicker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
//    for (UIView* view in self.view.subviews) {
//        [view removeFromSuperview];
//    }

    originalImage = [[UIImage alloc] init];
    
    originalImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    originalImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, originalImage.size.width, originalImage.size.height)];
    
    layer_1 = [[MaskShape alloc] initWithFrame:CGRectMake(0,0,originalImage.size.width/5,originalImage.size.height/5)];
    layer_1.clipsToBounds =YES;
    [layer_1.layer setMasksToBounds:YES];
    layer_1.layer.borderColor = [UIColor redColor].CGColor;
    layer_1.layer.borderWidth = 2;
    layer_1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    layer_2 = [[UIView alloc] initWithFrame:layer_1.frame];
    layer_2.center = CGPointMake(layer_1.frame.size.width/2, layer_1.frame.size.height/2);
    layer_2.clipsToBounds =NO;
    
    layer_pixellate =[[UIImageView alloc] initWithFrame:self.originalImageView.frame];
    
    [layer_1 addSubview:layer_2];
    [layer_2 addSubview:layer_pixellate];
    
    PixellateImage* pixel = [[PixellateImage alloc] init];
    originalImageView.image = originalImage;
    layer_pixellate.image = [pixel pixellatePhoto:originalImage];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGestureCaptured:)];
    [originalImageView addGestureRecognizer:singleTap];
    [originalImageView setUserInteractionEnabled:YES];
    [scrollView setCanCancelContentTouches:YES];
    
    self.rotateGesture = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(handleRotate:)];
	[layer_1 addGestureRecognizer:self.rotateGesture];
    self.rotateGesture.delegate =self;
    
    self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    [layer_1 addGestureRecognizer:self.pinchGesture];
    self.pinchGesture.delegate = self;
    
    [self centerScrollViewContents];
    scrollView.contentSize = originalImageView.frame.size;
    [self.view addSubview:self.scrollView];
    [scrollView addSubview:originalImageView];
    [originalImageView addSubview:layer_1];
    
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if ((gestureRecognizer == self.pinchGesture && otherGestureRecognizer == self.rotateGesture) ||
        (gestureRecognizer == self.rotateGesture && otherGestureRecognizer == self.pinchGesture)) {
        return YES;
    }
    return NO;
}

-(void)scale:(UIPinchGestureRecognizer*)recognizer{
    CGPoint center = layer_1.center;
    if (rotation == 0){
        layer_1.frame = CGRectMake(0, 0, layer_1.frame.size.width * recognizer.scale, layer_1.frame.size.height * recognizer.scale);
        layer_1.center = center;
        layer_2.frame = layer_1.frame;
        layer_2.center = CGPointMake(layer_1.frame.size.width/2, layer_1.frame.size.height/2);
    }else{
        layer_1.bounds = CGRectMake(layer_1.bounds.origin.x, layer_1.bounds.origin.y, layer_1.bounds.size.width * recognizer.scale, layer_1.bounds.size.height * recognizer.scale);
        rotated = CGRectApplyAffineTransform(layer_1.bounds, layer_1.transform);
        [layer_2 setBounds:CGRectMake(layer_2.bounds.origin.x,layer_2.bounds.origin.y, rotated.size.width, rotated.size.height)];
        layer_1.center = center;
        layer_2.center = CGPointMake(layer_1.bounds.size.width/2, layer_1.bounds.size.height/2);
    }
    
    rotated = CGRectApplyAffineTransform([layer_1 bounds], [layer_1 transform]);
    [layer_2 setBounds:CGRectMake(0, 0, rotated.size.width, rotated.size.height)];
    [layer_pixellate setFrame:CGRectMake(-layer_1.frame.origin.x, -layer_1.frame.origin.y, layer_pixellate.frame.size.width, layer_pixellate.frame.size.height)];
    
    if (num == 1) {
        layer_1.layer.cornerRadius = layer_1.bounds.size.width/2;
    }else if (num == 2) {
        [layer_1.layer setCornerRadius:0];
        CAShapeLayer *shapeMask = [CAShapeLayer layer];
        UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:layer_1.bounds];
        shapeMask.path = someClosedUIBezierPath.CGPath;
        layer_1.layer.mask = shapeMask;
    }
    
    layer_1.layer.borderColor = [UIColor redColor].CGColor;
    layer_1.layer.borderWidth = 2;
//    layer_1.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    recognizer.scale = 1;
}

float rotation;
- (void)handleRotate:(UIRotationGestureRecognizer *)recognizer {
    layer_1.transform = CGAffineTransformMakeRotation(recognizer.rotation);
    layer_2.transform = CGAffineTransformMakeRotation(-recognizer.rotation);
    rotation = recognizer.rotation;
    NSLog(@"%f",recognizer.rotation);
}

- (void)singleTapGestureCaptured:(UITapGestureRecognizer *)gesture
{   
    touchPoint = [gesture locationInView:originalImageView];
    layer_1.center = touchPoint;
    rotated = CGRectApplyAffineTransform([layer_1 bounds], [layer_1 transform]);
    [layer_2 setBounds:CGRectMake(0, 0, rotated.size.width, rotated.size.height)];
    [layer_pixellate setFrame:CGRectMake(-layer_1.frame.origin.x, -layer_1.frame.origin.y, layer_pixellate.frame.size.width, layer_pixellate.frame.size.height)];

//    NSLog(@"%@ layer1 frame",NSStringFromCGRect(layer_1.frame));
//    NSLog(@"%@ layer2 frame",NSStringFromCGRect(layer_2.frame));
//    NSLog(@"%@ layer2 bounds",NSStringFromCGRect(layer_2.bounds));
}

- (IBAction)Rectange:(id)sender {
    num = 3;
    sliderRotate.value = 0;
    layer_1.transform = CGAffineTransformMakeRotation(0);
    layer_2.transform = CGAffineTransformMakeRotation(0);
    MaskShape* shape = [[MaskShape alloc] init];
    [shape is_Rectangle:layer_1];
    [layer_2 setFrame:layer_1.frame];
    layer_2.center = CGPointMake(layer_1.frame.size.width/2, layer_1.frame.size.height/2);
    [layer_pixellate setFrame:CGRectMake(-layer_1.frame.origin.x, -layer_1.frame.origin.y, layer_pixellate.frame.size.width, layer_pixellate.frame.size.height)];
}

- (IBAction)ellipse:(id)sender {
    num = 2;
    sliderRotate.value = 0;
    layer_1.transform = CGAffineTransformMakeRotation(0);
    layer_2.transform = CGAffineTransformMakeRotation(0);
    MaskShape* shape = [[MaskShape alloc] init];
    [shape is_Ellipse:layer_1];
    [layer_2 setFrame:layer_1.frame];
    layer_2.center = CGPointMake(layer_1.frame.size.width/2, layer_1.frame.size.height/2);
    [layer_pixellate setFrame:CGRectMake(-layer_1.frame.origin.x, -layer_1.frame.origin.y, layer_pixellate.frame.size.width, layer_pixellate.frame.size.height)];
}

- (IBAction)Circle:(id)sender {
    num = 1;
    sliderRotate.value = 0;
    layer_1.transform = CGAffineTransformMakeRotation(0);
    layer_2.transform = CGAffineTransformMakeRotation(0);
    MaskShape* shape = [[MaskShape alloc] init];
    [shape is_Circle:layer_1];
    [layer_2 setFrame:layer_1.frame];
    layer_2.center = CGPointMake(layer_1.frame.size.width/2, layer_1.frame.size.height/2);
    [layer_pixellate setFrame:CGRectMake(-layer_1.frame.origin.x, -layer_1.frame.origin.y, layer_pixellate.frame.size.width, layer_pixellate.frame.size.height)];
}

-(void)save{
    
    if(num == 2) {
//        CGPoint center = layer_1.center;
        UIImageView* subSelectedView = [[UIImageView alloc] initWithFrame:layer_1.bounds];
        subSelectedView.tag = 1;
        subSelectedView.center = layer_1.center;
        UIGraphicsBeginImageContext(layer_1.bounds.size);
        CGContextRef context1 = UIGraphicsGetCurrentContext();
        [layer_1.layer renderInContext:context1];
        UIImage* renderImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        subSelectedView.transform = layer_1.transform;
        subSelectedView.image = [self maskImage:renderImage withMask:[UIImage imageNamed:@"elip.jpg"]];
        [layer_1 removeFromSuperview];
        [originalImageView addSubview: subSelectedView];
    }
    
    CGSize captureSize = CGSizeMake(originalImageView.bounds.size.width /scrollView.zoomScale, originalImageView.bounds.size.height /scrollView.zoomScale);
    UIGraphicsBeginImageContextWithOptions(captureSize, YES , 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1/scrollView.zoomScale, 1/scrollView.zoomScale);
    [originalImageView.layer renderInContext:context];
//    if (num == 2) {
//        CGContextSetLineWidth(context, 2.0);
//        
//        CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//        
//        CGContextAddEllipseInRect(context, layer_1.frame);
//        
//        CGContextStrokePath(context);
//    }
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(newImage, nil, nil, nil);
   
    UIAlertView *success = [[UIAlertView alloc] initWithTitle:@"Success"
                                                      message:@"The photo saved in Photo Library"
                                                     delegate:nil
                                            cancelButtonTitle:@"OK"
                                            otherButtonTitles:nil];
    [success show];
}

- (UIImage*) maskImage:(UIImage *) image withMask:(UIImage *) mask
{
    CGImageRef imageReference = image.CGImage;
    CGImageRef maskReference = mask.CGImage;
    
    CGImageRef imageMask = CGImageMaskCreate(CGImageGetWidth(maskReference),
                                             CGImageGetHeight(maskReference),
                                             CGImageGetBitsPerComponent(maskReference),
                                             CGImageGetBitsPerPixel(maskReference),
                                             CGImageGetBytesPerRow(maskReference),
                                             CGImageGetDataProvider(maskReference),
                                             NULL,
                                             YES
                                             );
    
    CGImageRef maskedReference = CGImageCreateWithMask(imageReference, imageMask);
    CGImageRelease(imageMask);
    
    UIImage *maskedImage = [UIImage imageWithCGImage:maskedReference];
    CGImageRelease(maskedReference);
    
    return maskedImage;
}
@end