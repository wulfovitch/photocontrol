//	photocontrol client
//	see http://photocontrol.net for more information
//
//	Copyright (C) 2009  Wolfgang König
//
//	This program is free software: you can redistribute it and/or modify
//	it under the terms of the GNU General Public License as published by
//	the Free Software Foundation, either version 3 of the License, or
//	(at your option) any later version.
//
//	This program is distributed in the hope that it will be useful,
//	but WITHOUT ANY WARRANTY; without even the implied warranty of
//	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//	GNU General Public License for more details.
//
//	You should have received a copy of the GNU General Public License
//	along with this program.  If not, see <http://www.gnu.org/licenses/>.


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
					[clientViewController setPhoto:[NSString stringWithFormat:@"%d", [clientViewController currentPageInScrollView]]];
				}
				break;
			default:
				break;
		}
	}
	[super touchesBegan:touches withEvent:event];
}





@end
