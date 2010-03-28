
// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"

@interface GameOver : CCLayer
{
	float bgVol;
	float effVol;
	int soundId;
}

// returns a Scene that contains the HelloWorld as the only child
+(id) scene;

@property (nonatomic) float  bgVol;
@property (nonatomic) float  effVol;
@property (nonatomic) int soundId;

@end
