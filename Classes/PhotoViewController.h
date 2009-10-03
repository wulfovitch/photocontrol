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


#import <UIKit/UIKit.h>
#import "SimpleCocoaClient.h"
#import "ConnectionManager.h"
#import "ScrollView.h"

@interface PhotoViewController : UIViewController <UIScrollViewDelegate, UITabBarControllerDelegate> {
	IBOutlet ScrollView *scrollView;
	
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

@property (nonatomic, retain) ScrollView *scrollView;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) NSString *currentDirectoryName;
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

