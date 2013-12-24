//
//  SetCardView.m
//  DyanamicMatchismo
//
//  Created by Ethan Petuchowski on 12/20/13.
//  Copyright (c) 2013 Ethan Petuchowski. All rights reserved.
//

#import "SetCardView.h"

@implementation SetCardView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// TODO
- (void)animateChooseCard
{
    
}

#define SHAPE_INSET_PROPORTION 0.7

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    // TODO draw the card face in here
    
    // TODO THIS IS ALLL WRONG BECAUSE I NEED TO DRAW
    // THE RIGHT /NUMBER/ OF EACH TYPE OF SHAPE!!
    
    // still not sure how to accomplish this for all the shapes
    
    CGRect shapeBounds = CGRectInset(self.frame,
                                     SHAPE_INSET_PROPORTION,
                                     SHAPE_INSET_PROPORTION);

    CGFloat left   = shapeBounds.origin.x;
    CGFloat top    = shapeBounds.origin.y;
    CGFloat right  = shapeBounds.origin.x + shapeBounds.size.width;
    CGFloat bottom = shapeBounds.origin.y + shapeBounds.size.height;
    CGFloat hMid   = shapeBounds.origin.x + shapeBounds.size.width/2;
    CGFloat vMid   = shapeBounds.origin.y + shapeBounds.size.height/2;
    
    CGPoint topMiddle    = CGPointMake(hMid, top);
    CGPoint rightMiddle  = CGPointMake(right, vMid);
    CGPoint bottomMiddle = CGPointMake(hMid, bottom);
    CGPoint leftMiddle   = CGPointMake(left, vMid);
//    CGPoint middleMiddle = CGPointMake(hMid, vMid);
//    CGPoint topRight     = CGPointMake(right, top);
//    CGPoint bottomRight  = CGPointMake(right, bottom);
//    CGPoint bottomLeft   = CGPointMake(left, bottom);
//    CGPoint topLeft      = CGPointMake(left, top);
    
    UIBezierPath *shapeOutline = [[UIBezierPath alloc] init];
    
    // DRAW DIAMOND
    if ([self.card.shape isEqualToString:@"Diamond"]) {
        [shapeOutline moveToPoint:topMiddle];
        [shapeOutline addLineToPoint:rightMiddle];
        [shapeOutline addLineToPoint:bottomMiddle];
        [shapeOutline addLineToPoint:leftMiddle];
        [shapeOutline closePath];
    }
    
    // DRAW OVAL
    else if ([self.card.shape isEqualToString:@"Oval"]) {
        shapeOutline = [UIBezierPath bezierPathWithOvalInRect:shapeBounds];
    }
    
    // DRAW SQUIGGLE (uh oh...)
    else if ([self.card.shape isEqualToString:@"Squiggle"]) {
        [shapeOutline moveToPoint:topMiddle];
        // TODO
    }
    
    else [NSException raise:@"Invalid card shape" format:@"%@", self.card.shape];
    
    // COLOR
    UIColor *cardColor = self.card.colorDict[self.card.color];
    [cardColor set]; // does a setFill /and/ a setStroke
    
    // SOLID
    if ([self.card.fillType isEqualToString:@"Solid"]) {
        [shapeOutline fill];
    }
    
    // UNFILLED
    else if ([self.card.fillType isEqualToString:@"Unfilled"]) {
        [shapeOutline stroke];
    }
    
    // STRIPED (uh oh...)
    else if ([self.card.fillType isEqualToString:@"Striped"]) {
        // ???
    }
    
    else [NSException raise:@"Invalid card fillType" format:@"%@", self.card.fillType];
    
    // differentiate it when it's chosen
    if (self.thinksItsChosen) {} else {}
}


@end
