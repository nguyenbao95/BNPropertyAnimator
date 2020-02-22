//
//  CALayer+BNPropertyAnimator.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer (BNPropertyAnimator)

/* Return YES if this key path can be animated additively, otherwise returns NO. */
+ (BOOL)bn_isAdditiveKeyPath:(NSString *)keyPath;

/* Returns **toValue** for additive animation associated to a given key path. */
+ (id)bn_toValueForAdditiveAnimationWithKeyPath:(NSString *)keyPath;

@end

NS_ASSUME_NONNULL_END
