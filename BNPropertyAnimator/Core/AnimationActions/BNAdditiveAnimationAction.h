//
//  BNAdditiveAnimationAction.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNAnimationAction.h"
#import "BNPropertyAnimator.h"

NS_ASSUME_NONNULL_BEGIN

@interface BNAdditiveAnimationAction : BNAnimationAction

- (instancetype)initWithEvent:(NSString *)event
                        delay:(NSTimeInterval)delay
                     animator:(BNPropertyAnimator *)animator
                     forLayer:(nonnull CALayer *)layer;

@end

NS_ASSUME_NONNULL_END
