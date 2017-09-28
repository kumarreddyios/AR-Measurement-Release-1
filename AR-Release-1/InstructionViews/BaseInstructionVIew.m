//
//  BaseInstructionVIew.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/28/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "BaseInstructionVIew.h"

@interface BaseInstructionVIew()
@property (nonatomic,strong) InstructionsModel *presentShowingInstruction;
@end

@implementation BaseInstructionVIew

-(void)awakeFromNib{
    [super awakeFromNib];
    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:1.0];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect bounds = [[UIScreen mainScreen] bounds];
    gradientLayer.frame = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];
}

-(void)presentInstructionView:(InstructionsModel *)model{
    self.presentShowingInstruction = model;
    self.alpha = 1.0;
    self.titleLable.text = model.mainTitle;
    self.subTitle.text = model.subTitle;
    self.imageView.image = [UIImage imageNamed:model.imageName];
    self.actionButton.titleLabel.text = model.buttonTitle;
    self.titleTop.constant = -500;
    self.actionButtonBottom.constant = -500;
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.9 animations:^{
        self.titleTop.constant = 60;
        self.actionButtonBottom.constant = 40;
        [[self superview] layoutIfNeeded];
    }];
}

-(void)popInstructionView{
    [self popInstructions];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    }];
}

-(void)popInstructions{
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.titleTop.constant = -500;
        self.actionButtonBottom.constant = -500;
        [self.superview layoutIfNeeded];
    }];
}


- (IBAction)clickedOnButton:(id)sender {
    [self.delegate clickedOnInstruction:self.presentShowingInstruction];
}

@end
