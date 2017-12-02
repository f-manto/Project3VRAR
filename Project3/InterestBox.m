//
//  InterestBox.m
//  ARKitBasics
//
//  Created by Francesco Mantovani on 30/11/2017.
//  Copyright © 2017 Apple. All rights reserved.
//

#import "InterestBox.h"

#define EDGE_LENGTH 10.0

@implementation InterestBox

-(void)drawRect:(CGRect)rect {
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor redColor] setStroke];
    CGFloat lineWidth=3;
    CGRect box = CGRectInset(self.bounds, lineWidth/2.0, lineWidth/2.0);
    CGContextSetLineWidth(ctx, lineWidth);
    CGFloat minX = CGRectGetMinX(box);
    CGFloat minY = CGRectGetMinY(box);
    CGFloat maxX = CGRectGetMaxX(box);
    CGFloat maxY = CGRectGetMaxY(box);
    CGContextMoveToPoint(ctx, minX, minY + EDGE_LENGTH);
    CGContextAddLineToPoint(ctx, minX, minY);
    CGContextAddLineToPoint(ctx, minX +  EDGE_LENGTH, minY);

    CGContextMoveToPoint(ctx, minX, maxY - EDGE_LENGTH);
    CGContextAddLineToPoint(ctx, minX, maxY);
    CGContextAddLineToPoint(ctx, minX +  EDGE_LENGTH, maxY);
    CGContextMoveToPoint(ctx, maxX - EDGE_LENGTH, minY);
    CGContextAddLineToPoint(ctx, maxX, minY);
    CGContextAddLineToPoint(ctx, maxX, minY +  EDGE_LENGTH);
    CGContextMoveToPoint(ctx, maxX - EDGE_LENGTH, maxY);
    CGContextAddLineToPoint(ctx, maxX, maxY);
    CGContextAddLineToPoint(ctx, maxX, maxY -  EDGE_LENGTH);
    CGContextStrokePath(ctx);
}

@end
