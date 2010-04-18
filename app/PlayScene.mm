//
// Demo of calling integrating Box2D physics engine with cocos2d AtlasSprites
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// by Steve Oldmeadow
//

// Import the interfaces
#import "PlayScene.h"
#import "GameOverScene.h"
#import "SimpleAudioEngine.h"


#if __cplusplus
extern "C" {
#endif
    void register_view(UIView*);
    void init();
    void render();
    char* get_title();
    void did_accelerate(UIAccelerometer*, UIAcceleration*);
    void touches_began(NSSet*, UIEvent*);
    void touches_moved(NSSet*, UIEvent*);
    void touches_ended(NSSet*, UIEvent*);
    void touches_cancelled(NSSet*, UIEvent*);
#if __cplusplus
}
#endif

#define MIN_SPEED 0.6
#define MAX_SPEED 1.6


//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagSpriteSheet = 1,
	kTagAnimation1 = 1,
};


// HelloWorld implementation
@implementation Play

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Play *layer = [Play node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) {


		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
		centre = screenSize.width/2;
		horizon = screenSize.height/2; 
		// Define the gravity vector.
		b2Vec2 gravity;
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
		
		
		// Define the ground body.
		b2BodyDef groundBodyDef;
		groundBodyDef.position.Set(0, 0); // bottom-left corner
		
		// Call the body factory which allocates memory for the ground body
		// from a pool and creates the ground box shape (also from a pool).
		// The body is also added to the world.
		b2Body* groundBody = world->CreateBody(&groundBodyDef);
		
		// Define the ground box shape.
		b2PolygonShape groundBox;		
		
		// bottom
		groundBox.SetAsEdge(b2Vec2(0,0), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// top
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO));
		groundBody->CreateFixture(&groundBox,0);
		
		// left
		groundBox.SetAsEdge(b2Vec2(0,screenSize.height/PTM_RATIO), b2Vec2(0,0));
		groundBody->CreateFixture(&groundBox,0);
		
		// right
		groundBox.SetAsEdge(b2Vec2(screenSize.width/PTM_RATIO,screenSize.height/PTM_RATIO), b2Vec2(screenSize.width/PTM_RATIO,0));
		groundBody->CreateFixture(&groundBox,0);
		
//		b2Vec2 gravity( -1 * 10, 1 * 10);
//		world->SetGravity( gravity );
		
		
		//Set up sprite
		
		CCSpriteSheet *sheet = [CCSpriteSheet spriteSheetWithFile:@"blocks.png" capacity:150];
		[self addChild:sheet z:0 tag:kTagSpriteSheet];
		
		[self addNewSpriteWithCoords:ccp(screenSize.width/2, screenSize.height/2)];
		
		CCLabel *label = [CCLabel labelWithString:@"Truck Game" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(255,255,255)];
		label.position = ccp( screenSize.width/2, screenSize.height-50);
//		[self schedule: @selector(itsOver)	interval:14.0];
		[self schedule: @selector(tick:)];

		engineSpeed = 1.0;
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.3];
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:1.0];	
		[[SimpleAudioEngine sharedEngine] playBackgroundMusic:@"cc.mp3"];
		
		engineThread = [[NSThread alloc] initWithTarget:self 
											   selector:@selector(engine) 
												 object:nil];
	

	}
	nextBeat=[[NSDate alloc] initWithTimeIntervalSinceNow:0.0];
	[engineThread start];
	
	return self;
}

-(void) engine
{
	while (![[NSThread currentThread] isCancelled]) {

		CCLOG(@"%d %d %0.2f ",currentAction, latestAction, engineSpeed);
		
			
		[[SimpleAudioEngine sharedEngine] playEffect:@"Engine5.wav" pitch:engineSpeed pan:0 gain:1];
		newNextBeat=[[NSDate alloc] initWithTimeInterval:0.07/engineSpeed sinceDate:nextBeat];
        [nextBeat release];
        nextBeat=newNextBeat;
        [NSThread sleepUntilDate:nextBeat];
	}
}


-(void) itsOver
{
	[engineThread cancel];
	NSLog(@"GAMEOVER");
	[[CCDirector sharedDirector] replaceScene:[CCFadeTransition transitionWithDuration:1.0 scene:[GameOver node]]];	
	
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	render();
}


-(void) addNewSpriteWithCoords:(CGPoint)p
{
//	CCLOG(@"Add sprite %0.2f x %02.f",p.x,p.y);
	CCSpriteSheet *sheet = (CCSpriteSheet*) [self getChildByTag:kTagSpriteSheet];
	
	//We have a 64x64 sprite sheet with 4 different 32x32 images.  The following code is
	//just randomly picking one of the images
	int idx = (CCRANDOM_0_1() > .5 ? 0:1);
	int idy = (CCRANDOM_0_1() > .5 ? 0:1);
	CCSprite *sprite = [CCSprite spriteWithSpriteSheet:sheet rect:CGRectMake(32 * idx,32 * idy,32,32)];
	[sheet addChild:sprite];
	
	sprite.position = ccp( p.x, p.y);
	
	// Define the dynamic body.
	//Set up a 1m squared box in the physics world
	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;

	bodyDef.position.Set(p.x/PTM_RATIO, p.y/PTM_RATIO);
	bodyDef.userData = sprite;
	b2Body *body = world->CreateBody(&bodyDef);
	
	// Define another box shape for our dynamic body.
	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(.5f, .5f);//These are mid points for our 1m box
	
	// Define the dynamic body fixture.
	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;	
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.3f;
	body->CreateFixture(&fixtureDef);
}



-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	
	if(currentAction == 3 && engineSpeed < MAX_SPEED) {
		engineSpeed = engineSpeed + 0.01;	
	}
	if(currentAction == 4 && engineSpeed > MIN_SPEED) {
		engineSpeed = engineSpeed - 0.02;	
	} else if(currentAction == 0 && engineSpeed > MIN_SPEED) {
		engineSpeed = engineSpeed - 0.001;
	}
	
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			//Synchronize the AtlasSprites position and rotation with the corresponding body
			CCSprite *myActor = (CCSprite*)b->GetUserData();
			myActor.position = CGPointMake( b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
			myActor.rotation = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
		}	
	}
}



-(int8) input:(CGPoint)p
{
	
	if (p.x >= centre && p.y >= horizon) {
		currentAction = 1;
	} else if (p.x < centre && p.y >= horizon) {
		currentAction = 2;
	} else if (p.x >= centre && p.y < horizon) {
		currentAction = 3;
	} else if (p.x < centre && p.y < horizon) {
		currentAction = 4;
	}
	return currentAction;
}

- (void)ccTouchesBegan :(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		if(currentAction == 0) {

				
			currentAction = [self input: location];
			
			if(currentAction == 3 && engineSpeed < MAX_SPEED) {
				engineSpeed = engineSpeed + 0.1;	
			}
			if(currentAction == 4 && engineSpeed > MIN_SPEED) {
				engineSpeed = engineSpeed - 0.2;	
			} 
		}
	}
}

- (void)ccTouchesMoved :(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		latestAction = [self input: location];
		if (currentAction != 0 && currentAction != latestAction) {
			currentAction = 0;
			latestAction = 0;

		}
	
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
		[self input: location];
		currentAction = 0;
		latestAction = 0;
		
	}
}

- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	//b2Vec2 gravity( -accelY * 10, accelX * 10);
	//world->SetGravity( gravity );
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
