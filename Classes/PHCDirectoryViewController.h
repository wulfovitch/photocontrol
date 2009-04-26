#import <UIKit/UIKit.h>
#import "PHCConnectionManager.h"
#import "SimpleCocoaClient.h"
#import "PHCClientViewController.h"

@interface PHCDirectoryViewController : UITableViewController {
	
	NSArray *subDirectories;
	NSArray *pictures;
	NSString *currentDirectory;
	NSString *currentDirectoryName;
	NSArray *picturesOfCurrentDirectory;
	int imageCount;
	
	PHCConnectionManager *conManager;
	NSTimer *reloadDirectoriesTimer;
	
	PHCDirectoryViewController *dirViewController;
	PHCClientViewController *cvc;
	
	BOOL noSubDirectories;
	NSTimer *getPicturesTimer;
	
	int nothingReceivedCounter;
}

@property (nonatomic, retain) NSArray *subDirectories;
@property (nonatomic, retain) NSArray *pictures;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) NSString *currentDirectoryName;
@property (nonatomic, retain) NSArray *picturesOfCurrentDirectory;
@property (nonatomic, retain) PHCConnectionManager *conManager;
@property (nonatomic, retain) PHCDirectoryViewController *dirViewController;
@property (nonatomic, retain) PHCClientViewController *cvc;
@property int nothingReceivedCounter;

- (void) handleTimer: (NSTimer *) timer;
- (void)refresh;

@end
