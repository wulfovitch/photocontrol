#import "PhSScrollView.h"
#import "ClientViewController.h"


@implementation PhSScrollView

@synthesize clientViewController;

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(clientViewController != nil)
	{
		UITouch *touch = [touches anyObject];
		NSUInteger tapCount = [touch tapCount];
		
		switch (tapCount)
		{
			case 1:
				//NSLog(@"tapcount 1");
				//	[self performSelector:@selector(singleTapMethod) withObject:nil afterDelay:.4];
				break;
			case 2:
				//NSLog(@"tapcount 2");
				//[self performSelector:@selector(doubleTapMethod) withObject:nil afterDelay:.2];
				[clientViewController setPhoto:[NSString stringWithFormat:@"%@", [[[clientViewController conManager] currentPictures] objectAtIndex:[clientViewController currentPageInScrollView]]]];
				break;
			default:
				break;
		}
	}
	[super touchesBegan:touches withEvent:event];
}





@end
