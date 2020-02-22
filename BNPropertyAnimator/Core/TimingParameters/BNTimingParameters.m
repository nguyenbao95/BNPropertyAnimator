//
//  BNTimingParameters.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNTimingParameters.h"

#define _BNAnimationCurveDefault -1

@implementation BNCubicTimingParameters

- (instancetype)init {
    return [self initWithAnimationCurve:BNAnimationCurveEaseInOut];
}

- (instancetype)initWithAnimationCurve:(BNAnimationCurve)curve {
    self = [super init];
    if (self) {
        _animationCurve = curve;
    }
    return self;
}

- (instancetype)initWithControlPoint1:(CGPoint)point1 controlPoint2:(CGPoint)point2 {
    self = [super init];
    if (self) {
        _animationCurve = _BNAnimationCurveDefault;
        _controlPoint1 = point1;
        _controlPoint2 = point2;
    }
    return self;
}

#pragma mark - BNTimingCurveProvider

- (BNCubicTimingParameters *)cubicTimingParameters {
    if (_animationCurve >= 0) {
        return [[BNCubicTimingParameters alloc] initWithAnimationCurve:_animationCurve];
    }
    return [[BNCubicTimingParameters alloc] initWithControlPoint1:_controlPoint1 controlPoint2:_controlPoint2];
}

- (BNSpringTimingParameters *)springTimingParameters {
    return nil;
}

@end

@implementation BNSpringTimingParameters

- (instancetype)init {
    return [self initWithMass:1 stiffness:100 damping:10 initialVelocity:0];
}

- (instancetype)initWithMass:(CGFloat)mass stiffness:(CGFloat)stiffness damping:(CGFloat)damping initialVelocity:(CGFloat)velocity {
    self = [super init];
    if (self) {
        _mass = mass;
        _stiffness = stiffness;
        _damping = damping;
        _initialVelocity = velocity;
    }
    return self;
}

#pragma mark - BNTimingCurveProvider

- (BNCubicTimingParameters *)cubicTimingParameters {
    return nil;
}

- (BNSpringTimingParameters *)springTimingParameters {
    return [[BNSpringTimingParameters alloc] initWithMass:_mass
                                                stiffness:_stiffness
                                                  damping:_damping
                                          initialVelocity:_initialVelocity];
}

@end
