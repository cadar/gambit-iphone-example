//
// Demo of calling integrating Box2D physics engine with cocos2d AtlasSprites
// a cocos2d example
// http://code.google.com/p/cocos2d-iphone
//
// by Steve Oldmeadow
//

// Import the interfaces
#import "GameOverScene.h"
#import "MenuScene.h"
#import "CCMenu.h"
#import "CCMenuItem.h"
#import <AVFoundation/AVFoundation.h>
#import "SimpleAudioEngine.h"






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
@implementation GameOver

@synthesize bgVol;
@synthesize effVol;

+(id) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	GameOver *layer = [GameOver node];
	
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

		CCLabel *label = [CCLabel labelWithString:@"GameOver" fontName:@"Zapfino" fontSize:60];
		label.position = ccp(screenSize.width/2,(screenSize.height/2));
        [self addChild:label];
		
		soundId = [[SimpleAudioEngine sharedEngine] playEffect:@"Success.wav" pitch:1.0 pan:1.0 gain:0.7];
		
		bgVol = 0.5f;
		effVol = 1.0f;
	
		[self schedule: @selector(startFade:) interval:3.0];
	}
	return self;
}

- (void)startFade:(id)sender
{
		[self schedule: @selector(fade:)	interval:2.0f/40];
}

- (void)fade:(id)sender
{
//	NSLog(@"on fade %f %f",bgVol, effVol);
	bgVol = bgVol - 0.03/2;
	effVol = effVol - 0.03;
	if (bgVol >= 0.0) {
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:bgVol];
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:effVol];	
	} else {
		[self schedule: @selector(toMenu:) interval:1.0];
		[self unschedule: @selector(fade:)];	
		[[SimpleAudioEngine sharedEngine] setBackgroundMusicVolume:0.0];
		[[SimpleAudioEngine sharedEngine] setEffectsVolume:0.0];	
		[[SimpleAudioEngine sharedEngine] stopBackgroundMusic];		
		[[SimpleAudioEngine sharedEngine] stopEffect:soundId];
	}
}


- (void)toMenu:(id)sender
{
//	NSLog(@"on menu");
	[[CCDirector sharedDirector] popScene];

}


- (void) dealloc
{
	[super dealloc];
}
@end
