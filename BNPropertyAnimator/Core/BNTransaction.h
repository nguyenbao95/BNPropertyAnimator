//
//  BNTransaction.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@class BNTransaction;

@protocol BNTransactionDelegate <NSObject>
@optional

/* Called by the default implementation of the -actionForKey: method.
 * Should return an object implementing the CAAction protocol.
 * May return 'nil' if the delegate doesn't specify a behavior for the current event.
 * Returning the NSNull explicitly forces no further search. */
- (id<CAAction>)actionInTransaction:(BNTransaction *)transaction forLayer:(CALayer *)layer forKey:(NSString *)event;

@end

@interface BNTransaction : NSObject

/* Begin a new transaction. */
+ (void)begin:(BNTransaction *)transaction;

/* Commit all changes made during the current transaction.
 * Raises an exception if no current transaction exists. */
+ (void)commit;

/* Returns nil if no current transaction exists. */
+ (BNTransaction *)lastTransaction;

@property (nullable, nonatomic, weak) id<BNTransactionDelegate> delegate;

/* The amount of time (seconds) to wait before beginning the animations.
 * Defaults to 0. */
@property (nonatomic, assign) NSTimeInterval delay;

- (instancetype)init;

@end

NS_ASSUME_NONNULL_END
