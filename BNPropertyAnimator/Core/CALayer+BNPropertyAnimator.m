//
//  CALayer+BNPropertyAnimator.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "CALayer+BNPropertyAnimator.h"
#import "BNMacros.h"
#import "BNUtils.h"
#import "BNTransaction.h"

@implementation CALayer (BNPropertyAnimator)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BNSwizzleMethod([self class],
                        @selector(actionForKey:),
                        [self class],
                        @selector(bn_actionForKey:));
    });
}

- (id<CAAction>)bn_actionForKey:(NSString *)event {
    BNTransaction *lastTransaction = [BNTransaction lastTransaction];
    if (lastTransaction) {
        __weak id<BNTransactionDelegate> delegate = lastTransaction.delegate;
        if (delegate) {
            id<CAAction> action = [delegate actionInTransaction:lastTransaction
                                                       forLayer:self
                                                         forKey:event];
            if (action) {
                return action;
            }
        }
    }
    // Passes the ball to UIKit's implementation if there is no active transaction.
    return [self bn_actionForKey:event];
}

+ (BOOL)bn_isAdditiveKeyPath:(NSString *)keyPath {
    return (BOOL)[[self class] bn_toValueForAdditiveAnimationWithKeyPath:keyPath];
}

+ (id)bn_toValueForAdditiveAnimationWithKeyPath:(NSString *)keyPath {
    id value = [[self class] bn_toValueForAdditiveAnimationMap][keyPath];
    if (!value && [self class] != [CALayer class]) {
        return [[[self class] superclass] bn_toValueForAdditiveAnimationWithKeyPath:keyPath];
    }
    return value;
}

+ (NSDictionary *)bn_toValueForAdditiveAnimationMap {
    static NSDictionary *keyPaths = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        keyPaths = @{
            @"bounds.origin" : [NSValue valueWithCGPoint:CGPointZero],
            @"bounds.size" : [NSValue valueWithCGSize:CGSizeZero],
            @"position" : [NSValue valueWithCGPoint:CGPointZero],
            @"position.x" : @(0.0),
            @"position.y" : @(0.0),
            @"opacity" : @(0.0),
            @"transform" : [NSValue valueWithCATransform3D:CATransform3DIdentity],
        };
    });
    return keyPaths;
}

@end
