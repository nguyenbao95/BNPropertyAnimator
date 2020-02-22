//
//  BNMacros.h
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#ifndef BNMacros_h
#define BNMacros_h

#ifdef __cplusplus
#define BN_EXTERN         extern "C" __attribute__((visibility ("default")))
#else
#define BN_EXTERN         extern __attribute__((visibility ("default")))
#endif

#define BN_UNAVAILABLE NS_UNAVAILABLE
#define BN_DESIGNATED_INITIALIZER NS_DESIGNATED_INITIALIZER

#endif /* BNMacros_h */
