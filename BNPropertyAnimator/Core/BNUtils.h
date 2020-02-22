//
//  BNUtils.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import "BNTimingParameters.h"
#import "BNMacros.h"

NS_ASSUME_NONNULL_BEGIN

BN_EXTERN void BNSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector);

BN_EXTERN id BNInvertAdditiveProperty(id fromValue, id toValue);

// Throw exception if either cp1 or cp2 is null.
BN_EXTERN void BNControlPointsForAnimationCurve(BNAnimationCurve curve, CGPoint *cp1, CGPoint *cp2);

NS_ASSUME_NONNULL_END
