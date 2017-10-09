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
@property (weak, nonatomic) IBOutlet UILabel *femaleText;
@property (weak, nonatomic) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *nextButtonBottomConstraint;

@property enum Gender gender;

@end

@implementation ARIntroViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sceneView.scene = [[SCNScene alloc] init];
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionRemoveExistingAnchors)];
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionResetTracking)];
    self.nextButtonBottomConstraint.constant = -100;
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
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];

    self.maleView.layer.cornerRadius = self.maleView.bounds.size.height / 2;
    self.femaleView.layer.cornerRadius = self.maleView.bounds.size.height / 2;
    self.maleView.tag = 1;
    self.femaleView.tag = 2;
    [self setupGestures];

    [self.navigationController.navigationBar setHidden:YES];
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
        [self.maleText setTextColor:[UIColor whiteColor]];
        [self.femaleView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.4]];
        [self.femaleText setTextColor:[UIColor colorWithRed:164.0/255.0 green:140.0/255.0 blue:201.0/255.0 alpha:1.0]];
        self.gender = Men;
    }else if(tapGesture.view.tag == 2){
        [self.femaleView setBackgroundColor:[UIColor whiteColor]];
        [self.femaleText setTextColor:[UIColor whiteColor]];
        [self.maleView setBackgroundColor:[UIColor colorWithWhite:1 alpha:0.4]];
        [self.maleText setTextColor:[UIColor colorWithRed:164.0/255.0 green:140.0/255.0 blue:201.0/255.0 alpha:1.0]];
        self.gender = Women;
    }
    [self animateNextButton];
}

-(void)animateNextButton {
    [UIView animateWithDuration:0.3 animations:^{
        self.nextButtonBottomConstraint.constant = 35;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)clickedOnNext:(id)sender {
    ARViewController *arViewController = [ARViewController getARViewController];
    arViewController.gender = self.gender;
    [self.navigationController pushViewController:arViewController animated:true];
}


@end
