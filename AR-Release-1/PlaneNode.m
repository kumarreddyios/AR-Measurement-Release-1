//
//  PlaneNode.m
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import "PlaneNode.h"
#import <ARKit/ARKit.h>

@interface PlaneNode() {
    ARPlaneAnchor *_anchor;
    SCNNode *_childNode;
}
@end

@implementation PlaneNode

-(instancetype)initWithAnchor:(ARPlaneAnchor*)detectedAnchor{
    self = [super init];
    if (self){
        _anchor = detectedAnchor;
        [self createNode];
    }
    return self;
}

-(void) createNode{
    SCNBox *childBox = [SCNBox boxWithWidth:_anchor.extent.x height:0 length:_anchor.extent.z chamferRadius:0];
    childBox.firstMaterial.diffuse.contents = [UIColor colorWithRed:0/255 green:0/255 blue:0/255 alpha:0.6];
    SCNNode *childNode = [SCNNode nodeWithGeometry:childBox];
    _childNode = childNode;
    [self addChildNode:childNode];
}

-(void) updateNode:(ARPlaneAnchor*)updatedAnchor{
    _anchor = updatedAnchor;
    SCNBox  *childBox = (SCNBox*) _childNode.geometry;
    childBox.width = updatedAnchor.extent.x;
    childBox.length = updatedAnchor.extent.z;
}

@end
