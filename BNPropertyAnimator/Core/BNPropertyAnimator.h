//
//  BNPropertyAnimator.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BNMacros.h"
#import "BNTimingParameters.h"

NS_ASSUME_NONNULL_BEGIN

@interface BNPropertyAnimator : NSObject

@property (nonatomic, readonly) BOOL running;
@property (nonatomic, readonly) NSTimeInterval duration;
@property (nonatomic, readonly) id<BNTimingCurveProvider> timingParameters;

- (instancetype)init BN_UNAVAILABLE;
- (instancetype)initWithDuration:(NSTimeInterval)duration timingParameters:(id<BNTimingCurveProvider>)parameters BN_DESIGNATED_INITIALIZER;

// Adds animations with a given block.
- (void)addAnimations:(void(^)(void))animation;

// The given completion will be called when the animation is completed.
- (void)addCompletion:(void(^)(BOOL finished))completion;

// Starts the animation.
- (void)startAnimation;

// Starts the animation after the given delay.
- (void)startAnimationAfterDelay:(NSTimeInterval)delay;

@end


@interface BNPropertyAnimator (BNAnimationWithBlocks)

/* Set of convenient methods helping to animate changes to one or more views/layers
 * using the specified duration, delay, timing parameters, and completion handler. */

// Delay = 0.0, completion = NULL and ease in/out curve.
+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void(^)(void))animations;

// Delay = 0.0 and ease in/out curve.
+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void(^)(void))animations
                 completion:(void(^ __nullable)(BOOL finished))completion;

// Animate changes with cubic curve.
+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                      curve:(BNAnimationCurve)curve
                 animations:(void(^)(void))animations
                 completion:(void(^ __nullable)(BOOL finished))completion;

// You can specify your own timing parameters.
+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
           timingParameters:(id<BNTimingCurveProvider>)parameters
                 animations:(void(^)(void))animations
                 completion:(void(^ __nullable)(BOOL finished))completion;

@end

NS_ASSUME_NONNULL_END
