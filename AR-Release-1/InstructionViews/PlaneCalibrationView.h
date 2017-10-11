//
//  PlaneCalibrationView.h
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 11/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

enum PlaneCalibrationState {
    Inactive,
    TiltLeft,
    TiltRight,
    TiltTop,
    TiltBottom
};

@interface PlaneCalibrationView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *primaryImageView;
@property (nonatomic, weak) IBOutlet UILabel *primaryInstructionLabel;

@property (nonatomic, weak) IBOutlet UIImageView *leftIndicatorImageView;
@property (nonatomic, weak) IBOutlet UIImageView *rightIndicatorImageView;
@property (nonatomic, weak) IBOutlet UIImageView *topIndicatorImageView;
@property (nonatomic, weak) IBOutlet UIImageView *bottomIndicatorImageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftIndicatorConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightIndicatorConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topIndicatorConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomIndicatorConstraint;

-(void)beginPlaneCalibration;

@end
