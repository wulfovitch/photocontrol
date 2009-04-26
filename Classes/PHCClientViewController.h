#import <UIKit/UIKit.h>
#import "SimpleCocoaClient.h"
#import "PHCConnectionManager.h"
#import "PHCScrollView.h"

@interface PHCClientViewController : UIViewController <UIScrollViewDelegate, UITabBarControllerDelegate> {
	IBOutlet PHCScrollView *scrollView;
	
	PHCConnectionManager *conManager;
	int pictureNumber;
	
	NSString *currentDirectory;
	NSString *currentDirectoryName;
	NSTimer *getPicturesTimer;
	
	BOOL progressShowing;
	int imageCount;
	int currentPageInScrollView;
	
	NSMutableArray *loadedImagesInScrollView;
	BOOL synchronious;
	int currentPicture;
	
	UIActivityIndicatorView *activityIndicator;
	
	int nothingReceivedCounter;
}

@property (nonatomic, retain) PHCScrollView *scrollView;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) NSString *currentDirectoryName;
@property (nonatomic, retain) PHCConnectionManager *conManager;
@property int imageCount;
@property int currentPicture;
@property BOOL synchronious;
@property (nonatomic, retain) NSMutableArray *loadedImagesInScrollView;
@property (readonly) int currentPageInScrollView;
@property int nothingReceivedCounter;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil synchron:(BOOL)synchron;
- (void)setPhoto:(NSString *)photo;
- (void)loadScrollViewWithPage:(int)pageNumber;
- (void)loadImage:(NSString *) photoNumber;
- (void) done;
- (void)receivingPicturesTimer:(NSTimer *)timer;
- (void)changeSynchroniousMode;
@end

