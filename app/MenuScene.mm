//
// Demo of calling integrating Box2D physics engine with cocos2d AtlasSprites
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// by Steve Oldmeadow
//

// Import the interfaces
#import "MenuScene.h"
#import "PlayScene.h"
#import "CCMenu.h"
#import "CCMenuItem.h"
#import <AVFoundation/AVFoundation.h>
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
@implementation Menu

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	Menu *layer = [Menu node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// initialize your instance here
-(id) init
{
	if( (self=[super init])) {
		[[SimpleAudioEngine sharedEngine] preloadEffect:@"Engine2.wav"];
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);

		CCLabel *label = [CCLabel labelWithString:@"Truck" fontName:@"Zapfino" fontSize:60];
		label.position = ccp(screenSize.width/2,(screenSize.height-screenSize.height/4));
        [self addChild:label];

		
		CCLabel *label1 = [CCLabel labelWithString:@"Play" fontName:@"Courier New" fontSize:30];
		CCLabel *label2 = [CCLabel labelWithString:@"High Score" fontName:@"Courier New" fontSize:30];
		CCLabel *label3 = [CCLabel labelWithString:@"About" fontName:@"Courier New" fontSize:30];

		CCMenuItem *menuItem1 = [CCMenuItemFont itemWithLabel:label1 target:self selector:@selector(onPlay:)];
		CCMenuItem *menuItem2 = [CCMenuItemFont itemWithLabel:label2 target:self selector:@selector(onPlay:)];
		CCMenuItem *menuItem3 = [CCMenuItemFont itemWithLabel:label3 target:self selector:@selector(onPlay:)];
		CCMenu *menu = [CCMenu menuWithItems:menuItem1,menuItem2,menuItem3, nil];
		menu.position = ccp(screenSize.width/2,(screenSize.height-screenSize.height*3/5));	
        [menu alignItemsVertically];
        [self addChild:menu];
	
	}
	return self;
}


- (void)onPlay:(id)sender
{
	NSLog(@"on play");
	[[CCDirector sharedDirector] pushScene:[CCFadeTransition transitionWithDuration:1.0 scene:[Play node]]];	
}


- (void) dealloc
{
	[super dealloc];
}
@end
