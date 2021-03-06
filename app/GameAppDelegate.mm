//
//  tosserAppDelegate.m
//  tosser
//
//  Created by James on 6/2/09.
//  Copyright Coptix, Inc 2009. All rights reserved.
//

#import "GameAppDelegate.h"
#import "EAGLView2.h"
#import "cocos2d.h"
#import "MenuScene.h"
#import "PlayScene.h"


@implementation GameAppDelegate

@synthesize window;
@synthesize glView;

- (void)applicationDidFinishLaunching:(UIApplication *)application {
	// Init the window
	if(true){
		window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
		
		// cocos2d will inherit these values
		[window setUserInteractionEnabled:YES];	
		[window setMultipleTouchEnabled:YES];
		
		// Try to use CADisplayLink director
		// if it fails (SDK < 3.1) use the default director
		if( ! [CCDirector setDirectorType:CCDirectorTypeDisplayLink] )
			[CCDirector setDirectorType:CCDirectorTypeDefault];
		
		// Use RGBA_8888 buffers
		// Default is: RGB_565 buffers
		[[CCDirector sharedDirector] setPixelFormat:kPixelFormatRGBA8888];
		
		// Create a depth buffer of 16 bits
		// Enable it if you are going to use 3D transitions or 3d objects
		//	[[CCDirector sharedDirector] setDepthBufferFormat:kDepthBuffer16];
		
		// Default texture format for PNG/BMP/TIFF/JPEG/GIF images
		// It can be RGBA8888, RGBA4444, RGB5_A1, RGB565
		// You can change anytime.
		[CCTexture2D setDefaultAlphaPixelFormat:kTexture2DPixelFormat_RGBA8888];
		
		// before creating any layer, set the landscape mode
		[[CCDirector sharedDirector] setDeviceOrientation:CCDeviceOrientationLandscapeLeft];
		[[CCDirector sharedDirector] setAnimationInterval:1.0/60];
		[[CCDirector sharedDirector] setDisplayFPS:YES];
		
		// create an openGL view inside a window
		[[CCDirector sharedDirector] attachInView:window];	
		
		[[CCDirector sharedDirector] runWithScene: [Menu scene]];	
		[window makeKeyAndVisible];		
	}else{
		glView.animationInterval = 1.0 / 60.0;
		[glView startAnimation];
	}
}


- (void)applicationWillResignActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 5.0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
	glView.animationInterval = 1.0 / 60.0;
}

- (void)dealloc {
	[[CCDirector sharedDirector] release];
	[window release];
	[glView release];
	[super dealloc];
}

@end
