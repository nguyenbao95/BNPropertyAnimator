//
//  BNPropertyAnimator.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNPropertyAnimator.h"
#import "BNTransaction.h"
#import "BNTimingParameters.h"
#import "BNAnimationAction.h"
#import "BNAdditiveAnimationAction.h"
#import "BNAnimationActionGroup.h"

typedef void(^BNAnimationBlock)(void);

@interface BNPropertyAnimator () <BNTransactionDelegate, BNAnimationActionDelegate> {
    NSMutableArray *_animationBlocks;
    NSMutableArray *_completionBlocks;
    NSMutableArray *_allActions;
    
    BNAnimationAction *_combinedAction;
}

@end

@implementation BNPropertyAnimator

- (instancetype)initWithDuration:(NSTimeInterval)duration timingParameters:(id<BNTimingCurveProvider>)parameters {
    self = [super init];
    if (self) {
        _animationBlocks = [[NSMutableArray alloc] init];
        _completionBlocks = [[NSMutableArray alloc] init];
        _allActions = [[NSMutableArray alloc] init];
        _duration = duration;
        _timingParameters = parameters;
    }
    return self;
}

- (void)addAnimations:(void(^)(void))animation {
    if (_running) {
        return;
    }
    [_animationBlocks addObject:animation];
}

- (void)addCompletion:(void(^)(BOOL finished))completion {
    if (_running) {
        return;
    }
    [_completionBlocks addObject:completion];
}

- (void)startAnimation {
    if (_running) {
        return;
    }
    [self _startAnimationAfterDelay:0.0];
}

- (void)startAnimationAfterDelay:(NSTimeInterval)delay {
    [self _startAnimationAfterDelay:delay];
}

- (void)_startAnimationAfterDelay:(NSTimeInterval)delay {
    // Marks as running.
    _running = YES;
    
    BNTransaction *transaction = [[BNTransaction alloc] init];
    transaction.delegate = self;
    transaction.delay = delay;
    
    // Begin new transaction
    [BNTransaction begin:transaction];
    
    // Performs all animation blocks. All updates will be caught in [CALayer bn_actionForKey:]
    for (BNAnimationBlock animation in _animationBlocks) {
        animation();
    }
    
    // End the transaction.
    [BNTransaction commit];
    
    
    // Combine all actions into one.
    BNAnimationActionGroup *actionGroup = [[BNAnimationActionGroup alloc] initWithActions:_allActions];
    actionGroup.delegate = self;
    
    for (BNAnimationAction *action in _allActions) {
        action.delegate = actionGroup;
    }
    _combinedAction = actionGroup;
    
    // Remove animation blocks to release all properties captured inside them.
    [_animationBlocks removeAllObjects];
}

- (void)_finalizeAnimationsAsFinished:(BOOL)finished {
    [self _executeCompletionBlocksAsFinished:finished];
    [self _cleanUp];
}

- (void)_executeCompletionBlocksAsFinished:(BOOL)finished {
    for (void(^completion)(BOOL) in _completionBlocks) {
        completion(finished);
    }
}

- (void)_cleanUp {
    _running = NO;
    _combinedAction.delegate = nil;
    _combinedAction = nil;
    [_allActions removeAllObjects];
    [_animationBlocks removeAllObjects];
    [_completionBlocks removeAllObjects];
}

#pragma mark - BNTransactionDelegate

- (id<CAAction>)actionInTransaction:(BNTransaction *)transaction forLayer:(CALayer *)layer forKey:(NSString *)event {
    BNAnimationAction *action = nil;
    
    if ([event isEqualToString:@"bounds"]) {
        BNAnimationAction *originAction, *sizeAction;
        originAction = [[BNAdditiveAnimationAction alloc]
                        initWithEvent:@"bounds.origin"
                        delay:transaction.delay
                        animator:self
                        forLayer:layer];
        sizeAction = [[BNAdditiveAnimationAction alloc]
                      initWithEvent:@"bounds.size"
                      delay:transaction.delay
                      animator:self
                      forLayer:layer];
        
        action = [[BNAnimationActionGroup alloc] initWithActions:@[originAction, sizeAction]];
    }
    else if ([event isEqualToString:@"position"]) {
        BNAnimationAction *dxAction, *dyAction;
        dxAction = [[BNAdditiveAnimationAction alloc]
                        initWithEvent:@"position.x"
                        delay:transaction.delay
                        animator:self
                        forLayer:layer];
        dyAction = [[BNAdditiveAnimationAction alloc]
                    initWithEvent:@"position.y"
                    delay:transaction.delay
                    animator:self
                    forLayer:layer];
        
        action = [[BNAnimationActionGroup alloc] initWithActions:@[dxAction, dyAction]];
    }
    else {
        action = [[BNAdditiveAnimationAction alloc]
                  initWithEvent:event
                  delay:transaction.delay
                  animator:self
                  forLayer:layer];
    }
    
    // Save the created action.
    [_allActions addObject:action];
    
    return action;
}

#pragma mark - BNAnimationActionDelegate

- (void)actionDidStop:(BNAnimationAction *)action finished:(BOOL)flag {
    if (action == _combinedAction) {
        [self _finalizeAnimationsAsFinished:flag];
    }
}

@end

@interface BNPropertyAnimator (BNAnimationWithBlocks_Private)

@property (class, readonly, strong) NSMutableDictionary *activeAnimators;

@end

@implementation BNPropertyAnimator (BNAnimationWithBlocks)

+ (NSMutableDictionary *)activeAnimators {
    static dispatch_once_t onceToken;
    static NSMutableDictionary *activeAnimators;
    dispatch_once(&onceToken, ^{
        activeAnimators = [[NSMutableDictionary alloc] init];
    });
    return activeAnimators;
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void(^)(void))animations {
    [self animateWithDuration:duration
                   animations:animations
                   completion:nil];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                 animations:(void(^)(void))animations
                 completion:(void(^ __nullable)(BOOL finished))completion {
    [self animateWithDuration:duration
                        delay:0.0
                        curve:BNAnimationCurveEaseInOut
                   animations:animations
                   completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
                      curve:(BNAnimationCurve)curve
                 animations:(void(^)(void))animations
                 completion:(void(^ __nullable)(BOOL finished))completion {
    id<BNTimingCurveProvider> parameters = [[BNCubicTimingParameters alloc] initWithAnimationCurve:curve];
    [self animateWithDuration:duration
                        delay:delay
             timingParameters:parameters
                   animations:animations
                   completion:completion];
}

+ (void)animateWithDuration:(NSTimeInterval)duration
                      delay:(NSTimeInterval)delay
           timingParameters:(id<BNTimingCurveProvider>)parameters
                 animations:(void(^)(void))animations
                 completion:(void(^ __nullable)(BOOL finished))completion {
    NSAssert(animations != nil, @"animations must not be nil!");
    NSAssert(parameters != nil, @"timingParameters must not be nil!");
    
    BNPropertyAnimator *animator = [[BNPropertyAnimator alloc] initWithDuration:duration timingParameters:parameters];
    
    NSString *animatorID = [NSString stringWithFormat:@"%p", animator];
    self.activeAnimators[animatorID] = animator;
    
    [animator addAnimations:animations];
    [animator addCompletion:^(BOOL finished) {
        [self.activeAnimators removeObjectForKey:animatorID];
        
        if (completion) {
            completion(finished);
        }
    }];
    
    [animator startAnimationAfterDelay:delay];
}

@end
