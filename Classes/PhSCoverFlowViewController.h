#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "ConnectionManager.h"

/* Number of pixels scrolled before next cover comes front */
#define SCROLL_PIXELS 70.0

/* Size of each cover */
#define COVER_WIDTH_HEIGHT 118.0

@interface CFView : UIScrollView <UIScrollViewDelegate>
{
	CAScrollLayer *cfIntLayer;
	NSMutableArray *_covers;
	NSTimer *timer;
	int selectedCover;
}
- (id) initWithFrame:(struct CGRect)frame covers:(NSMutableArray *)covers;
- (void)layoutLayer:(CAScrollLayer *)layer;

@property(nonatomic,getter=getSelectedCover) int selectedCover;

@end

@interface PhSCoverFlowViewController : UIViewController {
	NSMutableArray *covers;
    CFView *covertFlowView;
	
	ConnectionManager *conManager;
	NSString *currentDirectory;
}

- (id)initWithConManager:(ConnectionManager *)connectionManager andDirectory:(NSString *)dir;

@property (nonatomic, retain) ConnectionManager *conManager;
@property (nonatomic, retain) NSString *currentDirectory;

@end

