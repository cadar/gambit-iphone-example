#define COCOS2D_DEBUG 2
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

// HelloWorld Layer
@interface Play: CCLayer
{
	b2World* world;
	GLESDebugDraw *m_debugDraw;
	id soundEngine;
	float32 engineSpeed;
	NSDate * newNextBeat;
	NSDate * nextBeat;
	NSThread * engineThread;
	int centre;
	int horizon;
	int currentAction;
	int latestAction;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

// adds a new sprite at a given coordinate
-(void) addNewSpriteWithCoords:(CGPoint)p;
-(int8) input:(CGPoint)p;
@end
