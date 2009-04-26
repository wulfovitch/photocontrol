#import <UIKit/UIKit.h>
@class ClientViewController;

@interface PhSScrollView : UIScrollView {

	ClientViewController *clientViewController;
	
}

@property (nonatomic, retain) ClientViewController *clientViewController;

@end
