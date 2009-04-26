#import <UIKit/UIKit.h>
#import "SimpleCocoaClient.h"
#import "ConnectionManager.h"
#import "PhSScrollView.h"

@interface ClientViewController : UIViewController <UIScrollViewDelegate, UITabBarControllerDelegate> {
	IBOutlet PhSScrollView *scrollView;
	
	ConnectionManager *conManager;
	int pictureNumber;
	
	BOOL asynchronousMode;
	
	NSString *currentDirectory;
	NSArray *picturesOfCurrentDirectory;
	NSTimer *getPicturesTimer;
	
	BOOL progressShowing;
	int imageCount;
	int currentPageInScrollView;
	
	NSMutableArray *loadedImagesInScrollView;
	BOOL synchronious;
	int currentPicture;
}

@property (nonatomic, retain) PhSScrollView *scrollView;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) ConnectionManager *conManager;
@property (nonatomic, retain) NSArray *picturesOfCurrentDirectory;
@property int imageCount;
@property int currentPicture;
@property (nonatomic, retain) NSMutableArray *loadedImagesInScrollView;
@property (readonly) int currentPageInScrollView;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil synchron:(BOOL)synchron;
- (void)setPhoto:(NSString *)photo;
- (void)loadScrollViewWithPage:(int)pageNumber;
- (void)loadImage:(NSString *) photoNumber;
- (void) done;
@end

