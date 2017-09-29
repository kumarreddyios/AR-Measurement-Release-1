//
//  ViewController.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "ARViewController.h"
#import "PlaneNode.h"
#import "SizeChart.h"
#import "InstructionsModel.h"
#import "BaseInstructionVIew.h"

// start and end marker geometry
#define MarkerWidth 0.10
#define MarketHeight 0.001
#define MarkerLength 0.003

#define DefaultDifferenceBetweenStartAndEnd 0.20 /* 20 cms */

// centimeter scale geometry
#define ScaleWIdth 0.05
#define ScaleHeight 0.01
#define ScaleLength 0.05

// geometry of centimeter lines on the centimeter scale
#define CMLineWidth 0.02
#define CMLineWidth2 0.01
#define CMLineHeight 0.003
#define CMLineLength 0.002

#define CMTextWidth 0.03

@interface ARViewController () <ARSCNViewDelegate>
@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet BaseInstructionVIew *baseInstructionView;
@property (weak, nonatomic) IBOutlet UIView *footSizeStatsView;
@property (weak, nonatomic) IBOutlet UIView *gradientView;
@property (weak, nonatomic) IBOutlet UILabel *bandSize;
@property (weak, nonatomic) IBOutlet UILabel *bandSizeInCms;
@property (nonatomic, strong) NSMutableDictionary<NSString*,PlaneNode*> *dectedAnchors;
@property (nonatomic) SCNVector3 startPosition; //startpoint is fixed, it will change only if you reset the tracking or restart the process.
@property (nonatomic) SCNVector3 endPosition; // this will change when a user moved the endline.
@property (nonatomic, strong) SCNNode *startNode;
@property (nonatomic, strong) SCNNode *endNode;
@property (nonatomic) BOOL tapEnabled;
@property (nonatomic) BOOL panEnabled;
@property (nonatomic, strong) SizeChart *sizeChart;
@property (nonatomic, strong) SCNNode *cmScaleNode; // this is the centimeter scale node, to which we will add the line and text nodes.
@property (nonatomic, strong) NSMutableDictionary<NSNumber*,NSMutableArray<SCNNode*>*> *scaleNodesDict; // it will be having the list of nodes ( line node & text node ) for each centimeter.
@property (nonatomic) NSInteger scaleNumber; // it represents the scale number starting from 1.
@property (nonatomic) CGFloat presentDistance;
@property (nonatomic, strong) NSArray *instructionModels;
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
    [self loadSizeChart];
    self.scaleNodesDict = [[NSMutableDictionary alloc] init];
    self.scaleNumber = 1;
    [UIApplication.sharedApplication setIdleTimerDisabled:true];
    /*SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/marker.scn"];
    self.testNode = [[scene rootNode] childNodeWithName:@"EndNode" recursively:YES];*/

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (ARWorldTrackingConfiguration.isSupported){
            [self resetTracking];
        }else{
            // we should show an error that the iPhone does not support world tracking.
        }
        [self setupGestures];
    });

    //views decoration

    [self.footSizeStatsView setHidden:true];

    UIColor *colorOne = [UIColor colorWithRed:48.0/255.0 green:35.0/255.0 blue:174.0/255.0 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:147.0/255.0 green:61.0/255.0 blue:224.0/255.0 alpha:1.0];
    NSNumber *locationOne = [NSNumber numberWithFloat:0.3];
    NSNumber *locationTwo = [NSNumber numberWithFloat:0.7];
    NSArray *locationArray = @[locationOne, locationTwo];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    CGRect bounds = self.footSizeStatsView.frame;
    gradientLayer.frame = CGRectMake(0, 0, bounds.size.width,bounds.size.height);
    gradientLayer.colors = @[(id)colorOne.CGColor, (id)colorTwo.CGColor];
    gradientLayer.locations = locationArray;
    gradientLayer.cornerRadius = 8.0f;
    [self.gradientView.layer insertSublayer:gradientLayer atIndex:0];

    self.instructionModels = [InstructionsModel prepareInstructionsDataset];
    [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:0]];
    self.baseInstructionView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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

- (IBAction)clickedOnReset:(id)sender {
    [self resetTracking];
}

- (void)resetTracking {
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    self.sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionRemoveExistingAnchors)];
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionResetTracking)];
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
    self.panEnabled = false;
    [self.footSizeStatsView setHidden:true];
}

#pragma mark - ARSCNViewDelegate

-(void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]){
        ARPlaneAnchor *pAnchor = (ARPlaneAnchor*)anchor;
        PlaneNode *planeNode = [[PlaneNode alloc] initWithAnchor:pAnchor];
        //planeNode.simdTransform = pAnchor.transform;
        planeNode.position = SCNVector3Make(pAnchor.transform.columns[3].x, pAnchor.transform.columns[3].y, pAnchor.transform.columns[3].z);
        [self.sceneView.scene.rootNode addChildNode:planeNode];
        self.dectedAnchors[pAnchor.identifier.UUIDString]=planeNode;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.dectedAnchors.count == 1) {
                [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:2]];
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
    // Present an error message to the user
}

- (void)sessionWasInterrupted:(ARSession *)session {
    // Inform the user that the session has been interrupted, for example, by presenting an overlay
}

- (void)sessionInterruptionEnded:(ARSession *)session {
    // Reset tracking and/or remove existing anchors if consistent tracking is required
}

-(void)setupGestures{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedOnPlane:)];
    [self.sceneView addGestureRecognizer:tapGesture];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panningOnPlane:)];
    [self.sceneView addGestureRecognizer:panGesture];
}

-(void)tappedOnPlane:(UITapGestureRecognizer*)tapGesture {
    if (!self.tapEnabled) {
        CGPoint point = [tapGesture locationInView:self.sceneView];
        SCNVector3 worldLocation = [self worldLocationFromPoint:point];
        if (worldLocation.x == 0 && worldLocation.y == 0 && worldLocation.z == 0) {
            return;
        }else{
            self.tapEnabled = true;
            self.panEnabled = true;
            self.startPosition = worldLocation;
            /*NSLog(@"start position x %f y %f z %f",worldLocation.x,worldLocation.y,worldLocation.z);
            CGFloat raidians = atan(worldLocation.z);
            CGFloat newZ1 = sin(raidians);
            CGFloat newZ2 = cos(raidians);
            NSLog(@"sin %f cos %f",newZ1,newZ2);
            CGFloat raidians = atan(worldLocation.z);
            CGFloat newZ = cos(raidians);
            self.endPosition = SCNVector3Make(worldLocation.x, worldLocation.y, newZ);
            NSLog(@"end position x %f y %f z %f \n\n",worldLocation.x,worldLocation.y,newZ);
            NSLog(@"cos values %f",sin(raidians));*/
            [self createStartAndEndPonintsOnPlane];
            [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:3]];
        }
    }
}

-(void)createStartAndEndPonintsOnPlane {
    self.startNode = [self createAndAddToRootNode:MarkerWidth andHeight:MarketHeight andLength:MarkerLength atPosition:self.startPosition withMaterial:[UIColor whiteColor] withRotation:SCNVector4Zero];
    self.endPosition = ExtSCNVector3Subtract(self.startPosition, SCNVector3Make(0, 0, DefaultDifferenceBetweenStartAndEnd));
    self.endNode = [self createAndAddToRootNode:MarkerWidth andHeight:MarketHeight andLength:MarkerLength atPosition:self.endPosition withMaterial:[UIColor whiteColor] withRotation:SCNVector4Zero];
//    [self.sceneView.scene.rootNode addChildNode:self.testNode];
    self.testNode.position = self.endPosition;
    [self drawCentimeterScale];
}

-(void)panningOnPlane:(UIPanGestureRecognizer*)panGesture {
    if (self.panEnabled) {
        if (panGesture.state == UIGestureRecognizerStateEnded) {
            CGFloat distance = ExtSCNVectorDistanceInCms(self.startPosition,self.endPosition);
            [self.footSizeStatsView setHidden:false];
            NSString* formattedString = [NSString stringWithFormat:@"%.2f", distance];
            CGFloat cms = formattedString.floatValue;
            NSString *bandSize = [self.sizeChart getSizeFromCentimeters:cms];
            [self.bandSizeInCms setText:[NSString stringWithFormat:@" ( %@ cm )",formattedString]];
            [self.bandSize setText:bandSize];
            return;
        }
        if (panGesture.state == UIGestureRecognizerStateBegan) {
            [self.footSizeStatsView setHidden:true];
        }
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
        SCNBox *box = [SCNBox boxWithWidth:ScaleWIdth height:ScaleHeight length:distanceInMeters chamferRadius:0];
        box.firstMaterial.diffuse.contents = [UIColor yellowColor];
        SCNNode *node = [SCNNode nodeWithGeometry:box];
        node.position = scaleStartPosition;
        self.cmScaleNode = node;
        [self.sceneView.scene.rootNode addChildNode:self.cmScaleNode];
        [self addLineAndTextNodesToCentimeterScale:0 andNewDistance:distanceInMeters];
    }else{
        SCNBox *box = (SCNBox*)self.cmScaleNode.geometry;
        SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - (MarkerWidth*0.5) - (ScaleWIdth*0.5), self.startPosition.y, self.startPosition.z - (distanceInMeters*0.5));
        box.length = distanceInMeters;
        self.cmScaleNode.position = scaleStartPosition;
        [self addLineAndTextNodesToCentimeterScale:self.presentDistance andNewDistance:distanceInMeters];
    }
}

-(void)addLineAndTextNodesToCentimeterScale:(CGFloat)presentDistance andNewDistance:(CGFloat)newDistance{
    // if the newDistance is more than the present distance, add the scale from present Distance to new Distance.
    if (presentDistance < newDistance){
        while ((newDistance - 0.01) > presentDistance) {
            presentDistance = presentDistance + 0.01;
            if (self.scaleNumber % 5 == 0 || self.scaleNumber == 1) {
                SCNVector3 scaleNodePosition = SCNVector3Make(self.startPosition.x- (MarkerWidth*0.5) -(CMLineWidth*0.5), self.startPosition.y+0.01, self.startPosition.z - presentDistance);
                SCNNode *node = [self createAndAddToRootNode:CMLineWidth andHeight:CMLineHeight andLength:CMLineLength atPosition:scaleNodePosition withMaterial:[UIColor blackColor] withRotation:SCNVector4Zero];
                self.scaleNodesDict[[NSNumber numberWithFloat:presentDistance]] = [[NSMutableArray alloc] initWithObjects:node, nil];
                SCNNode *textNode = [self createTextNode:scaleNodePosition andText:[NSString stringWithFormat:@" %ld",self.scaleNumber]];
                NSMutableArray *nodesArray = [self.scaleNodesDict objectForKey:[NSNumber numberWithFloat:presentDistance]];
                if (nodesArray != NULL && nodesArray != nil && nodesArray.count > 0) {
                    [nodesArray addObject:textNode];
                }
            }else{
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
    scnText.font = [UIFont systemFontOfSize:6.0];
    scnText.flatness = 1.0;

    SCNNode *textNode = [SCNNode nodeWithGeometry:scnText];
    CGFloat xPosition = position.x - (CMLineWidth*0.5);
    textNode.position = SCNVector3Make(xPosition, position.y, position.z+0.01);
    textNode.eulerAngles = SCNVector3Make(0, M_PI_2, M_PI_2);
    textNode.scale = SCNVector3Make(0.003, 0.003, 0.003);
    [self.sceneView.scene.rootNode addChildNode:textNode];
    return textNode;
}

#pragma mark - Create and Add to rootnode

-(SCNNode*)createAndAddToRootNode:(CGFloat)width andHeight:(CGFloat)height andLength:(CGFloat)length atPosition:(SCNVector3)position withMaterial:(UIColor*)color withRotation:(SCNVector4)rotation{
    SCNBox *box = [SCNBox boxWithWidth:width height:height length:length chamferRadius:0];
    box.firstMaterial.diffuse.contents = color;
    SCNNode *node = [SCNNode nodeWithGeometry:box];
    node.position = position ;

    /* rotation */
    /*if (!self.tempValue) {
     node.rotation = self.sceneView.pointOfView.rotation;
     self.tempValue = !self.tempValue;
     }*/
    //    node.rotation = self.sceneView.pointOfView.rotation;
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

#pragma mark - Load the size data

-(void)loadSizeChart {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShoeSizeData" ofType:@"json"];
    NSData *sizeData = [NSData dataWithContentsOfFile:path];
    NSDictionary *sizeDictionary = [NSJSONSerialization JSONObjectWithData:sizeData options:kNilOptions error:&error];
    self.sizeChart = [[SizeChart alloc] initWithSizeDictionary:sizeDictionary];
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
            [self.baseInstructionView popInstructions];
            [self.baseInstructionView presentInstructionView:[self.instructionModels objectAtIndex:1]];
            break;
        case ARPlane:
            [self.baseInstructionView popInstructionView];
            break;
        case ARMarker:
            [self.baseInstructionView popInstructionView];
            break;
        case ARMeasure:
            [self.baseInstructionView popInstructionView];
            break;
        default:
            break;
    }
}
@end
