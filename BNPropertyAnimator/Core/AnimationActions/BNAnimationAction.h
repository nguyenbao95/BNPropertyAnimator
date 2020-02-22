//
//  BNAnimationAction.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class BNAnimationAction;

@protocol BNAnimationAction <CAAction>

@property (nonnull, nonatomic, readonly) NSString *identifier;

@end

@protocol BNAnimationActionDelegate <NSObject>
@optional

/* Called when the animation associcated to action either completes or
 * is removed from the object it is attached to (i.e. the layer). 'flag'
 * is true if the animation reached the end of its active duration
 * without being removed. */
- (void)actionDidStop:(BNAnimationAction *)action finished:(BOOL)flag;

@end


@interface BNAnimationAction : NSObject <BNAnimationAction> {
    NSString *_identifier; // Identifier of the action.
    __weak id<BNAnimationActionDelegate> _delegate;
}

/* The delegate of the action. Defaults to nil.
 * See below for the supported delegate methods. */
@property (nullable, nonatomic, weak) id<BNAnimationActionDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
