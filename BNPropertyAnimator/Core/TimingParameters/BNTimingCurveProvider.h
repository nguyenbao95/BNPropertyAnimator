//
//  BNTimingCurveProvider.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

NS_ASSUME_NONNULL_BEGIN

@class BNCubicTimingParameters, BNSpringTimingParameters;

@protocol BNTimingCurveProvider <NSObject>

@property (nullable, nonatomic, readonly) BNCubicTimingParameters *cubicTimingParameters;
@property (nullable, nonatomic, readonly) BNSpringTimingParameters *springTimingParameters;

@end

NS_ASSUME_NONNULL_END
