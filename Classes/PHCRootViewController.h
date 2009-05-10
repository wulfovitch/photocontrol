#import <UIKit/UIKit.h>
#import "PHCDirectoryViewController.h"
#import "PHCAboutViewController.h"

@interface PHCRootViewController : UITableViewController <UIActionSheetDelegate> {
	PHCDirectoryViewController *directoryViewController;
	NSNetServiceBrowser *browser;
	NSMutableArray *services;
}
@property (nonatomic, retain) PHCDirectoryViewController *directoryViewController;

- (void)refresh:(id)sender;
- (void)helpSelector;

@end
