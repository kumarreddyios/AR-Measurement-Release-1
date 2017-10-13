//
//  SizeStatsView.m
//  AR-Release-1
//
//  Created by Mohonish Chakraborty on 12/10/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "SizeStatsView.h"
#import "SizeChart.h"

@interface SizeStatsView()

@property (nonatomic, strong) SizeChart *sizeChart;

@end

@implementation SizeStatsView

-(void)awakeFromNib{
    [super awakeFromNib];
    [self setActiveState:NoSize];
    [self setBackgroundGradient];
    if([self isExpandable]) {
        [self.topArrowImageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        [self.botArrowImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        [self.containerViewTypeMultiple.topArrowImageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        [self.containerViewTypeMultiple.botArrowImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
    } else {
        [self.topArrowImageView setHidden:true];
        [self.botArrowImageView setHidden:true];
        [self.containerViewTypeMultiple.topArrowImageView setHidden:true];
        [self.containerViewTypeMultiple.botArrowImageView setHidden:true];
    }
}

-(void)setBackgroundGradient {
    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:0.7];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:0.7];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width,self.bounds.size.height + 10);
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    [self.containerViewTypeSingle.layer insertSublayer:gradientLayer atIndex:0];
    [self.containerViewTypeSingle setClipsToBounds:true];
    
    CAGradientLayer *gradientLayer2 = [CAGradientLayer layer];
    gradientLayer2.frame = CGRectMake(0, 0, self.containerViewTypeMultiple.bounds.size.width,self.containerViewTypeMultiple.bounds.size.height);
    gradientLayer2.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer2.locations = locationArray;
    [self.containerViewTypeMultiple.layer insertSublayer:gradientLayer2 atIndex:0];
    [self.containerViewTypeMultiple setClipsToBounds:true];
}

-(void)updateSizesWithDistance:(CGFloat)distance {
    NSString* formattedString = [NSString stringWithFormat:@"%.2f", distance];
    [self.sizeLabelCM setText:[NSString stringWithFormat:@"(%@ cm)",formattedString]];
    CGFloat cms = formattedString.floatValue;
    if(self.sizeChart != nil) {
        printf("\nsizeChart not nil");
        switch (self.currentGender) {
            case Men: {
                //EU Size
                NSArray *euSize = [self.sizeChart getEUSizeFromCM:cms];
                if (euSize != nil && euSize.count > 0) {
                    if (euSize.count > 1) { //More than one results in range. Change state.
                        [self setActiveState:MultipleSize];
                        [self.containerViewTypeMultiple updateSizesWithDistance:distance forGender:Men andSizeChart:self.sizeChart];
                        return;
                    } else {
                        [self setActiveState:SingleSize];
                        [self.sizeLabel1 setText:euSize[0]?:@"-"];
                    }
                } else {
                    [self.sizeLabel1 setText:@"-"];
                }
                //UK Size
                NSArray *ukSize = [self.sizeChart getUKSizeFromCM:cms];
                if (ukSize != nil && ukSize.count > 0) {
                    [self.sizeLabel2 setText:ukSize[0]?:@"-"];
                } else {
                    [self.sizeLabel2 setText:@"-"];
                }
                //US Size
                NSArray *usSize = [self.sizeChart getUSSizeFromCM:cms];
                if (usSize != nil && usSize.count > 0) {
                    [self.sizeLabel3 setText:usSize[0]?:@"-"];
                } else {
                    [self.sizeLabel3 setText:@"-"];
                }
                break;
            }
            case Women: {
                NSArray *euSize = [self.sizeChart getEUSizeFromCM:cms];
                if (euSize != nil && euSize.count > 0) {
                    if (euSize.count > 1) { //More than one results in range. Change state.
                        printf("\nupdateSizesWithDistance - Multiple Size");
                        [self setActiveState:MultipleSize];
                        [self.containerViewTypeMultiple updateSizesWithDistance:distance forGender:Women andSizeChart:self.sizeChart];
                        return;
                    } else {
                        printf("\nupdateSizesWithDistance - Single Size");
                        [self setActiveState:SingleSize];
                        [self.sizeLabel3 setText:euSize[0]?:@"-"];
                    }
                } else {
                    printf("\nupdateSizesWithDistance - NOSize");
                    [self setActiveState:NoSize];
                    [self.sizeLabel3 setText:@"-"];
                }
                [self.sizeLabel2 setText:@"-"];
                [self.sizeLabel1 setText:@"-"];
            }
        }
    }
}

#pragma mark - State Management

-(void)setActiveState:(enum SizeStatState)state {
    if (state != _currentState) {
        switch (state) {
            case SingleSize:
                [self.containerViewTypeSingle setHidden:false];
                [self.containerViewTypeMultiple setHidden:true];
                printf("SHOW - Single");
                break;
            case MultipleSize:
                [self.containerViewTypeSingle setHidden:true];
                [self.containerViewTypeMultiple setHidden:false];
                printf("SHOW - Multiple");
                break;
            case NoSize:
                [self.containerViewTypeSingle setHidden:true];
                [self.containerViewTypeMultiple setHidden:true];
                printf("SHOW - NOSize");
        }
        _currentState = state;
    }
}

#pragma mark - Load size data

-(void)loadSizeChart {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShoeSizeData" ofType:@"json"];
    NSData *sizeData = [NSData dataWithContentsOfFile:path];
    NSDictionary *sizeDictionary = [NSJSONSerialization JSONObjectWithData:sizeData options:kNilOptions error:&error];
    self.sizeChart = [[SizeChart alloc] initWithSizeDictionary:sizeDictionary];
    printf("\nSetting Gender = %d", self.currentGender);
    [self.sizeChart setGender:self.currentGender];
}

#pragma mark - Expandability

-(BOOL)isExpandable {
    return self.currentGender == Men;
}

-(CGFloat)getToggleAnimationHeight {
    if(self.currentState == MultipleSize) {
        return [[self.containerViewTypeMultiple sizeLabelCM] frame].origin.y;
    } else {
        return [self.sizeLabelCM frame].origin.y;
    }
}

@end
