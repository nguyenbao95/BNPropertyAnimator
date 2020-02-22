//
//  BNAnimationActionGroup.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNAnimationActionGroup.h"

@interface BNAnimationActionGroup () {
    NSMutableDictionary *_actions;
    NSMutableSet *_finishedActions;
}

@end

@implementation BNAnimationActionGroup

- (instancetype)initWithActions:(NSArray<BNAnimationAction *> *)actions {
    self = [super init];
    if (self) {
        NSAssert(actions != nil, @"actions must not be nil");
        _actions = [[NSMutableDictionary alloc] init];
        _finishedActions = [[NSMutableSet alloc] init];
        _identifier = [NSString stringWithFormat:@"%p", self];
        
        for (BNAnimationAction *action in actions) {
            NSString *actionID = action.identifier;
            [_actions setObject:action forKey:actionID];
        }
    }
    return self;
}

- (void)_clearAllActions {
    [_finishedActions removeAllObjects];
    [_actions removeAllObjects];
}

#pragma mark - Getters/Setters

- (NSArray<BNAnimationAction *> *)actions {
    return _actions.allValues;
}

#pragma mark - BNAnimationAction

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(nullable NSDictionary *)dict {
    for (BNAnimationAction *action in _actions.allValues) {
        action.delegate = self;
        [action runActionForKey:event object:anObject arguments:dict];
    }
}

#pragma mark - BNAnimationActionDelegate

- (void)actionDidStop:(BNAnimationAction *)action finished:(BOOL)flag {
    if (flag) {
        // The action has been finished.
        [_finishedActions addObject:action.identifier];
    }
    else {
        // The action has been corrupted.
        [_actions removeObjectForKey:action.identifier];
    }
    
    NSUInteger actionsCount = _actions.count;
    NSUInteger finishedCount = _finishedActions.count;
    
    if (finishedCount == actionsCount) {
        // All actions have been completed.
        // Remember that, completed action might be either finished or corrupted.
        if (_delegate && [_delegate respondsToSelector:@selector(actionDidStop:finished:)]) {
            // An action group is finished if there is at least one finished action.
            BOOL finished = finishedCount > 0;
            [_delegate actionDidStop:self finished:finished];
        }
        
        [self _clearAllActions];
    }
}

@end
