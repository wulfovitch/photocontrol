#import <UIKit/UIKit.h>
#import "ClientViewController.h"
#import "ConnectionManager.h"
#import "CoverViewController.h"


@interface TabBarViewController : UIViewController <UITabBarControllerDelegate> {
	UITabBarController *tabBarController;
	
	ConnectionManager *conManager;
	NSString *currentDirectory;
	int imageCount;
	UIActivityIndicatorView *activityIndicator;
	
	NSArray *picturesOfCurrentDirectory;
	NSTimer *getPicturesTimer;
	
	// Controllers
	CoverViewController *cvc;
	BOOL coverFlowLoaded;
}

@property (nonatomic, retain) UITabBarController *tabBarController;

@property (nonatomic, retain) ConnectionManager *conManager;
@property (nonatomic, retain) NSString *currentDirectory;
@property int imageCount;
@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) NSArray *picturesOfCurrentDirectory;
@property (nonatomic, retain) CoverViewController *cvc;

-(void)handleTimer:(NSTimer *)timer;

@end
