//
//  WaitingPenguin.m
//  PeevedPenguins
//
//  Created by Phillip Ou on 6/25/14.
//  Copyright (c) 2014 Apportable. All rights reserved.
//

#import "WaitingPenguin.h"

@implementation WaitingPenguin
-(void) didLoadFromCCB{
    float delay = (arc4random() %2000)/ 1000.f; //generate random number
    
    //start animation after random delay
    
    [self performSelector: @selector(startBlinkAndJump)withObject: nil afterDelay: delay];
}

-(void) startBlinkAndJump{
    //the animation manager property of each ccsprite node is stored in animationManager
    CCAnimationManager *animationManager = self.animationManager;
    //run animation from BlinkAndJump file
    [animationManager runAnimationsForSequenceNamed:@"BlinkAndJump"];
}
@end
