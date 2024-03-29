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

-(id) init
{
	if( (self=[super init])) {
        score = 0;
        bgfile = 0;
        
        regenarate = false;
        
        screenSize = [[CCDirector sharedDirector] winSize];
        self.isTouchEnabled = YES;
        
        bg = [CCSprite spriteWithFile:[NSString stringWithFormat:@"humfbg%i.png", bgfile]];
        bg.position = CGPointMake(0, screenSize.height / 2);
        bg.anchorPoint = CGPointMake(0, 0.5f);
        [self addChild:bg z:0];
        
        
        bg2 = [CCSprite spriteWithFile:[NSString stringWithFormat:@"humfbg%i.png", bgfile]];
        bg2.anchorPoint = CGPointMake(0, 0.5f);
        bg2.position = CGPointMake(screenSize.width - 1, screenSize.height / 2);
        bg2.flipX = YES;
        [self addChild:bg2 z:1];
    
        ship = [Ship ship];
		ship.position = CGPointMake(80, 70);
		[self addChild:ship z:10];
 
        
        lonely = [Lonely lonely];
        lonely.visible = NO;
		[self addChild:lonely z:10];
        
        energyPoints = 100;
        ecstacyPoints = 0;
        
        humf = [Humf humf];
        humf.visible = NO;
        [self addChild:humf z:11];
        
		scrollSpeed = 1.0f;
        [self initEnemies];
        
        
        [self scheduleUpdate];
        stillHumping = 0;
        
        playerPositionY = 70;
        
        [[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"humff-prowl.wav"];
        [[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.2];
        
        
        progressEnergy = [CCProgressTimer progressWithFile:@"bar.png"];
        progressEnergy.type = kCCProgressTimerTypeHorizontalBarLR;
        progressEnergy.percentage = energyPoints;
        progressEnergy.position = CGPointMake(90,screenSize.height-25); //ccp(screenSize.width/2,screenSize.height/2);
        
        [self addChild:progressEnergy z:70];
        
        CCSprite* border;
        border = [CCSprite spriteWithFile:@"baroutline.png"];
        border.position = CGPointMake(90, screenSize.height-25);
        [self addChild:border z:71];
        
        progressXtacy = [CCProgressTimer progressWithFile:@"bar.png"];
        progressXtacy.type = kCCProgressTimerTypeHorizontalBarLR;
        progressXtacy.percentage = ecstacyPoints;
        progressXtacy.position = CGPointMake(screenSize.width -90,screenSize.height-25); //ccp(screenSize.width/2,screenSize.height/2);
        
        [self addChild:progressXtacy z:70];
        
        CCSprite* border2;
        border2 = [CCSprite spriteWithFile:@"baroutline.png"];
        border2.position = CGPointMake(screenSize.width -90,screenSize.height-25);
        [self addChild:border2 z:71];
        
        energyLabel = [CCLabelTTF labelWithString:@"Energy" fontName:@"Arial" fontSize:15]; 
        energyLabel.position = CGPointMake(32, screenSize.height-50);
        [self addChild:energyLabel z:500];
        
        xtacyLabel = [CCLabelTTF labelWithString:@"Ecstasy" fontName:@"Arial" fontSize:15]; 
        xtacyLabel.position = CGPointMake(screenSize.width - 37, screenSize.height-50);
        [self addChild:xtacyLabel z:500];
        
        
        scoreLabel = [CCLabelTTF labelWithString:[NSString stringWithFormat:@"%d",score] fontName:@"Sniglet.ttf" fontSize:50];
        scoreLabel.position = CGPointMake(screenSize.width/2, screenSize.height-30);
        scoreLabel.color = ccc3(171,22,52); //171,22,52 - day color    137,195,35 - reverse
        [self addChild:scoreLabel z:500];
        
        
        energyLabel.color = ccc3(0,0,0);  
        xtacyLabel.color = ccc3(0,0,0);
        
        bgCounter = 0;
        
    
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
	    Female* enemy = [Female female];
    	[self addChild:enemy z:10];
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
		enemy.position = CGPointMake(screenSize.width+ imageSize.width, ((imageSize.height) * i + imageSize.height * 0.5f)-175);
		//enemy.scale = 1;
		
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
	
	CGPoint pos = enemy.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.x= screenSize.width + [enemy texture].contentSize.width;
	enemy.position = pos;
}


-(void) enemyDied:(int)g {
    
    stillHumping = 1;
	CCSprite* enemy = [enemies objectAtIndex:g];

    [enemy stopAllActions];
    
	CGPoint pos = enemy.position;
	CGSize screenSize = [[CCDirector sharedDirector] winSize];
	pos.x = screenSize.width + [enemy texture].contentSize.width;
	enemy.position = pos;
    
    
}

-(void) update:(ccTime)delta
{
	
    if(regenarate == true) {
        totaltime += delta;
        if(totaltime > nextshotime) {
            nextshotime = totaltime + .060;

            if(energyPoints <= 100) {
                energyPoints  += 1;
            }    
        
            if (ecstacyPoints > 0) {
                ecstacyPoints -= 1;
            }
        }    
    }
    
    if (energyPoints >= 100) {
        regenarate = false;
        ship.visible = YES;
        lonely.visible = NO;
    }
    
    if(regenarate==false){
    	canHump = (energyPoints <= 0) ? false : true;
    }
    
    if(stillHumping == 0) {
        if(canHump){
            [self checkCollision];
        }else{
            ship.visible = NO;
            lonely.visible = YES;
            lonely.position = ship.position;
            regenarate =true;
        }
    }else {
        totaltime += delta;
        if(totaltime > nextshotime) {
            nextshotime = totaltime + 1.1f;
            if(energyPoints > 0) {
                energyPoints  -= 10;
            }    
            
            if (ecstacyPoints < 100) {
                ecstacyPoints += 10;
            }    
            
            humf.visible = NO;
            ship.visible = YES;
            stillHumping = 0;
        }
        
        
    }
    
    progressXtacy.percentage = ecstacyPoints;    
    progressEnergy.percentage = energyPoints;
    
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

        
        
        
        bgCounter++;
        
        if(bgCounter > 2) {
            bgCounter = 0;
            
            
            if(bgfile == 0) {
                bgfile = 1;
                scoreLabel.color = ccc3(137,195,35); //171,22,52 - day color    137,195,35 - reverse
                energyLabel.color = ccc3(255,255,255);  
                xtacyLabel.color = ccc3(255,255,255); 
            }else{
                bgfile = 0;
                scoreLabel.color = ccc3(171,22,52); //171,22,52 - day color    137,195,35 - reverse
                energyLabel.color = ccc3(0,0,0);  
                xtacyLabel.color = ccc3(0,0,0); 
                
            }
            
            
            CCTexture2D *tex0 = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"humfbg%i.png", bgfile]];
            CCTexture2D *tex1 = [[CCTextureCache sharedTextureCache] addImage:[NSString stringWithFormat:@"humfbg%i.png", bgfile]];
            
            bg.texture = tex0;
            bg2.texture = tex0;            
            
        }
        
    }
    
    
    bg2.position = pos2;    
    playerPositionY=ship.position.y;
	
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
                                           ship.contentSize.width/2, 
                                           ship.contentSize.height/2);
            
            if (CGRectIntersectsRect(playerRect, targetRect)) {
                score += 1;
             	ship.visible = NO;
                [self enemyDied:g];
                humf.visible = YES;
                humf.position = ship.position;
                [[SimpleAudioEngine sharedEngine] playEffect:@"cat-meow.wav"];
                [self addChild:humf z:11];

                
                
                //NSLog(@"hit");
            }
            
            
         
            
            
        }
    //NSLog(@"score ---> %d",score);
    [scoreLabel setString:[NSString stringWithFormat:@"%d",score]];

    
    
}




-(void) ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(playerPositionY < 225) {
    	playerPositionY= playerPositionY+15;
    }
    
    CGPoint pos = ship.position;
    pos.y = playerPositionY;
    
    ship.position = pos;
    
    CGPoint belowScreenPosition = CGPointMake(ship.position.x, 70);
	CCMoveTo* move = [CCMoveTo actionWithDuration:3.0f position:belowScreenPosition];
	[ship runAction:move];
    
    
}

- (void) dealloc
{

	[super dealloc];
}
@end
