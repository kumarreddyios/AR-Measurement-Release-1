//
//  BaseInstructionVIew.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/28/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InstructionsModel.h"

@protocol InstructionDelegate

-(void)clickedOnInstruction:(InstructionsModel*)model;

@end

@interface BaseInstructionVIew : UIView
@property (nonatomic, weak) IBOutlet UIView *gradientView;
@property (nonatomic, weak) IBOutlet UILabel *titleLable;
@property (nonatomic, weak) IBOutlet UILabel *subTitle;
@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, weak) IBOutlet UIButton *actionButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *titleTop;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionButtonBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;

@property (nonatomic, weak) id<InstructionDelegate> delegate;

-(void)presentInstructionView:(InstructionsModel*)model;
-(void)popInstructionView;
-(void)popInstructions;

@end
