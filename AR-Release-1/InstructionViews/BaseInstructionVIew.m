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
    //Set initial constants for animation.
    self.titleTop.constant = -500;
    self.subtitleTop.constant = -500;
    self.imageBottomConstant.constant = 500;
    self.actionButtonBottom.constant = -500;
    [self layoutIfNeeded];
}

-(void)presentInstructionView:(InstructionsModel *)model{
    [self setHidden:false];
    self.presentShowingInstruction = model;
    self.titleLable.text = model.mainTitle;
    self.subTitle.text = model.subTitle;
    
    
    self.imageView.animatedImage = [[FLAnimatedImage alloc] initWithAnimatedGIFData:[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Plane-Detection" ofType:@"gif"]]];
    [self.actionButton setTitle:model.buttonTitle forState:UIControlStateNormal];
    self.titleTop.constant = -500;
    self.subtitleTop.constant = -500;
    self.imageBottomConstant.constant = 500;
    self.actionButtonBottom.constant = -500;
    [[self superview] layoutIfNeeded];
    [UIView animateWithDuration:0.7 delay:0.0 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        self.subtitleTop.constant = 160;
        self.imageBottomConstant.constant = 80;
        self.alpha = 1.0;
        [[self superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.actionButton setTitle:model.buttonTitle forState:UIControlStateNormal];
    }];
    [UIView animateWithDuration:1.0 delay:0.1 options:(UIViewAnimationOptionCurveEaseIn) animations:^{
        self.titleTop.constant = 105;
        self.actionButtonBottom.constant = 40;
        [[self superview] layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self.actionButton setTitle:model.buttonTitle forState:UIControlStateNormal];
    }];
}

-(void)popInstructionView{
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 delay:0.0 options:(UIViewAnimationOptionCurveLinear) animations:^{
        self.titleTop.constant = -500;
        self.actionButtonBottom.constant = -500;
        [self.superview layoutIfNeeded];
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self setHidden:true];
    }];
}

-(void)popInstructionsAndPresent:(InstructionsModel*)model {
    [self layoutIfNeeded];
    [UIView animateWithDuration:0.3 animations:^{
        self.titleTop.constant = -500;
        self.actionButtonBottom.constant = -500;
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self presentInstructionView:model];
    }];
}


- (IBAction)clickedOnButton:(id)sender {
    [self.delegate clickedOnInstruction:self.presentShowingInstruction];
}

- (IBAction)actionButton:(UIButton *)sender {
}
@end
