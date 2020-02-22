//
//  BNAnimationAction.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNAnimationAction.h"

@implementation BNAnimationAction

@synthesize identifier = _identifier;
@synthesize delegate = _delegate;

- (void)runActionForKey:(NSString *)event
                 object:(id)anObject
              arguments:(nullable NSDictionary *)dict {}

@end
