#import <UIKit/UIKit.h>
#import "PHCDirectoryViewController.h"
#import "PHCAboutViewController.h"

@interface PHCRootViewController : UITableViewController <UIActionSheetDelegate> {
	PHCDirectoryViewController *directoryViewController;
	NSNetServiceBrowser *browser;
	NSMutableArray *services;
	
	PHCConnectionManager *conManager;
}
@property (nonatomic, retain) PHCDirectoryViewController *directoryViewController;
@property (nonatomic, retain) PHCConnectionManager *conManager;

- (void)refresh:(id)sender;
- (void)helpSelector;

@end
