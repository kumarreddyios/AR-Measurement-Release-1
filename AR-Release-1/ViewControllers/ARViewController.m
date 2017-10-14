//
//  ViewController.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "ARViewController.h"
#import "PlaneNode.h"
#import "InstructionsModel.h"
#import "BaseInstructionVIew.h"
#import "PlaneCalibrationView.h"
#import "SizeStatsView.h"

// start and end marker geometry
#define MarkerWidth 0.20
#define MarkerHeight 0.001
#define MarkerLength 0.003

#define DefaultDifferenceBetweenStartAndEnd 0.20 /* 20 cms */

// centimeter scale geometry
#define ScaleWIdth 0.05
#define ScaleHeight 0.01
#define ScaleLength 0.05

// geometry of centimeter lines on the centimeter scale
#define CMLineWidth 0.018
#define CMLineWidth2 0.009
#define CMLineHeight 0.001
#define CMLineLength 0.001

#define CMTextWidth 0.03
#define NobRadius 0.008

@interface ARViewController () <ARSCNViewDelegate>
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet BaseInstructionVIew *baseInstructionView;
@property (weak, nonatomic) IBOutlet SizeStatsView *footSizeStatsView;
@property (weak, nonatomic) IBOutlet UIVisualEffectView *actionButtonView;
@property (weak, nonatomic) IBOutlet UIButton *actionButtonTitle;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *toastView;
@property (weak, nonatomic) IBOutlet UILabel *toastLabel;
@property (weak, nonatomic) IBOutlet PlaneCalibrationView *planeCalibrationView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *statsViewTopConstraint;

@property (nonatomic, strong) NSMutableDictionary<NSString*,PlaneNode*> *dectedAnchors;
@property (nonatomic) SCNVector3 startPosition; //startpoint is fixed, it will change only if you reset the tracking or restart the process.
@property (nonatomic) SCNVector3 endPosition; // this will change when a user moved the endline.
@property (nonatomic, strong) SCNNode *startNode;
@property (nonatomic, strong) SCNNode *endNode;
@property (nonatomic, strong) SCNNode *nobNode;
@property (nonatomic, strong) SCNNode *nobArrowTop;
@property (nonatomic, strong) SCNNode *nobArrowBot;
@property (nonatomic, strong) SCNNode *topTextNode;
@property (nonatomic, strong) SCNNode *scaleBaseNode;
@property (nonatomic) BOOL tapEnabled;
@property (nonatomic) BOOL panEnabled;
@property (nonatomic, strong) SCNNode *cmScaleNode; // this is the centimeter scale node, to which we will add the line and text nodes.
@property (nonatomic, strong) NSMutableDictionary<NSNumber*,NSMutableArray<SCNNode*>*> *scaleNodesDict; // it will be having the list of nodes ( line node & text node ) for each centimeter.
@property (nonatomic) NSInteger scaleNumber; // it represents the scale number starting from 1.
@property (nonatomic) CGFloat presentDistance;
@property (nonatomic, strong) NSArray *instructionModels;
@property (nonatomic, strong) InstructionsModel *currentlyShowingInstruction;
@property (nonatomic, strong) SCNNode *testNode;
@end

@implementation ARViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sceneView.delegate = self;
    //self.sceneView.showsStatistics = true;
    self.sceneView.scene = [[SCNScene alloc] init];
    self.dectedAnchors = [[NSMutableDictionary alloc] init];
    self.tapEnabled = false;
    self.panEnabled = false;
    self.scaleNodesDict = [[NSMutableDictionary alloc] init];
    self.scaleNumber = 1;
    [[self backButton] setHidden:true];
    [[self resetButton] setHidden:true];
    [[self toastView] setHidden:true];
    [self.footSizeStatsView setHidden:true];
    [self.footSizeStatsView setCurrentGender:self.gender];
    [self.footSizeStatsView loadSizeChart];
    [UIApplication.sharedApplication setIdleTimerDisabled:true];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //views decoration
    [self toggleStatsViewExpand];
    
    //camera permission code
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusAuthorized) {
        [self startInstructions];
    }else if(status == AVAuthorizationStatusNotDetermined){
        [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self startInstructions];
                });
            }else{
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.navigationController popViewControllerAnimated:true];
                });
            }
        }];
    }else if(status == AVAuthorizationStatusDenied || status == AVAuthorizationStatusRestricted){
        UIAlertController *cameraPermissionAlert = [UIAlertController alertControllerWithTitle:@"Camera Access" message:@"Myntra AR requires use of camera for Augmented Reality. Go to settings - > Myntra AR -> Camera (ON) " preferredStyle:(UIAlertControllerStyleAlert)];
         UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"Ok" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {
             [self.navigationController popViewControllerAnimated:true];
         }];
         [cameraPermissionAlert addAction:okAction];
         [self presentViewController:cameraPermissionAlert animated:true completion:nil];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //TODO: nudge animate sizes view if isExpandable.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // Pause the view's session
    [self.sceneView.session pause];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - Reset Tracking

-(void)startInstructions{
    self.instructionModels = [InstructionsModel prepareInstructionsDataset];
    self.baseInstructionView.delegate = self;
    [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:0]];
    self.currentlyShowingInstruction = [self.instructionModels objectAtIndex:0];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self resetTracking:false showFeaturePoints:false];
    });
}

- (IBAction)clickedOnReset:(id)sender {
    [self resetTracking:true showFeaturePoints:true];
}

- (void)resetTracking:(BOOL)isPlaneDetection showFeaturePoints:(BOOL)showFeaturePoints {
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    if (isPlaneDetection) {
        configuration.planeDetection = ARPlaneDetectionHorizontal;
        [self.planeCalibrationView setHidden:false];
        [self.planeCalibrationView beginPlaneCalibration];
    }
    if (showFeaturePoints) {
        self.sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    }
    [self.sceneView setAlpha:0];
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionRemoveExistingAnchors)];
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionResetTracking)];
    [UIView animateWithDuration:1.5 delay:0.4 options:UIViewAnimationOptionCurveLinear animations:^{
        [self.sceneView setAlpha:1.0];
    } completion:nil];
    [self deleteAllTheNodes];
    self.scaleNumber = 1;
}

-(void)deleteAllTheNodes{
    for (SCNNode *node in self.sceneView.scene.rootNode.childNodes) {
        [node removeFromParentNode];
    }
    [self.dectedAnchors removeAllObjects];
    self.startNode = nil;
    self.endNode = nil;
    self.cmScaleNode = nil;
    self.tapEnabled = false;
    [self.footSizeStatsView setHidden:true];
}

#pragma mark - ARSCNViewDelegate

-(void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]){
        ARPlaneAnchor *pAnchor = (ARPlaneAnchor*)anchor;
        PlaneNode *planeNode = [[PlaneNode alloc] initWithAnchor:pAnchor];
        //planeNode.simdTransform = pAnchor.transform;
        planeNode.position = SCNVector3Make(pAnchor.transform.columns[3].x, pAnchor.transform.columns[3].y, pAnchor.transform.columns[3].z);
        if(self.dectedAnchors.count > 0) {
            return; //To prevent multiple planes being added to the same scene.
        }
        [self.sceneView.scene.rootNode addChildNode:planeNode];
        self.dectedAnchors[pAnchor.identifier.UUIDString]=planeNode;
        dispatch_async(dispatch_get_main_queue(), ^{
            // it means that plane got detected.
            if (self.dectedAnchors.count == 1) {
                self.sceneView.debugOptions = SCNDebugOptionNone;
                [self.planeCalibrationView stopPlaneCalibration];
                [self.planeCalibrationView setHidden:true];
                [self.actionButtonView setHidden:false];
                [self hideToastViewWithTime:0];
                [self createInitialScaleOnPlaneAnchor:pAnchor];
                [self createEndPointsInScale];
            }
        });
    }
}

-(void)renderer:(id<SCNSceneRenderer>)renderer didUpdateNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]){
        ARPlaneAnchor *pAnchor = (ARPlaneAnchor*)anchor;
        if (self.dectedAnchors[pAnchor.identifier.UUIDString]) {
            PlaneNode *planeNode = self.dectedAnchors[pAnchor.identifier.UUIDString];
            [planeNode updateNode:pAnchor];
        }
    }
}

- (void)session:(ARSession *)session didFailWithError:(NSError *)error {
    if (self.currentlyShowingInstruction.type == ARMeasure) {
        [self showToastViewWithErrorMessage:error.localizedDescription];
    }
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
    [self showToastViewWithErrorMessage:@"Session Interrupted"];
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
    [self hideToastViewWithTime:1];
    [self resetTracking:true showFeaturePoints:true];
}

# pragma mark - Toast View

- (void)showToastViewWithErrorMessage:(NSString *)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self toastLabel] setText:message];
        _toastView.alpha = 0;
        [[self toastView] setHidden:false];
        [UIView animateWithDuration:0.3 animations:^{
            _toastView.alpha = 1;
        } completion: ^(BOOL finished) {
            [[self toastView] setHidden:!finished];
        }];
    });
}

- (void)hideToastViewWithTime:(int)seconds {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(seconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 animations:^{
            _toastView.alpha = 0;
        } completion: ^(BOOL finished) {
            [[self toastView] setHidden:finished];
        }];
    });
}

#pragma mark - Gestures

-(void)setupGestures{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnSizeStatsView:)];
    [self.footSizeStatsView addGestureRecognizer:tapGesture];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnPlane:)];
    [self.view addGestureRecognizer:tapGesture2];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panningOnPlane:)];
    [self.sceneView addGestureRecognizer:panGesture];
}

-(void)didTapOnSizeStatsView:(UITapGestureRecognizer*)tapGesture {
    if([self.footSizeStatsView isExpandable]) {
        [self toggleStatsViewExpand];
    }
}

-(void)tappedOnPlane:(UITapGestureRecognizer*)tapGesture {
    [self dismissStatsViewExpandedState];
//    CGPoint point = [tapGesture locationInView:self.sceneView];
//    SCNVector3 worldLocation = [self worldLocationFromPoint:point];
//    //if (!self.tapEnabled) {
//        //CGPoint point = [tapGesture locationInView:self.sceneView];
//        if (worldLocation.x == 0 && worldLocation.y == 0 && worldLocation.z == 0) {
//            return;
//        }else{
//            self.tapEnabled = true;
//            self.panEnabled = true;
//            self.startPosition = worldLocation;
//            self.startNode = [self createAndAddToRootNode:MarkerWidth andHeight:MarkerHeight andLength:MarkerLength atPosition:self.startPosition withMaterial:[UIColor whiteColor] withRotation:SCNVector4Zero];
//        }
//    //}
}

-(void)createInitialScaleOnPlaneAnchor:(ARPlaneAnchor*)anchor {
    self.startPosition = SCNVector3Make(anchor.transform.columns[3].x, anchor.transform.columns[3].y, anchor.transform.columns[3].z + (anchor.extent.z*0.5));
    self.startNode = [self createAndAddToRootNode:MarkerWidth andHeight:MarkerHeight andLength:MarkerLength atPosition:self.startPosition withMaterial:[UIColor whiteColor] withRotation:SCNVector4Zero];
}

-(void)createLayoverImage {
    CGFloat distance = ExtSCNVectorDistanceInCms(self.startPosition,self.endPosition)/100;
    SCNBox *box = [SCNBox boxWithWidth:distance*0.394 height:NobRadius length:distance chamferRadius:0.0];
    box.firstMaterial.diffuse.contents = [UIImage imageNamed:@"Foot"];
    box.firstMaterial.transparency = 0.3;
    SCNNode *footNode = [SCNNode nodeWithGeometry:box];
    footNode.position = SCNVector3Make(self.endPosition.x, self.endPosition.y, self.endPosition.z + distance*0.5);
    [self.sceneView.scene.rootNode addChildNode:footNode];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:2.0];
        footNode.opacity = 0;
        [SCNTransaction commit];
        [SCNTransaction flush];
    });
}

-(void)createEndPointsInScale {
    self.endPosition = ExtSCNVector3Subtract(self.startPosition, SCNVector3Make(0, 0, DefaultDifferenceBetweenStartAndEnd));
    self.endNode = [self createAndAddToRootNode:MarkerWidth andHeight:MarkerHeight andLength:MarkerLength atPosition:self.endPosition withMaterial:[UIColor whiteColor] withRotation:SCNVector4Zero];
    // create a nob for the end line, as the given 3D marker model is not working due to scaling issues.

    // Torus
//    SCNTorus *torus = [SCNTorus torusWithRingRadius:NobRadius pipeRadius:NobRadius/5];
//    torus.ringSegmentCount = 12;
//    torus.pipeSegmentCount = 6;
//    torus.firstMaterial.diffuse.contents = [UIColor whiteColor];
//    self.nobNode = [SCNNode nodeWithGeometry:torus];
//    self.nobNode.position = SCNVector3Make(self.endPosition.x + (MarkerWidth/2), self.endPosition.y, self.endPosition.z - NobRadius);
//    [self.sceneView.scene.rootNode addChildNode:self.nobNode];
    
    // Nob Shape
    SCNBox *box = [SCNBox boxWithWidth:NobRadius*4 height:NobRadius length:NobRadius*4 chamferRadius:NobRadius*0.5];
    box.firstMaterial.diffuse.contents = [UIColor whiteColor];
    self.nobNode = [SCNNode nodeWithGeometry:box];
    self.nobNode.position = SCNVector3Make(self.endPosition.x + (MarkerWidth/2), self.endPosition.y, self.endPosition.z);
    [self.sceneView.scene.rootNode addChildNode:self.nobNode];
    
    // Up Arrow Shape
    SCNPyramid *pyramid1 = [SCNPyramid pyramidWithWidth:NobRadius height:NobRadius length:NobRadius/3];
    pyramid1.firstMaterial.diffuse.contents = [UIColor blackColor];
    self.nobArrowTop = [SCNNode nodeWithGeometry:pyramid1];
    self.nobArrowTop.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0);
    self.nobArrowTop.position = SCNVector3Make(self.endPosition.x + (MarkerWidth/2), self.endPosition.y + NobRadius, self.endPosition.z - NobRadius*0.5);
    [self.sceneView.scene.rootNode addChildNode:self.nobArrowTop];
    
    // Down Arrow Shape
    SCNPyramid *pyramid2 = [SCNPyramid pyramidWithWidth:NobRadius height:NobRadius length:NobRadius/3];
    pyramid2.firstMaterial.diffuse.contents = [UIColor blackColor];
    self.nobArrowBot = [SCNNode nodeWithGeometry:pyramid2];
    self.nobArrowBot.eulerAngles = SCNVector3Make(M_PI_2, 0, 0);
    self.nobArrowBot.position = SCNVector3Make(self.endPosition.x + (MarkerWidth/2), self.endPosition.y + NobRadius, self.endPosition.z + NobRadius*0.5);
    [self.sceneView.scene.rootNode addChildNode:self.nobArrowBot];
    
    // Top Text Node
    SCNText *scnText = [SCNText textWithString:@"Drag to the tip of your toe"  extrusionDepth:0.5];
    scnText.firstMaterial.diffuse.contents = [UIColor whiteColor];
    scnText.font = [UIFont systemFontOfSize:4.0];
    scnText.flatness = 1.0;
    
    self.topTextNode = [SCNNode nodeWithGeometry:scnText];
    self.topTextNode.position = SCNVector3Make(self.endPosition.x - (MarkerWidth/2), self.endPosition.y, self.endPosition.z - 0.01);
    self.topTextNode.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0);
    self.topTextNode.scale = SCNVector3Make(0.003, 0.003, 0.003);
    [self.sceneView.scene.rootNode addChildNode:self.topTextNode];
    
    [self createLayoverImage];
    
    [self drawCentimeterScale];

    /* extracted the rotarion from camera, however we could not able to apply it to node and to get the line perpendicular to camera.*/

    /*SCNNode *tempNode = [self createAndAddToRootNode:MarkerWidth andHeight:MarketHeight andLength:MarkerLength atPosition:SCNVector3Zero withMaterial:[UIColor redColor] withRotation:SCNVector4Zero];

    SCNMatrix4 matrix = tempNode.worldTransform;
    NSLog(@"%f %f %f %f",matrix.m11,matrix.m12,matrix.m13,matrix.m14);
    NSLog(@"%f %f %f %f",matrix.m21,matrix.m22,matrix.m23,matrix.m24);
    NSLog(@"%f %f %f %f",matrix.m31,matrix.m32,matrix.m33,matrix.m34);
    NSLog(@"%f %f %f %f",matrix.m41,matrix.m42,matrix.m43,matrix.m44);

    //SCNMatrix4 matrix = SCNM
    matrix_float4x4 matrix1 = self.sceneView.session.currentFrame.camera.transform;
    SCNMatrix4 matrix2 = SCNMatrix4FromMat4(matrix1);
    matrix2.m41 = 0;
    matrix2.m42 = 0;
    matrix2.m43 = 0;

    CGFloat sx = sqrt(pow(matrix2.m11, 2)+pow(matrix2.m21, 2)+pow(matrix2.m31, 2));
    CGFloat sy = sqrt(pow(matrix2.m12, 2)+pow(matrix2.m22, 2)+pow(matrix2.m32, 2));
    CGFloat sz = sqrt(pow(matrix2.m13, 2)+pow(matrix2.m23, 2)+pow(matrix2.m33, 2));

    NSLog(@"Scaling %f %f %f",sx,sy,sz);

    matrix2.m11 = matrix2.m11/sx;
    matrix2.m21 = matrix2.m21/sx;
    matrix2.m31 = matrix2.m31/sx;

    matrix2.m12 = matrix2.m12/sy;
    matrix2.m22 = matrix2.m22/sy;
    matrix2.m32 = matrix2.m32/sy;

    matrix2.m13 = matrix2.m13/sz;
    matrix2.m23 = matrix2.m23/sz;
    matrix2.m33 = matrix2.m33/sz;

    NSLog(@"\n Rotation matrix \n");
    NSLog(@"%f %f %f %f",matrix2.m11,matrix2.m12,matrix2.m13,matrix2.m14);
    NSLog(@"%f %f %f %f",matrix2.m21,matrix2.m22,matrix2.m23,matrix2.m24);
    NSLog(@"%f %f %f %f",matrix2.m31,matrix2.m32,matrix2.m33,matrix2.m34);
    NSLog(@"%f %f %f %f",matrix2.m41,matrix2.m42,matrix2.m43,matrix2.m44);

    //tempNode.worldTransform = SCNMatrix4Mult(tempNode.worldTransform, matrix2);
    SCNMatrix4  finalMatrix = SCNMatrix4Mult(SCNMatrix4Identity,matrix2);
    finalMatrix.m41 = self.endPosition.x;
    finalMatrix.m42 = self.endPosition.y;
    finalMatrix.m43 = self.endPosition.z;

    tempNode.worldTransform = finalMatrix;

    SCNNode *tempNode2 = [self createAndAddToRootNode:MarkerWidth andHeight:MarketHeight andLength:MarkerLength atPosition:self.endPosition withMaterial:[UIColor blueColor] withRotation:SCNVector4Zero];

    tempNode2.geometry.firstMaterial.diffuse.contents=@[(id)[UIColor redColor],[UIColor yellowColor]];

//    tempNode2.worldTransform = finalMatrix;
//    tempNode2.eulerAngles = SCNVector3Make(tempNode.eulerAngles.x, 0, tempNode.eulerAngles.z);

    tempNode2.rotation = self.sceneView.pointOfView.rotation;
    tempNode2.eulerAngles = SCNVector3Make(0, tempNode2.eulerAngles.y, tempNode2.eulerAngles.z);

    matrix = tempNode.worldTransform;
    NSLog(@"\n Final Matrix \n");
    NSLog(@"%f %f %f %f",matrix.m11,matrix.m12,matrix.m13,matrix.m14);
    NSLog(@"%f %f %f %f",matrix.m21,matrix.m22,matrix.m23,matrix.m24);
    NSLog(@"%f %f %f %f",matrix.m31,matrix.m32,matrix.m33,matrix.m34);
    NSLog(@"%f %f %f %f",matrix.m41,matrix.m42,matrix.m43,matrix.m44);*/
}

-(void)panningOnPlane:(UIPanGestureRecognizer*)panGesture {
    if (self.panEnabled) {
        if (panGesture.state == UIGestureRecognizerStateEnded) {
            CGFloat distance = ExtSCNVectorDistanceInCms(self.startPosition,self.endPosition);
            printf("PanningOnPlane CM = %fd", distance);
            [self.footSizeStatsView setHidden:false];
            [self.footSizeStatsView updateSizesWithDistance:distance];
            return;
        }
        if (panGesture.state == UIGestureRecognizerStateBegan) {
            [self.footSizeStatsView setHidden:true];
        }
        //IF Gesture Begain
        // - Find tap location on object.
        // - If object near bottom marker or on scale, move bottom marker.
        // - If object near top marker, move top marker.
        CGPoint point = [panGesture locationInView:self.sceneView];
        SCNVector3 worldLocation = [self worldLocationFromPoint:point];
        if (worldLocation.x == 0 && worldLocation.y == 0 && worldLocation.z == 0) {
            return;
        }else{
            SCNVector3 newEndPosition = SCNVector3Make(self.endPosition.x, self.endPosition.y, worldLocation.z);
            CGFloat minDistanceFromStart = ExtSCNVectorDistanceInCms(self.startPosition, newEndPosition);
            if (minDistanceFromStart/100 < DefaultDifferenceBetweenStartAndEnd) {
//                NSLog(@"This is the minimum foot size, you can not have less than this.");
                return;
            }
            CGFloat distanceMoved = ExtSCNVectorDistanceInCms(self.endPosition, newEndPosition);
            if (distanceMoved/100 > 0.1) {
//                NSLog(@"you are paaning too far from the end point");
                return;
            }
            self.endPosition = newEndPosition;
            self.endNode.position = self.endPosition;
            //self.nobNode.position = SCNVector3Make(self.endPosition.x + (MarkerWidth/2), self.endPosition.y, self.endPosition.z);
            self.nobNode.position = SCNVector3Make(self.nobNode.position.x, self.nobNode.position.y, newEndPosition.z);
            self.nobArrowTop.position = SCNVector3Make(self.nobArrowTop.position.x, self.nobArrowTop.position.y, newEndPosition.z - NobRadius*0.5);
            self.nobArrowBot.position = SCNVector3Make(self.nobArrowBot.position.x, self.nobArrowBot.position.y, newEndPosition.z + NobRadius*0.5);
            self.topTextNode.position = SCNVector3Make(self.topTextNode.position.x, self.topTextNode.position.y, newEndPosition.z - 0.01);
            [self drawCentimeterScale];
        }
    }
}

#pragma mark Building a Scale

-(void)drawCentimeterScale{
    CGFloat distance = ExtSCNVectorDistanceInCms(self.startPosition,self.endPosition);
    CGFloat distanceInMeters = distance/100;
    if (self.cmScaleNode == nil) {
        SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - (MarkerWidth*0.5) - (ScaleWIdth*0.5), self.startPosition.y, self.startPosition.z - (distanceInMeters*0.5));
        self.cmScaleNode = [self createScaleAndAddToRootNode:ScaleWIdth andHeight:ScaleHeight andLength:distanceInMeters atPosition:scaleStartPosition];
        [self addLineAndTextNodesToCentimeterScale:0 andNewDistance:distanceInMeters];
        [self drawScaleBaseMarker];
        [self drawBaseMarkerText];
    }else{
        SCNBox *box = (SCNBox*)self.cmScaleNode.geometry;
        SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - (MarkerWidth*0.5) - (ScaleWIdth*0.5), self.startPosition.y, self.startPosition.z - (distanceInMeters*0.5));
        box.length = distanceInMeters;
        self.cmScaleNode.position = scaleStartPosition;
        [self addLineAndTextNodesToCentimeterScale:self.presentDistance andNewDistance:distanceInMeters];
    }
}

- (void)drawScaleBaseMarker {
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, 0.07, ScaleHeight) cornerRadius:0.05];
    SCNShape *rectShape = [SCNShape shapeWithPath:rectPath extrusionDepth:0.020];
    rectShape.chamferMode = SCNChamferModeBack;
    rectShape.chamferRadius = 0.05;
    SCNMaterial *metalMaterial = [SCNMaterial material];
    metalMaterial.diffuse.contents = [UIImage imageNamed:@"metal_texture"];
    rectShape.materials = @[metalMaterial];
    //rectShape.firstMaterial.diffuse.contents = [UIColor colorWithRed:62.0/255.0 green:65.0/255.0 blue:82.0/255.0 alpha:1.0];
    self.scaleBaseNode = [SCNNode nodeWithGeometry:rectShape];
    self.scaleBaseNode.position = SCNVector3Make(self.startPosition.x - (MarkerWidth) + 0.04, self.startPosition.y, self.startPosition.z - 0.009);
    [self.sceneView.scene.rootNode addChildNode:self.scaleBaseNode];
}

- (void)drawBaseMarkerText {
    SCNText *scnText = [SCNText textWithString:@"Place back of heel here"  extrusionDepth:0.5];
    scnText.firstMaterial.diffuse.contents = [UIColor whiteColor];
    scnText.font = [UIFont systemFontOfSize:4.0];
    scnText.flatness = 1.0;
    
    SCNNode *textNode = [SCNNode nodeWithGeometry:scnText];
    textNode.position = SCNVector3Make(self.startPosition.x - (MarkerWidth/3), self.startPosition.y, self.startPosition.z + 0.02);
    textNode.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0);
    textNode.scale = SCNVector3Make(0.003, 0.003, 0.003);
    [self.sceneView.scene.rootNode addChildNode:textNode];
}

-(void)addLineAndTextNodesToCentimeterScale:(CGFloat)presentDistance andNewDistance:(CGFloat)newDistance{
    // if the newDistance is more than the present distance, add the scale from present Distance to new Distance.
    if (presentDistance < newDistance){
        while ((newDistance - 0.01) > presentDistance) {
            presentDistance = presentDistance + 0.01;
            if (self.scaleNumber % 5 == 0) {
                SCNVector3 scaleNodePosition = SCNVector3Make(self.startPosition.x- (MarkerWidth*0.5) -(CMLineWidth*0.5), self.startPosition.y+0.01, self.startPosition.z - presentDistance);
                SCNNode *node = [self createAndAddToRootNode:CMLineWidth andHeight:CMLineHeight andLength:CMLineLength atPosition:scaleNodePosition withMaterial:[UIColor blackColor] withRotation:SCNVector4Zero];
                self.scaleNodesDict[[NSNumber numberWithFloat:presentDistance]] = [[NSMutableArray alloc] initWithObjects:node, nil];
                SCNNode *textNode = [self createTextNode:scaleNodePosition andText:[NSString stringWithFormat:@"%ld ",self.scaleNumber]];
                NSMutableArray *nodesArray = [self.scaleNodesDict objectForKey:[NSNumber numberWithFloat:presentDistance]];
                if (nodesArray != NULL && nodesArray != nil && nodesArray.count > 0) {
                    [nodesArray addObject:textNode];
                }
            }else if (self.scaleNumber > 2) {
                SCNVector3 scaleNodePosition = SCNVector3Make(self.startPosition.x- (MarkerWidth*0.5) -(CMLineWidth2*0.5), self.startPosition.y+0.01, self.startPosition.z - presentDistance);
                SCNNode *node = [self createAndAddToRootNode:CMLineWidth2 andHeight:CMLineHeight andLength:CMLineLength atPosition:scaleNodePosition withMaterial:[UIColor blackColor] withRotation:SCNVector4Zero];
                self.scaleNodesDict[[NSNumber numberWithFloat:presentDistance]] = [[NSMutableArray alloc] initWithObjects:node, nil];
            }
            self.scaleNumber = self.scaleNumber + 1;
            self.presentDistance = presentDistance;
        }
    }else if ((newDistance+0.01) < presentDistance){
        while (presentDistance > newDistance) {
            NSMutableArray *nodes = [self.scaleNodesDict objectForKey:[NSNumber numberWithFloat:presentDistance]];
            for (SCNNode *node in nodes) {
                [node removeFromParentNode];
            }
            self.scaleNumber = self.scaleNumber - 1;
            [self.scaleNodesDict removeObjectForKey:[NSNumber numberWithFloat:presentDistance]];
            presentDistance = presentDistance - 0.01;
            self.presentDistance = presentDistance;
        }
    }
}

-(SCNNode*)createTextNode:(SCNVector3)position andText:(NSString*)text{
    SCNText *scnText = [SCNText textWithString:text  extrusionDepth:1.0];
    scnText.firstMaterial.diffuse.contents = [UIColor blackColor];
    scnText.font = [UIFont systemFontOfSize:4.0];
    scnText.flatness = 1.0;

    SCNNode *textNode = [SCNNode nodeWithGeometry:scnText];
    CGFloat xPosition = position.x - (CMLineWidth);
    textNode.position = SCNVector3Make(xPosition, position.y, position.z+0.015);
    textNode.eulerAngles = SCNVector3Make(-M_PI_2, 0, 0);
    textNode.scale = SCNVector3Make(0.003, 0.003, 0.003);
    [self.sceneView.scene.rootNode addChildNode:textNode];
    return textNode;
}

#pragma mark - Create and Add to rootnode

-(SCNNode*)createAndAddToRootNode:(CGFloat)width andHeight:(CGFloat)height andLength:(CGFloat)length atPosition:(SCNVector3)position withMaterial:(UIColor*)color withRotation:(SCNVector4)rotation{
    SCNBox *box = [SCNBox boxWithWidth:width height:height length:length chamferRadius:0];
    box.firstMaterial.diffuse.contents = color;
    SCNNode *node = [SCNNode nodeWithGeometry:box];
    node.position = position;
    /* rotation
     node.rotation = self.sceneView.pointOfView.rotation;
     node.eulerAngles = SCNVector3Make(0, node.eulerAngles.y, node.eulerAngles.z);
     self.tempValue = !self.tempValue;
     }*/
    [self.sceneView.scene.rootNode addChildNode:node];
    return node;
}

-(SCNNode*)createScaleAndAddToRootNode:(CGFloat)width andHeight:(CGFloat)height andLength:(CGFloat)length atPosition:(SCNVector3)position {
    SCNBox *box = [SCNBox boxWithWidth:width height:height length:length chamferRadius:0];
    
    SCNMaterial *woodMaterial = [SCNMaterial material];
    woodMaterial.diffuse.contents = [UIImage imageNamed:@"bar_background"];
    
    box.materials = @[woodMaterial];
    SCNNode *node = [SCNNode nodeWithGeometry:box];
    node.position = position;
    
    [self.sceneView.scene.rootNode addChildNode:node];
    return node;
}

#pragma mark - World location from point

-(SCNVector3)worldLocationFromPoint:(CGPoint)point{
    NSArray *hitResults = [self.sceneView hitTest:point types:(ARHitTestResultTypeExistingPlaneUsingExtent)];
    if (hitResults != nil && hitResults.count >0 ){
        ARHitTestResult *hitResult = (ARHitTestResult*)hitResults.firstObject;
        matrix_float4x4 transform = hitResult.worldTransform;
        return SCNVector3Make(transform.columns[3].x,transform.columns[3].y,transform.columns[3].z);
    }
    return SCNVector3Make(0, 0, 0);
}


#pragma mark - SCNVector3 Utilities

static inline SCNVector3 ExtSCNVector3Subtract(SCNVector3 vectorA, SCNVector3 vectorB) {
    return SCNVector3Make(vectorA.x - vectorB.x, vectorA.y - vectorB.y, vectorA.z - vectorB.z);
}

static inline CGFloat ExtSCNVectorDistanceInCms(SCNVector3 vectorA, SCNVector3 vectorB) {
    CGFloat distance = sqrt(pow(vectorA.x - vectorB.x, 2) + pow(vectorA.y - vectorB.y, 2) + pow(vectorA.z - vectorB.z, 2));
    distance = distance * 100;
    NSString* formattedString = [NSString stringWithFormat:@"%.1f", distance];
    return formattedString.floatValue;
}

#pragma mark - Get View Controller

+(ARViewController*)getARViewController{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ARKit" bundle:[NSBundle mainBundle]];
    return (ARViewController*)[storyboard instantiateViewControllerWithIdentifier:@"arViewController"];
}

#pragma mark - Instruction Delegate

-(void)clickedOnInstruction:(InstructionsModel *)model{
    switch (model.type) {
        case ARIntroduction:
//            [self.baseInstructionView popInstructionsAndPresent:[self.instructionModels objectAtIndex:1]];
//            self.currentlyShowingInstruction = [self.instructionModels objectAtIndex:1];
//            [[self backButton] setHidden:false];
            [self.baseInstructionView popInstructionView];
            if (ARWorldTrackingConfiguration.isSupported){
                [self resetTracking:true showFeaturePoints:true];
            }else{
                [self showToastViewWithErrorMessage:@"AR Tracking Not Supported!"];
            }
            self.panEnabled = true;
            [self setupGestures];
            [self.actionButtonView setHidden:true];
            [[self backButton] setHidden:false];
            [[self resetButton] setHidden:false];
            [self.actionButtonTitle setTitle:@"SAVE MY SIZE" forState:UIControlStateNormal];
            break;
        case ARPlane:
            [self.baseInstructionView popInstructionsAndPresent:[self.instructionModels objectAtIndex:3]];
            self.currentlyShowingInstruction = [self.instructionModels objectAtIndex:3];
            [[self backButton] setHidden:false];
            break;
        case ARMarker:
            //NOTE: Case not used in new flow.
            [self.baseInstructionView popInstructionView];
            [self setupGestures];
            [self.actionButtonView setHidden:false];
            break;
        case ARMeasure:
            [self.baseInstructionView popInstructionView];
            if (ARWorldTrackingConfiguration.isSupported){
                [self resetTracking:true showFeaturePoints:true];
            }else{
                [self showToastViewWithErrorMessage:@"AR Tracking Not Supported!"];
            }
            self.panEnabled = true;
            [self setupGestures];
            [self.actionButtonView setHidden:true];
            [[self resetButton] setHidden:false];
            [self.actionButtonTitle setTitle:@"SAVE MY SIZE" forState:UIControlStateNormal];
            break;
        default:
            break;
    }
}

-(void)didTapOnBackButton {
    CATransition* transition = [CATransition animation];
    transition.duration = 0.5;
    transition.type = kCATransitionFade;
    [self.navigationController.view.layer addAnimation:transition forKey:nil];
    [self.navigationController popViewControllerAnimated:false];
}

- (IBAction)clickedOnBackButton:(id)sender {
    [self.planeCalibrationView setHidden:true];
    [self.navigationController popViewControllerAnimated:true];
}
- (IBAction)clickedOnNextButton:(id)sender {
    [self.actionButtonView setHidden:true];
    switch (self.currentlyShowingInstruction.type) {
        case ARPlane:
            [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:2]];
            self.currentlyShowingInstruction = [self.instructionModels objectAtIndex:2];
            break;
            
        case ARMarker:
            [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:3]];
            self.currentlyShowingInstruction = [self.instructionModels objectAtIndex:3];
        default:
            break;
    }
}

#pragma mark - Size Stats View

//Always call this method with check to footSizeStatsView isExpandable if required.
-(void)toggleStatsViewExpand {
    CGFloat height = [self.footSizeStatsView getToggleAnimationHeight];
    [self.view layoutIfNeeded];
    BOOL transformTop = true;
    if(self.statsViewTopConstraint.constant == 0) {
        [self.statsViewTopConstraint setConstant:-height];
        transformTop = false;
    } else {
        [self.statsViewTopConstraint setConstant:0];
    }
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
        if(transformTop) {
            [self.footSizeStatsView.botArrowImageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
            [self.footSizeStatsView.containerViewTypeMultiple.botArrowImageView setTransform:CGAffineTransformMakeRotation(M_PI_2)];
        } else {
            [self.footSizeStatsView.botArrowImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [self.footSizeStatsView.containerViewTypeMultiple.botArrowImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
        }
        
        [self.view layoutIfNeeded];
    } completion:nil];
}

-(void)dismissStatsViewExpandedState {
    CGFloat height = [self.footSizeStatsView getToggleAnimationHeight];
    [self.view layoutIfNeeded];
    if (self.statsViewTopConstraint.constant == 0) { //Is in expanded state
        [self.statsViewTopConstraint setConstant:-height];
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:0 options:(UIViewAnimationOptionCurveEaseOut) animations:^{
            [self.footSizeStatsView.botArrowImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [self.footSizeStatsView.containerViewTypeMultiple.botArrowImageView setTransform:CGAffineTransformMakeRotation(-M_PI_2)];
            [self.view layoutIfNeeded];
        } completion:nil];
    }
    
}

@end
