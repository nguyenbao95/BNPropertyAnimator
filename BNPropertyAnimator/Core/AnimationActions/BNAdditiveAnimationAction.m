//
//  BNAdditiveAnimationAction.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNAdditiveAnimationAction.h"
#import "CALayer+BNPropertyAnimator.h"
#import "BNUtils.h"

@interface BNAdditiveAnimationAction () <CAAnimationDelegate> {
    NSString *_event;
    NSTimeInterval _delay;
    CALayer *_layer;
    NSString *_animationKey;
    CABasicAnimation *_pendingAnimation;
    BNPropertyAnimator *_animator;
    
    id _fromValue;
    id _toValue;
    BOOL _additive;
}

@end

@implementation BNAdditiveAnimationAction

- (instancetype)initWithEvent:(NSString *)event
                        delay:(NSTimeInterval)delay
                     animator:(BNPropertyAnimator *)animator
                     forLayer:(nonnull CALayer *)layer {
    self = [super init];
    if (self) {
        _event = event;
        _delay = delay;
        _layer = layer;
        _animator = animator;
        _fromValue = [layer valueForKeyPath:event];
        _animationKey = [self _animationKeyForEvent:event];
        _identifier = [NSString stringWithFormat:@"%p:%@:%@", layer, event, _animationKey];
        _additive = [_layer.class bn_isAdditiveKeyPath:event];
        _pendingAnimation = [self _generateAnimation];
    }
    return self;
}

- (CABasicAnimation *)_generateAnimation {
    CABasicAnimation *animation = nil;
    id<BNTimingCurveProvider> timingParams = _animator.timingParameters;
    if (@available(iOS 9.0, *)) {
        BNSpringTimingParameters *springParams = timingParams.springTimingParameters;
        if (springParams) {
            CASpringAnimation *springAnimation = [CASpringAnimation animationWithKeyPath:_event];
            springAnimation.mass = springParams.mass;
            springAnimation.damping = springParams.damping;
            springAnimation.stiffness = springParams.stiffness;
            springAnimation.initialVelocity = springParams.initialVelocity;
            
            animation = springAnimation;
        }
    }
    if (!animation) {
        animation = [CABasicAnimation animationWithKeyPath:_event];
    }
    BNCubicTimingParameters *cubicParams = timingParams.cubicTimingParameters;
    if (cubicParams) {
        CGPoint cp1, cp2;
        if (cubicParams.animationCurve >= 0) {
            BNControlPointsForAnimationCurve(cubicParams.animationCurve, &cp1, &cp2);
        }
        else {
            cp1 = cubicParams.controlPoint1;
            cp2 = cubicParams.controlPoint2;
        }
        animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:cp1.x :cp1.y :cp2.x :cp2.y];
    }
    
    // Convert global time to layer's local time if animation has a delay.
    if (_delay != 0.0) {
        NSTimeInterval currentTime = CACurrentMediaTime();
        NSTimeInterval currentLayerTime = [_layer convertTime:currentTime fromLayer:nil];
        animation.beginTime = currentLayerTime + _delay;
    }
    animation.additive = _additive;
    animation.duration = _animator.duration;
    animation.delegate = self;
    animation.fillMode = kCAFillModeBoth;
    animation.removedOnCompletion = NO;
    
    return animation;
}

- (NSString *)_animationKeyForEvent:(NSString *)event {
    NSString *animKey = nil;
    NSInteger index = 1;
    
    do {
        NSString *curKey = [NSString stringWithFormat:@"bn_%@_%li", event, (long)index];
        BOOL existed = [_layer animationForKey:curKey] ? YES : NO;
        if (!existed) {
            animKey = curKey;
        }
        ++index;
    }
    while(!animKey);
    
    return animKey;
}

- (void)_cleanUp {
    _pendingAnimation.delegate = nil;
    [_layer removeAnimationForKey:_animationKey];
}

#pragma mark - CAAction

- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(nullable NSDictionary *)dict {
    id toValue = [_layer valueForKeyPath:_event];
    id fromValue = _fromValue;
    
    if (_additive) {
        _toValue = [_layer.class bn_toValueForAdditiveAnimationWithKeyPath:_event];
        _fromValue = BNInvertAdditiveProperty(fromValue, toValue);
    }
    else {
        _toValue = toValue;
        _fromValue = fromValue;
    }
    
    _pendingAnimation.toValue = _toValue;
    _pendingAnimation.fromValue = _fromValue;
    
    [_layer removeAnimationForKey:_animationKey];
    [_layer addAnimation:_pendingAnimation forKey:_animationKey];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if (flag) {
        if (_delegate && [_delegate respondsToSelector:@selector(actionDidStop:finished:)]) {
            [_delegate actionDidStop:self finished:YES];
        }
    }
    else {
        /* When removing a view/layer from its superview/superlayer or
         * adding an animation into a view/layer that hasn't been rendered on the hierachy yet,
         * the animationDidStop:finished: will be invoked immediately.
         */
        CAAnimation *animation = [_layer animationForKey:_animationKey];
        if (animation == nil || animation == anim) {
            if (_delegate && [_delegate respondsToSelector:@selector(actionDidStop:finished:)]) {
                [_delegate actionDidStop:self finished:NO];
            }
        }
    }
    
    // Clean up to prevent retain cycles.
    [self _cleanUp];
}

@end
