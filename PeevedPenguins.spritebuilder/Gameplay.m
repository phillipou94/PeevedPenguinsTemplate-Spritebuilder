//
//  Gameplay.m
//  PeevedPenguins
//
//  Created by Phillip Ou on 6/24/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "Gameplay.h"

@implementation Gameplay{
    CCPhysicsNode *_physicsNode;
    CCNode *_levelNode;
    CCNode *_catapultArm;
    CCNode *_contentNode;
}

-(void) didLoadFromCCB{
    self.userInteractionEnabled=TRUE;
    CCScene *level = [CCBReader loadAsScene: @"Levels/Level1"];
    [_levelNode addChild: level];
}

//this function is called everytime something is touched
-(void) touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    [self launchPenguins];
    
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
@end
