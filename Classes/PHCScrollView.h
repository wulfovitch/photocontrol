#import <UIKit/UIKit.h>
@class PHCClientViewController;

/*
 * extends the functionality of UIScrollView to detect doubletaps
 */

@interface PHCScrollView : UIScrollView {
	PHCClientViewController *clientViewController;
}

@property (nonatomic, retain) PHCClientViewController *clientViewController;

@end
