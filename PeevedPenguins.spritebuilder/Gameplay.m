//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Phillip Ou on 6/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_levelNode;
    CCNode *_catapultArm;
    CCNode *_contentNode;
    CCNode *_pullbackNode;
    CCNode *_mouseJointNode;
    CCPhysicsJoint *_mouseJoint;
    CCNode *_currentPenguin;
    CCPhysicsJoint *_penguinCatapultJoint;
}

-(void) didLoadFromCCB{
    self.userInteractionEnabled=TRUE;
    CCScene *level = [CCBReader loadAsScene: @"Levels/Level1"];
    [_levelNode addChild: level];
    //_physicsNode.debugDraw= TRUE;
    _pullbackNode.physicsBody.collisionMask=@[];//nothing collides with the pullbacknode
    _mouseJointNode.physicsBody.collisionMask=@[];
    
    _physicsNode.collisionDelegate = self;
}




-(void) launchPenguins{
    CCNode *penguin = [CCBReader load: @"Penguin"]; //create variable penguin from spriteBuilder file Penguin
   //CCNode *contentNode = [CCBReader load: @"Gameplay"];
    
    //position penguin at bowl of catapult
    penguin.position = ccpAdd(_catapultArm.position, ccp(16,50));
    
    // add the penguin to the physicsNode of this scene (because it has physics enabled)
    [_physicsNode addChild: penguin];   //make it a child of the _physicsNode
    
    // manually create & apply a force to launch the penguin
    CGPoint launchDirection = ccp(1, 0);
    CGPoint force = ccpMult(launchDirection, 8000);
    [penguin.physicsBody applyForce:force];
    
    
    
    //ensure object is followed by camera
    self.position = ccp(0,0);
    CCAction *follow= [CCActionFollow actionWithTarget:penguin worldBoundary: self.boundingBox];
    [_contentNode runAction: follow];   //runaction is method that asks camera to follow object
    
}

-(void) retry{
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"Gameplay"]];
}

//this function is called everytime something is touched

-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchLocation = [touch locationInNode:_contentNode];
    
    // start catapult dragging when a touch inside of the catapult arm occurs
    if (CGRectContainsPoint([_catapultArm boundingBox], touchLocation))
    {
        // move the mouseJointNode to the touch position
        _mouseJointNode.position = touchLocation;
        
        // setup a spring joint between the mouseJointNode and the catapultArm
        _mouseJoint = [CCPhysicsJoint connectedSpringJointWithBodyA:_mouseJointNode.physicsBody bodyB:_catapultArm.physicsBody anchorA:ccp(0, 0) anchorB:ccp(34, 138) restLength:0.f stiffness:3000.f damping:150.f];
        
        //create a penguin
        _currentPenguin = [CCBReader load:@"Penguin"];
        
        CGPoint penguinPosition = [_catapultArm convertToWorldSpace:ccp(34,138)];
        //transform the world position to the node space to which the penguin will be added
        _currentPenguin.position = [_physicsNode convertToNodeSpace: penguinPosition];
        
        [_physicsNode addChild: _currentPenguin]; //make current Penguin a physics node
        
        _currentPenguin.physicsBody.allowsRotation = FALSE;
        
        // create a joint to keep the penguin fixed to the scoop until the catapult is released
        _penguinCatapultJoint = [CCPhysicsJoint connectedPivotJointWithBodyA:_currentPenguin.physicsBody bodyB:_catapultArm.physicsBody anchorA:_currentPenguin.anchorPointInPoints];
        
        
    }
}
-(void)touchMoved:(UITouch *)touch withEvent: (UIEvent *) event{
    //whenever touches move update position of mouseJointNode to the touch
    CGPoint touchLocation = [touch locationInNode: _contentNode];
    _mouseJointNode.position = touchLocation;
}
-(void) releaseCatapult{
    if (_mouseJoint !=nil){
        [_mouseJoint invalidate];   //release mouseJoint
        _mouseJoint = nil;          //destroy mouse joint
    
        [_penguinCatapultJoint invalidate]; //release penguinJoint
        _penguinCatapultJoint = nil;    //destroy penguinJoint
        
        _currentPenguin.physicsBody.allowsRotation = TRUE; //now we allow rotation after catapult release
        
        CCAction *follow = [CCActionFollow actionWithTarget: _currentPenguin worldBoundary:self.boundingBox];
        [_contentNode runAction: follow];
    }
    
}

//when touch ends we want to release the catapult


-(void) touchEnded:(UITouch *)touch withEvent:(UIEvent *)event{
    [self releaseCatapult];
    
}

-(void)ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA wildcard:(CCNode *)nodeB{
    CCLOG(@"Something Collided with a Seal");
}

-(void) sealRemoved: (CCNode *) seal{
    [seal removeFromParent];
}

-(void) ccPhysicsCollisionPostSolve:(CCPhysicsCollisionPair *)pair seal:(CCNode *)nodeA typeB:(CCNode *)nodeB{
   
    float energy = [pair totalKineticEnergy];
    
    if(energy >50.f){
        [[_physicsNode space] addPostStepBlock:^{
            [self sealRemoved: nodeA];}
                                           key:nodeA];
    }
}


@end
