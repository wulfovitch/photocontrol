#import "PHCScrollView.h"
#import "PHCClientViewController.h"


@implementation PHCScrollView

@synthesize clientViewController;

// detect doubletap
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	if(clientViewController != nil && [clientViewController synchronious] == false)
	{
		UITouch *touch = [touches anyObject];
		NSUInteger tapCount = [touch tapCount];
		
		switch (tapCount)
		{
			case 1:
				break;
			case 2:
				if ([clientViewController currentPageInScrollView] > -1)
				{
					[clientViewController setPhoto:[NSString stringWithFormat:@"%@", [[[clientViewController conManager] currentPictures] objectAtIndex:[clientViewController currentPageInScrollView]]]];
				}
				break;
			default:
				break;
		}
	}
	[super touchesBegan:touches withEvent:event];
}





@end
