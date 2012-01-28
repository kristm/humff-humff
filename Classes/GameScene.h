//
//  HelloWorldLayer.h
//  ChasingTails
//
//  Created by Joan Gayle Villaneva on 1/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Ship.h"

// HelloWorldLayer
@interface GameScene : CCLayer
{

	CCSpriteBatchNode* spriteBatch;
    CCSprite* bg;
    CCSprite* bg2;
	CCSprite* bg3;
    int numStripes;
    
    Ship* ship;
    
	CCArray* speedFactors;
	float scrollSpeed;
    
    CCSprite* cat;    
	CGSize screenSize;
    
    CCArray* enemies;
    
    float enemyMoveDuration;
    
	int numEnemiesMoved;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
