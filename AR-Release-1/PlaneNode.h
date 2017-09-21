//
//  PlaneNode.h
//  AR-Release-1
//
//  Created by Birapuram Kumar Reddy on 9/20/17.
//  Copyright © 2017 Myntra Design Pvt Ltd. All rights reserved.
//

#import <SceneKit/SceneKit.h>
#import <ARKit/ARKit.h>

@interface PlaneNode : SCNNode

-(instancetype)initWithAnchor:(ARPlaneAnchor*)planeAnchor;
-(void) updateNode:(ARPlaneAnchor*)updatedAnchor;

@end
