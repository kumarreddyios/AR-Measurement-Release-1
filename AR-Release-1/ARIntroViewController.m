//
//  ARIntroViewController.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/27/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "ARIntroViewController.h"
#import "ARViewController.h"
#import "SizeChart.h"

@interface ARIntroViewController ()
@property (weak, nonatomic) IBOutlet UIView *maleView;
@property (weak, nonatomic) IBOutlet UIView *femaleView;
@property (weak, nonatomic) IBOutlet UILabel *maleText;
@property (weak, nonatomic) IBOutlet UILabel *femalText;
@property enum Gender gender;

@end

@implementation ARIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.view setBackgroundColor:[UIColor clearColor]];
    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:1.0];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.view.frame;
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    [self.view.layer insertSublayer:gradientLayer atIndex:0];

    self.maleView.layer.cornerRadius = 42.5;
    self.femaleView.layer.cornerRadius = 42.5;
    self.maleView.tag = 1;
    self.femaleView.tag = 2;
    [self setupGestures];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setupGestures{
    UITapGestureRecognizer *mTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.maleView addGestureRecognizer:mTapGesture];
    UITapGestureRecognizer *fTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self.femaleView addGestureRecognizer:fTapGesture];
}

-(void)handleTap:(UITapGestureRecognizer*)tapGesture{
    if (tapGesture.view.tag == 1) {
        [self.maleView setBackgroundColor:[UIColor whiteColor]];
        [self.femaleView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0]];
        self.gender = Men;
    }else if(tapGesture.view.tag == 2){
        [self.femaleView setBackgroundColor:[UIColor whiteColor]];
        [self.maleView setBackgroundColor:[UIColor colorWithRed:235.0/255.0 green:235.0/255.0 blue:241.0/255.0 alpha:1.0]];
        self.gender = Women;
    }
}

- (IBAction)clickedOnNext:(id)sender {
    ARViewController *arViewController = [ARViewController getARViewController];
    arViewController.gender = self.gender;
    [self.navigationController pushViewController:arViewController animated:true];
}


@end
