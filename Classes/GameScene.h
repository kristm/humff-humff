//
//  HelloWorldLayer.h
//  Humff Humff
//
//  Created by Joan Gayle Villaneva on 1/27/12.
//  Copyright __MyCompanyName__ 2012. All rights reserved.
//


// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Ship.h"
#import "Humf.h"
#import "Lonely.h"


// HelloWorldLayer
@interface GameScene : CCLayer
{

	CCSpriteBatchNode* spriteBatch;
    CCSprite* bg;
    CCSprite* bg2;
	CCSprite* bg3;
    Humf* humf;
    Lonely* lonely;
    CCTexture2D *tex0;
    CCTexture2D *tex1; 
    CCLabelTTF* energyLabel;
    CCLabelTTF* xtacyLabel;
    
    int numStripes;
    
    Ship* ship;
    
	CCArray* speedFactors;
	float scrollSpeed;
    
    CCSprite* cat;    
	CGSize screenSize;
    
    CCArray* enemies;
    
    float enemyMoveDuration;
    
	int numEnemiesMoved;
    int stillHumping;
    bool canHump;
    bool regenarate;
    
    float totaltime;
    float nextshotime;
    
    int playerPositionY;
    CGPoint playerVelocity;
    
    CCProgressTimer* progressEnergy; 
    CCProgressTimer* progressXtacy; 
    
    int energyPoints;
    int ecstacyPoints;
    
    int score;
    CCLabelTTF* scoreLabel;
    int bgfile;
    int bgCounter;
    
    int touchBegan;
    
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

@end
