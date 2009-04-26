#import "ClientAppDelegate.h"
#import "PHCRootViewController.h"
#import "PHCConnectionManager.h"


@implementation ClientAppDelegate

@synthesize window;
@synthesize navigationController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	// Configure and show the window
	[window addSubview:[navigationController view]];
	[window makeKeyAndVisible];
	
	// avoid sleeping when this application is running
	application.idleTimerDisabled = YES;
}


- (void)applicationWillTerminate:(UIApplication *)application {
	// Save data if appropriate
}


- (void)dealloc {
	[navigationController release];
	[window release];
	[super dealloc];
}

@end
