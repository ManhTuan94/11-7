//
//  PixellateImage.m
//  demoPhoto
//
//  Created by TOM on 7/6/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "PixellateImage.h"
#import "GPUImage.h"

@implementation PixellateImage
-(UIImage*)pixellatePhoto:(UIImage*)originalImage{
    GPUImagePicture* _picture = [[GPUImagePicture alloc] initWithImage:originalImage];
    GPUImagePixellateFilter* pixellateFilter= [[GPUImagePixellateFilter alloc] init];
    pixellateFilter.fractionalWidthOfAPixel = 0.015;
    [_picture addTarget:pixellateFilter];
    [_picture processImage];
    UIImage *successImage = [pixellateFilter imageFromCurrentlyProcessedOutput];
    return successImage;
}
@end
