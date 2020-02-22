//
//  BNTransaction.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "BNTransaction.h"

@implementation BNTransaction

+ (NSMutableArray *)activeTransactions {
    static dispatch_once_t onceToken;
    static NSMutableArray *activeTransactions;
    dispatch_once(&onceToken, ^{
        activeTransactions = [[NSMutableArray alloc] init];
    });
    return activeTransactions;
}

+ (void)begin:(BNTransaction *)transactions {
    [CATransaction begin];
    [CATransaction setDisableActions:NO];
    
    [BNTransaction.activeTransactions addObject:transactions];
}

+ (void)commit {
    [BNTransaction.activeTransactions removeLastObject];
    
    [CATransaction commit];
}

+ (BNTransaction *)lastTransaction {
    return BNTransaction.activeTransactions.lastObject;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
