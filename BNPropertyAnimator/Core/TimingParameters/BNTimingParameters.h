//
//  BNTimingParameters.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "BNMacros.h"
#import "BNTimingCurveProvider.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    BNAnimationCurveEaseInOut   = 0,
    BNAnimationCurveEaseIn      = 1,
    BNAnimationCurveEaseOut     = 2,
    BNAnimationCurveLinear      = 3,
} BNAnimationCurve;

@interface BNCubicTimingParameters : NSObject <BNTimingCurveProvider>

@property (nonatomic, readonly) BNAnimationCurve animationCurve;
@property (nonatomic, readonly) CGPoint controlPoint1;
@property (nonatomic, readonly) CGPoint controlPoint2;

- (instancetype)initWithAnimationCurve:(BNAnimationCurve)curve BN_DESIGNATED_INITIALIZER;
- (instancetype)initWithControlPoint1:(CGPoint)point1 controlPoint2:(CGPoint)point2 BN_DESIGNATED_INITIALIZER;

@end

/* Available on iOS 9.0 or later */
@interface BNSpringTimingParameters : NSObject <BNTimingCurveProvider>

/* The mass of the object attached to the end of the spring. Must be greater
 * than 0. Defaults to 1. */
@property (nonatomic, readonly) CGFloat mass;

/* The spring stiffness coefficient. Must be greater than 0.
 * Defaults to 100. */
@property (nonatomic, readonly) CGFloat stiffness;

/* The damping coefficient. Must be greater than or equal to 0.
 * Defaults to 10. */
@property (nonatomic, readonly) CGFloat damping;

/* The initial velocity of the object attached to the spring animation.
 * Defaults to 0. */
@property (nonatomic, readonly) CGFloat initialVelocity;

- (instancetype)initWithMass:(CGFloat)mass
                   stiffness:(CGFloat)stiffness
                     damping:(CGFloat)damping
             initialVelocity:(CGFloat)velocity BN_DESIGNATED_INITIALIZER;

@end

NS_ASSUME_NONNULL_END
