//
//  BNUtils.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNUtils.h"
#import <objc/runtime.h>

void BNSwizzleMethod(Class originalCls, SEL originalSelector, Class swizzledCls, SEL swizzledSelector) {
    Method originalMethod = class_getInstanceMethod(originalCls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(swizzledCls, swizzledSelector);
    
    BOOL didAddMethod =
    class_addMethod(originalCls,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    
    if (didAddMethod) {
        class_replaceMethod(originalCls,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

void invertValues(double *from, double *to, double *inverse, int count) {
    for (int i = 0; i < count; ++i) {
        inverse[i] = from[i] - to[i];
    }
}

id invertCGFloat(CGFloat fromValue, CGFloat toValue) {
    CGFloat inverse = fromValue - toValue;
    return [NSNumber numberWithDouble:inverse];
}

id invertCGColorRef(CGColorRef fromValue, CGColorRef toValue) {
    UIColor *f = [UIColor colorWithCGColor:fromValue];
    double from[4];
    [f getHue:from saturation:from + 1 brightness:from + 2 alpha:from + 3];
    
    UIColor *t = [UIColor colorWithCGColor:toValue];
    double to[4];
    [t getHue:to saturation:to + 1 brightness:to + 2 alpha:to + 3];
    
    double inverse[4];
    invertValues(from, to, inverse, 4);
    return (id)[UIColor colorWithHue:inverse[0] saturation:inverse[1] brightness:inverse[2] alpha:inverse[3]].CGColor;
}

id invertCATransform3D(CATransform3D fromValue, CATransform3D toValue) {
    return [NSValue valueWithCATransform3D:CATransform3DConcat(fromValue, CATransform3DInvert(toValue))];
}

id invertCGRect(CGRect fromValue, CGRect toValue) {
    double from[] = {fromValue.origin.x, fromValue.origin.y, fromValue.size.width, fromValue.size.height};
    double to[] = {toValue.origin.x, toValue.origin.y, toValue.size.width, toValue.size.height};
    
    double inverse[4];
    invertValues(from, to, inverse, 4);
    CGRect rect = CGRectMake(inverse[0], inverse[1], inverse[2], inverse[3]);
    return [NSValue valueWithCGRect:rect];
}

id invertCGPoint(CGPoint fromValue, CGPoint toValue) {
    double from[] = {fromValue.x, fromValue.y};
    double to[] = {toValue.x, toValue.y};
    
    double inverse[2];
    invertValues(from, to, inverse, 2);
    CGPoint point = CGPointMake(inverse[0], inverse[1]);
    return [NSValue valueWithCGPoint:point];
}

id invertCGSize(CGSize fromValue, CGSize toValue) {
    double from[] = {fromValue.width, fromValue.height};
    double to[] = {toValue.width, toValue.height};
    
    double inverse[2];
    invertValues(from, to, inverse, 2);
    CGSize size = CGSizeMake(inverse[0], inverse[1]);
    return [NSValue valueWithCGSize:size];
}

id BNInvertAdditiveProperty(id fromValue, id toValue) {
    if ([fromValue isKindOfClass:NSNumber.class] &&
        [toValue isKindOfClass:NSNumber.class]) {
        return invertCGFloat([(NSNumber *)fromValue doubleValue], [(NSNumber *)toValue doubleValue]);
    }
    
    if ((CFGetTypeID((__bridge CFTypeRef)fromValue) == CGColorGetTypeID()) &&
        (CFGetTypeID((__bridge CFTypeRef)toValue) == CGColorGetTypeID())) {
        CGColorRef fromColor = (CGColorRef)CFBridgingRetain(fromValue);
        CGColorRef toColor = (CGColorRef)CFBridgingRetain(toValue);
        
        return invertCGColorRef(fromColor, toColor);
    }
    
    if ([fromValue isKindOfClass:NSValue.class] &&
        [toValue isKindOfClass:NSValue.class] &&
        (strcmp([fromValue objCType], [toValue objCType]) == 0)) {
        if (strcmp([fromValue objCType], @encode(CATransform3D)) == 0) {
            return invertCATransform3D([fromValue CATransform3DValue], [toValue CATransform3DValue]);
        }
        
        if (strcmp([fromValue objCType], @encode(CGRect)) == 0) {
            return invertCGRect([fromValue CGRectValue], [toValue CGRectValue]);
        }
        
        if (strcmp([fromValue objCType], @encode(CGPoint)) == 0) {
            return invertCGPoint([fromValue CGPointValue ], [toValue CGPointValue]);
        }
        
        if (strcmp([fromValue objCType], @encode(CGSize)) == 0) {
            return invertCGSize([fromValue CGSizeValue], [toValue CGSizeValue]);
        }
    }
    return nil;
}

void BNControlPointsForAnimationCurve(BNAnimationCurve curve, CGPoint *cp1, CGPoint *cp2) {
    NSCAssert(cp1 != nil && cp2 != nil, @"cp1 and cp2 must not be nil");
    
    switch (curve) {
        case BNAnimationCurveEaseInOut:
            *cp1 = CGPointMake(0.42, 0.0);
            *cp2 = CGPointMake(0.58, 1.0);
            break;
        case BNAnimationCurveEaseIn:
            *cp1 = CGPointMake(0.42, 0.0);
            *cp2 = CGPointMake(1.0, 1.0);
            break;
        case BNAnimationCurveEaseOut:
            *cp1 = CGPointMake(0.0, 0.0);
            *cp2 = CGPointMake(0.58, 1.0);
            break;
        case BNAnimationCurveLinear:
            *cp1 = CGPointMake(0.0, 0.0);
            *cp2 = CGPointMake(1.0, 1.0);
            break;
        default:
            *cp1 = CGPointMake(0.25, 0.1);
            *cp2 = CGPointMake(0.25, 1.0);
            break;
    }
}
