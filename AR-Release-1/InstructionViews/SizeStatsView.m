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
    _currentState = InactiveSize;
    [self setBackgroundGradient];
    [self loadSizeChart];
}

-(void)setBackgroundGradient {
    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:1.0];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = CGRectMake(0, 0, self.bounds.size.width,self.bounds.size.height);
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    gradientLayer.cornerRadius = 2.0f;
    [self.containerViewTypeSingle setClipsToBounds:true];
    [self.containerViewTypeSingle.layer insertSublayer:gradientLayer atIndex:0];
}

-(void)updateSizesWithDistance:(CGFloat)distance {
    NSString* formattedString = [NSString stringWithFormat:@"%.2f", distance];
    [self.sizeLabelCM setText:[NSString stringWithFormat:@"(%@ cm)",formattedString]];
    CGFloat cms = formattedString.floatValue;
    if(self.sizeChart != nil) {
        switch (self.currentGender) {
            case Men: {
                NSString *ukSize = [self.sizeChart getUKSizeFromCM:cms];
                [self.sizeLabel3 setText:ukSize?:@"-"];
                NSString *usSize = [self.sizeChart getUSSizeFromCM:cms];
                [self.sizeLabel2 setText:usSize?:@"-"];
                NSString *euSize = [self.sizeChart getEUSizeFromCM:cms];
                [self.sizeLabel1 setText:euSize?:@"-"];
                break;
            }
            case Women: {
                NSString *bandSize = [self.sizeChart getEUSizeFromCM:cms];
                [self.sizeLabel3 setText:bandSize?:@"-"];
                [self.sizeLabel2 setText:@"-"];
                [self.sizeLabel1 setText:@"-"];
            }
        }
    }
}

#pragma mark - Load size data

-(void)loadSizeChart {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShoeSizeData" ofType:@"json"];
    NSData *sizeData = [NSData dataWithContentsOfFile:path];
    NSDictionary *sizeDictionary = [NSJSONSerialization JSONObjectWithData:sizeData options:kNilOptions error:&error];
    self.sizeChart = [[SizeChart alloc] initWithSizeDictionary:sizeDictionary];
}

#pragma mark - Expandability

-(BOOL)isExpandable {
    return self.currentGender == Men;
}

@end
