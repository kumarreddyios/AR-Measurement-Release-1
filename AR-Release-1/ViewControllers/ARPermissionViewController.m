//
//  ARPermissionViewController.m
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 06/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "ARPermissionViewController.h"
#import <ARKit/ARKit.h>

@interface ARPermissionViewController ()

@end

@implementation ARPermissionViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setBackgroundGradient];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - UI Setup

- (void)setBackgroundGradient {
    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:1.0];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect bounds = self.view.bounds;
    gradientLayer.frame = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];
}

# pragma mark - UI Actions

- (IBAction)didTapOnProceed:(UIButton *)sender {
    //Show permissions dialog for Camera
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self moveToIntroViewController];
    } else if(status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self moveToIntroViewController];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showPermissionErrorModal];
                });
            }
        }];
    }else if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        [self showPermissionErrorModal];
    }
}

- (void)showPermissionErrorModal {
    UIAlertController *cameraPermissionAlert = [UIAlertController alertControllerWithTitle:@"Camera Access" message:@"Myntra AR requires use of camera for Augmented Reality. Go to settings - > Myntra AR -> Camera (ON) " preferredStyle:(UIAlertControllerStyleAlert)];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
        [self dismissViewControllerAnimated:true completion:nil];
    }];
    [cameraPermissionAlert addAction:okAction];
    [self presentViewController:cameraPermissionAlert animated:true completion:nil];
}

- (void)moveToIntroViewController {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ARKit" bundle:nil];
    UIViewController *initialVC = [storyboard instantiateInitialViewController];
    initialVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:initialVC animated:true completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
