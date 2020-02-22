//
//  BNAnimationActionGroup.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNAnimationAction.h"

NS_ASSUME_NONNULL_BEGIN

/* An object that allows multiple animation actions
 * to be grouped and run concurrently. */

@interface BNAnimationActionGroup : BNAnimationAction <BNAnimationActionDelegate>

/* An array of id<BNAnimationAction> objects. Each member of the array will run
 * concurrently in the time space of the parent action
 * The order of actions can be different from the initial actions. */

@property(nonnull, copy, readonly) NSArray<BNAnimationAction *> *actions;

- (instancetype)initWithActions:(NSArray<BNAnimationAction *> *)actions;

@end

NS_ASSUME_NONNULL_END
