#import <UIKit/UIKit.h>
#import "ConnectionManager.h"
#import "SimpleCocoaClient.h"
#import "TabBarViewController.h"

@interface DirectoryViewController : UITableViewController {
	
	NSArray *subDirectories;
	NSArray *pictures;
	NSString *currentDirectory;
	int imageCount;
	
	ConnectionManager *conManager;
	NSTimer *reloadDirectoriesTimer;
	
	DirectoryViewController *dirViewController;
	TabBarViewController *tabBarViewController;
	
	BOOL noSubDirectories;
}

@property (nonatomic, retain) NSArray *subDirectories;
@property (nonatomic, retain) NSArray *pictures;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) ConnectionManager *conManager;
@property (nonatomic, retain) DirectoryViewController *dirViewController;
@property (nonatomic, retain) TabBarViewController *tabBarViewController;

- (void) handleTimer: (NSTimer *) timer;
- (void)refresh;

@end
