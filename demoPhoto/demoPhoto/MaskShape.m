//
//  MaskShape.m
//  demoPhoto
//
//  Created by TOM on 7/6/13.
//  Copyright (c) 2013 TechmasterVietNam. All rights reserved.
//

#import "MaskShape.h"

@implementation MaskShape

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)is_Rectangle:(MaskShape*)shape{
    CGPoint center = shape.center;
    [shape setFrame:CGRectMake(0, 0, 300,200)];
    shape.center = center;
    shape.layer.mask = nil;
    [shape.layer setCornerRadius:0];
}
-(void)is_Circle:(MaskShape*)shape{
    shape.layer.mask = nil;
    CGPoint center = shape.center;
    [shape setFrame:CGRectMake(0, 0, 200,200)];
    shape.center = center;
    [shape.layer setCornerRadius:shape.frame.size.width/2];
}
-(void)is_Ellipse:(MaskShape*)shape{
    shape.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    CGPoint center = shape.center;
    [shape setFrame:CGRectMake(0, 0, 300,200)];
    shape.center = center;
    [shape.layer setCornerRadius:0];
    CAShapeLayer *shapeMask = [CAShapeLayer layer];
    UIBezierPath *someClosedUIBezierPath = [UIBezierPath bezierPathWithOvalInRect:shape.bounds];
    shapeMask.path = someClosedUIBezierPath.CGPath;
    shape.layer.mask = shapeMask;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
