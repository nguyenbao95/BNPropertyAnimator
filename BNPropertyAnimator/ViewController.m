//
//  ViewController.m
//  BNPropertyAnimator
//
//  Copyright © 2020 Bao Nguyen. All rights reserved.
//

#import "ViewController.h"
#import "BNPropertyAnimator.h"

@interface ABView : UIView

@end

@implementation ABView

- (void)dealloc
{
    NSLog(@"Dealloc");
}

@end


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIView *view = [[ABView alloc] initWithFrame:CGRectMake(100, 100, 60, 60)];
    view.backgroundColor = [UIColor redColor];
    [self.view addSubview:view];
    
    UIView *view2 = [[UIView alloc] initWithFrame:CGRectMake(100, 200, 60, 60)];
    view2.backgroundColor = [UIColor greenColor];
    [self.view addSubview:view2];
    
    
    CALayer *layer = [[CALayer alloc] init];
    layer.backgroundColor = UIColor.blueColor.CGColor;
    layer.frame = CGRectMake(100, 300, 60, 60);
    [self.view.layer addSublayer:layer];
    
//    [UIView animateWithDuration:4.0 animations:^{
//        view.layer.frame = CGRectMake(200, 200, 80, 80);
//        view2.frame = CGRectMake(200, 300, 80, 80);
//        layer.frame = CGRectMake(200, 400, 80, 80);
//    } completion:^(BOOL finished) {
//        NSLog(@"Completed");
//    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [view removeFromSuperview];
//        //[view2 removeFromSuperview];
//    });
    
    
    id<BNTimingCurveProvider> timingParams = [[BNSpringTimingParameters alloc] init];
    [BNPropertyAnimator
     animateWithDuration:4.0
     delay:1.0
     timingParameters:timingParams
     animations:^{
        view.layer.frame = CGRectMake(200, 200, 80, 80);
        view2.frame = CGRectMake(200, 300, 80, 80);
        layer.frame = CGRectMake(200, 400, 80, 80);
    }
     completion:^(BOOL finished) {
        NSLog(@"Completed");
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [view removeFromSuperview];
//        [view2 removeFromSuperview];
//        [layer removeFromSuperlayer];
    });
}


@end
