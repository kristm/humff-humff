#import "GameScene.h"
#import "Female.h"
#import "SimpleAudioEngine.h"




@implementation GameScene

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameScene *layer = [GameScene node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
        //[director enableRetinaDisplay:NO];
        screenSize = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = YES;
        
        // Background
        bg = [CCSprite spriteWithFile:@"humfbg1.png"];
        bg.position = CGPointMake(0, screenSize.height / 2);
        bg.anchorPoint = CGPointMake(0, 0.5f);
        [self addChild:bg z:0];
        
        bg2 = [CCSprite spriteWithFile:@"humfbg1.png"];
        bg2.anchorPoint = CGPointMake(0, 0.5f);
        bg2.position = CGPointMake(screenSize.width - 1, screenSize.height / 2);
        bg2.flipX = YES;
        [self addChild:bg2 z:1];
        
        bg3 = [CCSprite spriteWithFile:@"humfbg1.png"];
        bg3.position = CGPointMake(0, screenSize.height / 2);
        bg3.anchorPoint = CGPointMake(0, 0.5f);
        //[self addChild:bg3 z:0];
                
        ship = [Ship ship];
		ship.position = CGPointMake(80, 70);
		[self addChild:ship z:10];
           
        /*Female* female = [Female female];
        female.position = CGPointMake(200, screenSize.height / 2);
		[self addChild:female z:10];
        */
        
         //CCSprite* bar  = [CCSprite spriteWithFile:@"bar.png"];
        
        
        
        //[self addChild:progressBar z:17];
        
        humf = [Humf humf];
        humf.visible = NO;
        [self addChild:humf z:11];
        
		scrollSpeed = 1.0f;
        [self initEnemies];
        
        
        [self scheduleUpdate];
        stillHumping = FALSE;
        
        playerPositionY = 70;
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"humff-prowl.wav"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2];
        
        CCProgressTimer* progressEnergy; 
        progressEnergy = [CCProgressTimer progressWithFile:@"bar.png"];
        progressEnergy.type = kCCProgressTimerTypeHorizontalBarLR;
        progressEnergy.percentage = 100.00;
        progressEnergy.position = CGPointMake(90,screenSize.height-25); //ccp(screenSize.width/2,screenSize.height/2);
        
        [self addChild:progressEnergy z:70];
        
        CCProgressTimer* progressXtacy; 
        progressXtacy = [CCProgressTimer progressWithFile:@"bar.png"];
        progressXtacy.type = kCCProgressTimerTypeHorizontalBarLR;
        progressXtacy.percentage = 100.00;
        progressXtacy.position = CGPointMake(screenSize.width -90,screenSize.height-25); //ccp(screenSize.width/2,screenSize.height/2);
        
        [self addChild:progressXtacy z:70];
        
        
        CCLabelTTF* energyLabel;
        energyLabel = [CCLabelTTF labelWithString:@"Energy" fontName:@"Arial" fontSize:15]; 
        energyLabel.position = CGPointMake(32, screenSize.height-50);
        [self addChild:energyLabel z:5];
        
        
        CCLabelTTF* xtacyLabel;
        xtacyLabel = [CCLabelTTF labelWithString:@"Ecstasy" fontName:@"Arial" fontSize:15]; 
        xtacyLabel.position = CGPointMake(screenSize.width - 37, screenSize.height-50);
        [self addChild:xtacyLabel z:5];
        
    
    }
	return self;
}

-(void) initEnemies {
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
	CCSprite* tempSpider = [CCSprite spriteWithFile:@"kitty0.png"];
	float imageHeight = [tempSpider texture].contentSize.height;
	
	int numSpiders = screenSize.width / imageHeight;
    
	NSAssert(enemies == nil, @"%@: spiders array is already initialized!", NSStringFromSelector(_cmd));
	enemies = [[CCArray alloc] initWithCapacity:numSpiders];
	
	for (int i = 0; i < numSpiders; i++){
		//CCSprite* enemy = [CCSprite spriteWithFile:@"4.png"];
        //enemy.flipY = 180;
		
        Female* enemy = [Female female];
        //enemy.position = CGPointMake(200, screenSize.height / 2);
		[self addChild:enemy z:10];
        
        //[self addChild:enemy];
		
		[enemies addObject:enemy];
	}
	
	[self resetEnemies];
}


-(void) resetEnemies {
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
	CCSprite* tempSpider = [enemies lastObject];
	CGSize imageSize = [tempSpider texture].contentSize;
    
	int numSpiders = [enemies count];
	for (int i = 0; i < numSpiders; i++){
		CCSprite* enemy = [enemies objectAtIndex:i];
		enemy.position = CGPointMake(screenSize.width+ imageSize.width, (imageSize.height) * i + imageSize.height * 0.5f);
		enemy.scale = 1;
		
		//[enemy stopAllActions];
	}
	
	[self unschedule:@selector(enemiesUpdate:)];
    [self schedule:@selector(enemiesUpdate:) interval:0.6f];
	
	numEnemiesMoved = 0;
	enemyMoveDuration = 5.0f;
}


-(void) enemiesUpdate:(ccTime)delta{
    //if (gameOver != 1) {
    	//for (int i = 0; i < 10; i++) {
			int randomEnemyIndex = CCRANDOM_0_1() * [enemies count];
			CCSprite* enemy = [enemies objectAtIndex:randomEnemyIndex];
            
			//if ([enemy numberOfRunningActions] == 0) {
                enemy.visible = YES;
                [self runEnemyMoveSequence:enemy];
                //break;
			//}
		//}
    //}
}


-(void) runEnemyMoveSequence:(CCSprite*)enemy {
	numEnemiesMoved++;
	if (numEnemiesMoved % 4 == 0 && enemyMoveDuration > 2.0f) {
		enemyMoveDuration -= 0.1f;
	}
	
	//enemy.visible = YES;
	CGPoint belowScreenPosition = CGPointMake(-[enemy texture].contentSize.width, enemy.position.y);
	CCMoveTo* move = [CCMoveTo actionWithDuration:enemyMoveDuration position:belowScreenPosition ];
    move.tag = 12;
	CCCallFuncN* callDidDrop = [CCCallFuncN actionWithTarget:self selector:@selector(enemyDidDrop:)];
	CCSequence* sequence = [CCSequence actions:move, callDidDrop, nil];
	[enemy runAction:sequence];
}



-(void) enemyDidDrop:(id)sender {
	NSAssert([sender isKindOfClass:[CCSprite class]], @"sender is not of class CCSprite!");
	CCSprite* enemy = (CCSprite*)sender;
	
	// move the spider back up outside the top of the screen
	CGPoint pos = enemy.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.x= screenSize.width + [enemy texture].contentSize.width;
	enemy.position = pos;
}


-(void) enemyDied:(int)g {
	CCSprite* enemy = [enemies objectAtIndex:g];
    //NSLog(@"%i", g);
    //enemy.visible = NO;
    //[enemy stopActionByTag:15];
    //[enemy stopActionByTag:12];
    [enemy stopAllActions];
    //[self removeChild:enemy cleanup:YES];
    
    // move the spider back up outside the top of the screen
	CGPoint pos = enemy.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.x = screenSize.width + [enemy texture].contentSize.width;
	enemy.position = pos;
}

-(void) update:(ccTime)delta
{
	
    if(stillHumping == FALSE) {
    	[self checkCollision];
        stillHumping = TRUE;
    }
    
    
    if(stillHumping == TRUE) {
    	totaltime += delta;
        if(totaltime > nextshotime) {
    		nextshotime = totaltime + 1.1f;
            //[humf stopAllActions];
            
            humf.visible = NO;
        	ship.visible = YES;
            stillHumping = FALSE;
    	}
    }
        
    
    NSNumber* factor = [speedFactors objectAtIndex:bg.zOrder];
    
    CGPoint pos = bg.position;
    pos.x -= 2; //scrollSpeed * [factor floatValue];
    
    if (pos.x < -screenSize.width) {
        bg.position = CGPointMake(screenSize.width-bg2.position.x-5, screenSize.height / 2);
        pos = bg.position; 

    }
    
    bg.position = pos;
    
    
    CGPoint pos2 = bg2.position;
    pos2.x -= 2; //scrollSpeed * [factor floatValue];
    if (pos2.x < -screenSize.width) {
        bg2.position = CGPointMake(screenSize.width-bg.position.x-5, screenSize.height / 2);
        //bg2.position = CGPointMake(screenSize.width, screenSize.height / 2);
        pos2 = bg2.position; 
    }
    
    
    bg2.position = pos2;    
    playerPositionY=ship.position.y;
    
    
    //if (playerPositionY > 70) {
    //	playerPositionY= playerPositionY-20;
    //} 
    //CGPoint pos3 = ship.position;
    //pos3.y = playerVelocity.y;
	
    /*CGSize screenSize = [[CCDirector sharedDirector] winSize];
    float imageWidthHalved = [player texture].contentSize.width * 0.5f;
    float leftBorderLimit = imageWidthHalved;
    float rightBorderLimit = screenSize.width - imageWidthHalved;
    
    if (pos.x < leftBorderLimit){
        pos.x = leftBorderLimit;        
        playerVelocity = CGPointZero;
    }
    else if (pos.x > rightBorderLimit) {
        pos.x = rightBorderLimit;        
        playerVelocity = CGPointZero;
    }*/
    
    //ship.position = pos3;
	
}


-(void)checkCollision {
    
        
        
        int numSpiders = [enemies count];
        for (int g = 0; g < numSpiders; g++){
            CCSprite* targets = [enemies objectAtIndex:g];
            
            
            CGRect targetRect = CGRectMake(
                                           targets.position.x - (targets.contentSize.width/2), 
                                           targets.position.y - (targets.contentSize.height/2), 
                                           targets.contentSize.width, 
                                           targets.contentSize.height);
            
            CGRect playerRect = CGRectMake(
                                           ship.position.x - (ship.contentSize.width/2), 
                                           ship.position.y - (ship.contentSize.height/2), 
                                           ship.contentSize.width, 
                                           ship.contentSize.height);
            
            if (CGRectIntersectsRect(playerRect, targetRect)) {
             	ship.visible = NO;
               // targets.visible = NO;
                //targets.visible = NO;
                //targets.position = CGPointMake(0, 0);
                [self enemyDied:g];
                humf.visible = YES;
                humf.position = ship.position;
                [self addChild:humf z:11];
                
                //NSLog(@"hit");
            }
            
            
         
            
            
        }
    
    
}

-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	
    
    //[ship stopAllActions];
    float deceleration = 0.4f;
	float sensitivity = 6.0f;
	float maxVelocity = 100;
    
    
    if(playerPositionY < 280) {
    	playerPositionY= playerPositionY+15;
    }
	//playerVelocity.y = playerVelocity.y * deceleration + playerPositionY * sensitivity;
	
	/*if (playerVelocity.y > maxVelocity) {
		playerVelocity.y = maxVelocity;
	}
	else if (playerVelocity.y < -maxVelocity) {
		playerVelocity.y = -maxVelocity;
	}  */
    
    
    CGPoint pos = ship.position;
    pos.y = playerPositionY;
    
    ship.position = pos;
    
    CGPoint belowScreenPosition = CGPointMake(ship.position.x, 70);
	CCMoveTo* move = [CCMoveTo actionWithDuration:3.0f position:belowScreenPosition];
	[ship runAction:move];
    
    //NSLog(@"%i", playerPositionY);
    
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{

	[super dealloc];
}
@end
