#import <UIKit/UIKit.h>
#import "DirectoryViewController.h"

@interface RootViewController : UITableViewController {
	DirectoryViewController *directoryViewController;
	NSNetServiceBrowser *browser;
	NSMutableArray *services;
	
	ConnectionManager *conManager;
}
@property (nonatomic, retain) DirectoryViewController *directoryViewController;
@property (nonatomic, retain) ConnectionManager *conManager;

- (void)refresh:(id)sender;

@end
