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
    TiltBottom,
    UpDownMessage
};

@interface PlaneCalibrationView : UIView

@property (nonatomic, weak) IBOutlet UIImageView *indicatorImageView;
@property (nonatomic, weak) IBOutlet UIImageView *mapImageView;
@property (nonatomic, weak) IBOutlet UILabel *primaryInstructionLabel;
@property (nonatomic, weak) IBOutlet UILabel *secondaryInstructionLabel;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *endMessageView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerYConstrant;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *centerXConstraint;

-(void)beginPlaneCalibration;

@end
