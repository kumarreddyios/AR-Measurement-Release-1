//
//  ViewController.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "ViewController.h"
#import "PlaneNode.h"
#import "SizeChart.h"

#define BoxWidth 0.10
#define BoxHeight 0.001
#define BoxLength 0.005
#define DefaultDifferenceBetweenStartAndEnd 0.20 /* 20 cms */
#define ScaleWIdth 0.05
#define ScaleHeight 0.01
#define ScaleLength 0.05

@interface ViewController () <ARSCNViewDelegate>

@property (nonatomic, strong) IBOutlet ARSCNView *sceneView;
@property (weak, nonatomic) IBOutlet UIView *statsView;
@property (weak, nonatomic) IBOutlet UILabel *cmsLabel;
@property (weak, nonatomic) IBOutlet UILabel *ukSizeLabel;
@property (nonatomic, strong) NSMutableDictionary<NSString*,PlaneNode*> *dectedAnchors;
@property (nonatomic) SCNVector3 startPosition; //startpoint is fixed, it will change only if you reset the tracking or restart the process.
@property (nonatomic) SCNVector3 endPosition; // this will change when a user moved the endline.
@property (nonatomic, strong) SCNNode *startNode;
@property (nonatomic, strong) SCNNode *endNode;
@property (nonatomic) BOOL tapEnabled;
@property (nonatomic) BOOL panEnabled;
@property (nonatomic) BOOL tempValue;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSMutableArray *scaleNodes;
@property (nonatomic, strong) SizeChart *sizeChart;
@property (nonatomic, strong) SCNNode *cmScaleNode;
@end

    
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.sceneView.delegate = self;
    //self.sceneView.showsStatistics = true;
    self.sceneView.scene = [[SCNScene alloc] init];
    self.dectedAnchors = [[NSMutableDictionary alloc] init];
    self.tapEnabled = false;
    self.panEnabled = false;
    self.colors = @[[UIColor redColor],[UIColor blackColor],[UIColor greenColor],[UIColor blueColor],[UIColor yellowColor],[UIColor cyanColor]];
    self.scaleNodes = [[NSMutableArray alloc] init];
    [self loadSizeChart];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (ARWorldTrackingConfiguration.isSupported){
        [self resetTracking];
    }else{
        //return
    }
    [self setupGestures];

    //views decoration
    self.statsView.layer.cornerRadius = 8.0f;
    [self.statsView setHidden:true];
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

- (void)resetTracking {
    ARWorldTrackingConfiguration *configuration = [ARWorldTrackingConfiguration new];
    configuration.planeDetection = ARPlaneDetectionHorizontal;
    self.sceneView.debugOptions = ARSCNDebugOptionShowFeaturePoints;
    [self.sceneView.session runWithConfiguration:configuration options:(ARSessionRunOptionResetTracking)];
}

#pragma mark - ARSCNViewDelegate

-(void)renderer:(id<SCNSceneRenderer>)renderer didAddNode:(SCNNode *)node forAnchor:(ARAnchor *)anchor{
    if ([anchor isKindOfClass:[ARPlaneAnchor class]]){
        ARPlaneAnchor *pAnchor = (ARPlaneAnchor*)anchor;
        PlaneNode *planeNode = [[PlaneNode alloc] initWithAnchor:pAnchor];
        planeNode.position = SCNVector3Make(pAnchor.transform.columns[3].x, pAnchor.transform.columns[3].y, pAnchor.transform.columns[3].z);
        [self.sceneView.scene.rootNode addChildNode:planeNode];
        self.dectedAnchors[pAnchor.identifier.UUIDString]=planeNode;
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
            [self createStartAndEndPonintsOnPlane];
        }
    }
}


-(void)panningOnPlane:(UIPanGestureRecognizer*)panGesture {
    if (self.panEnabled) {
        CGPoint point = [panGesture locationInView:self.sceneView];
        SCNVector3 worldLocation = [self worldLocationFromPoint:point];
        if (worldLocation.x == 0 && worldLocation.y == 0 && worldLocation.z == 0) {
            return;
        }else{
            self.endPosition = SCNVector3Make(self.endPosition.x, self.endPosition.y, worldLocation.z);
            self.endNode.position = self.endPosition;
            [self buildAScale];
        }
    }
}

-(void)createStartAndEndPonintsOnPlane {
    self.startNode = [self createAndAddToRootNode:self.startPosition withMaterial:[UIColor redColor]];
    /* increase the Z co ordiante by DefaultDifferenceBetweenStartAndEnd and draw end line*/
    self.endPosition = ExtSCNVector3Subtract(self.startPosition, SCNVector3Make(0, 0, DefaultDifferenceBetweenStartAndEnd));
    self.endNode = [self createAndAddToRootNode:self.endPosition withMaterial:[UIColor blueColor]];
    [self buildAScale];
}


-(SCNVector3)worldLocationFromPoint:(CGPoint)point{
    NSArray *hitResults = [self.sceneView hitTest:point types:(ARHitTestResultTypeExistingPlaneUsingExtent)];
    if (hitResults != nil && hitResults.count >0 ){
        ARHitTestResult *hitResult = (ARHitTestResult*)hitResults.firstObject;
        matrix_float4x4 transform = hitResult.worldTransform;
        return SCNVector3Make(transform.columns[3].x,transform.columns[3].y,transform.columns[3].z);
    }
    return SCNVector3Make(0, 0, 0);
}

-(SCNNode*)createAndAddToRootNode:(SCNVector3)position withMaterial:(UIColor*)color{
    SCNBox *box = [SCNBox boxWithWidth:BoxWidth height:BoxHeight length:BoxLength chamferRadius:0];
    box.firstMaterial.diffuse.contents = color;
    SCNNode *node = [SCNNode nodeWithGeometry:box];
    node.position = position ;

    /* rotation */
    /*if (!self.tempValue) {
        node.rotation = self.sceneView.pointOfView.rotation;
        self.tempValue = !self.tempValue;
    }*/
    [self.sceneView.scene.rootNode addChildNode:node];
    return node;
}

#pragma mark Building a Scale

-(void)buildAScale{
    /*remove the scale nodes*/
    for (int index = 0; index < self.scaleNodes.count; index++) {
        SCNNode *scaleNode = [self.scaleNodes objectAtIndex:index];
        [scaleNode removeFromParentNode];
    }
    CGFloat prevLength = 0;
    CGFloat distance = ExtSCNVectorDistanceInCms(self.startPosition,self.endPosition);
    [self.statsView setHidden:false];
    NSString* formattedString = [NSString stringWithFormat:@"%.1f cms", distance];
    [self.cmsLabel setText:formattedString];
    /*SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - 0.1, self.startPosition.y, self.startPosition.z - ScaleLength/2);
    while (prevLength < (distance/100)) {
        SCNBox *box = [SCNBox boxWithWidth:ScaleWIdth height:ScaleHeight length:ScaleLength chamferRadius:0];
        box.firstMaterial.diffuse.contents = [self getRandomColor];
        SCNNode *node = [SCNNode nodeWithGeometry:box];
        node.position = scaleStartPosition;
        [self.sceneView.scene.rootNode addChildNode:node];
        [self.scaleNodes addObject:node];
        scaleStartPosition = SCNVector3Make(scaleStartPosition.x, scaleStartPosition.y, scaleStartPosition.z - ScaleLength);
        prevLength = prevLength + ScaleLength;
    }*/

    if (self.cmScaleNode == nil) {
        SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - 0.1, self.startPosition.y, self.startPosition.z - (distance/200));
        SCNBox *box = [SCNBox boxWithWidth:ScaleWIdth height:ScaleHeight length:(distance/100) chamferRadius:0];
        box.firstMaterial.diffuse.contents = [UIColor yellowColor];
        SCNNode *node = [SCNNode nodeWithGeometry:box];
        node.position = scaleStartPosition;
        self.cmScaleNode = node;
        [self.sceneView.scene.rootNode addChildNode:self.cmScaleNode];
        [self buildCentimeterScaleFor:self.cmScaleNode presentDistance:0 andNewDistance:(CGFloat)distance/100];
    }else{
        SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - 0.1, self.startPosition.y, self.startPosition.z - (distance/200));
        SCNBox *box = (SCNBox*)self.cmScaleNode.geometry;
        box.length = (distance/100);
        self.cmScaleNode.position = scaleStartPosition;
    }
}

-(void)buildCentimeterScaleFor:(SCNNode*)node presentDistance:(CGFloat)presentDistance andNewDistance:(CGFloat)newDistance{
    // if the newDistance is more than the present distance, add the scale from present Distance to new Distance.
    // presentDistance < newDistance
    while (presentDistance < newDistance) {
        presentDistance = presentDistance + 0.01;
        SCNBox *box = [SCNBox boxWithWidth:ScaleWIdth/2 height:0.005 length:0.002 chamferRadius:0];
        box.firstMaterial.diffuse.contents = [UIColor blackColor];
        SCNNode *tempNode = [SCNNode nodeWithGeometry:box];
        tempNode.position = SCNVector3Make(self.startPosition.x-0.1, self.startPosition.y+0.01, self.startPosition.z - presentDistance);
        [self.sceneView.scene.rootNode addChildNode:tempNode];

    }


//    SCNVector3 scaleStartPosition = SCNVector3Make(self.startPosition.x - 0.1, self.startPosition.y, self.startPosition.z - (distance/200));


}

#pragma mark SCNVector3 - Utilities

static inline SCNVector3 ExtSCNVector3Subtract(SCNVector3 vectorA, SCNVector3 vectorB) {
    return SCNVector3Make(vectorA.x - vectorB.x, vectorA.y - vectorB.y, vectorA.z - vectorB.z);
}

static inline CGFloat ExtSCNVectorDistanceInCms(SCNVector3 vectorA, SCNVector3 vectorB) {
    CGFloat distance = sqrt(pow(vectorA.x - vectorB.x, 2) + pow(vectorA.y - vectorB.y, 2) + pow(vectorA.z - vectorB.z, 2));
    distance = distance * 100;
    NSString* formattedString = [NSString stringWithFormat:@"%.1f", distance];
    return formattedString.floatValue;
}

/*static inline SCNVector3 ExtSCNVector3Add(SCNVector3 vectorA,SCNVector3 vectorB){
    return SCNVector3Make(vectorA.x + vectorB.x, vectorA.y + vectorB.y, vectorA.z + vectorB.z);
}*/

#pragma mark Random color generator

-(UIColor*)getRandomColor {
    /*int r = arc4random() % 255;
    int g = arc4random() % 255;
    int b = arc4random() % 255;
    NSLog(@" r g b values %d %d %d",r,g,b);
    return [UIColor colorWithRed:r/255 green:g/255 blue:b/255 alpha:1.0];*/

    int random = arc4random() % self.colors.count;
    return [self.colors objectAtIndex:random];
}

#pragma mark - load the size data

-(void)loadSizeChart {
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ShoeSizeData" ofType:@"json"];
    NSData *sizeData = [NSData dataWithContentsOfFile:path];
    NSDictionary *sizeDictionary = [NSJSONSerialization JSONObjectWithData:sizeData options:kNilOptions error:&error];
    self.sizeChart = [[SizeChart alloc] initWithSizeDictionary:sizeDictionary];
}

@end
