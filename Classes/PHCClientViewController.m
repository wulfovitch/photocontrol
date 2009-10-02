#import "PHCClientViewController.h"

#define INDICATOR_VIEW	1997
#define UISCROLLVIEW_INTRODUCTION 1998
#define PHOTOTAGSSTART 1999

@implementation PHCClientViewController

@synthesize currentDirectory;
@synthesize currentDirectoryName;
@synthesize scrollView;
@synthesize imageCount;
@synthesize loadedImagesInScrollView;
@synthesize currentPageInScrollView;
@synthesize currentPicture;
@synthesize synchronious;
@synthesize nothingReceivedCounter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil synchron:(BOOL)synchron
{
	if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])
	{
		if(synchron)
		{
			synchronious = TRUE;
		} else {
			synchronious = FALSE;
		}
	}
	nothingReceivedCounter = 0;
	return self;
}

 

- (void)viewWillAppear:(BOOL)animated
{
	self.title = currentDirectoryName;
	[super viewWillAppear:animated];
}

- (void)dealloc
{
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	currentPageInScrollView = -1;
	CGRect scrollViewBounds = [scrollView bounds];
	
	//Get the height of the parent view.
	CGFloat scrollViewHeight = CGRectGetHeight(scrollViewBounds);
	CGFloat scrollViewWidth = CGRectGetWidth(scrollViewBounds);
	
	// this is important for catching the doubletap events
	[scrollView setClientViewController:self];
	
	// setup the scroll view for the images
	[scrollView setBackgroundColor:[UIColor blackColor]];
	[scrollView setCanCancelContentTouches:NO];
	scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
	scrollView.clipsToBounds = YES;	// default is NO, we want to restrict drawing within our scrollview
	scrollView.scrollEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
	scrollView.delegate = self;
	scrollView.delaysContentTouches = NO;
	scrollView.pagingEnabled = YES; // scrolling stops at every picture
	[scrollView setContentSize:CGSizeMake(((imageCount+1) * scrollViewWidth), scrollViewHeight)]; // scrollview is as width as the number of images + 1 because the first image of the scrollView is an introduction image
	
	NSLog(@"scrollview width: %f", scrollView.contentSize.width);
	
	// setup the activivity indicator in the navigation bar
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	self.navigationItem.rightBarButtonItem = activityItem;
	[activityItem release];
	 
	 
	// setup a timer if the server is busy
	getPicturesTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
															target: self
														  selector: @selector(receivingPicturesTimer:)
														  userInfo: nil
														   repeats: YES];
	
	UIImageView *iView = (UIImageView *)[scrollView viewWithTag: UISCROLLVIEW_INTRODUCTION];
	if(iView == nil)
	{
		//UIImage *smallImage = [UIImage imageNamed:@"introduction.png"];
		UIImage *smallImage = [UIImage imageNamed:NSLocalizedString(@"introduction.png", @"introduction.png")];
		if (smallImage)
		{
			UIImageView *imageView = [[UIImageView alloc] initWithImage:smallImage];
			
			CGRect frame = scrollView.frame;
			frame.origin.x = 0;
			frame.origin.y = 0;
			imageView.frame = frame;
			imageView.tag = UISCROLLVIEW_INTRODUCTION;
			[scrollView addSubview:imageView];
			[imageView setNeedsDisplay];
			[imageView release];	
		}
		[smallImage release];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

// timer for receiving the images for the case the server was busy
- (void)receivingPicturesTimer:(NSTimer *)timer
{
	if([[PHCConnectionManager getConnectionManager] isReceiving])
	{
		nothingReceivedCounter++;
		NSLog(@"nothing received: %d", nothingReceivedCounter);
		if(nothingReceivedCounter > 50) // value 50 is arbitrarily chosen
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"connection lost", @"The connection to the server seems to be lost. Please restart the application and establish the connection again!") 
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[timer invalidate];
		}
	} else {
		NSLog(@"invalidate");
		[timer invalidate];
		
		nothingReceivedCounter = 0;
		
		// load the first three images of the scroll views
		[self loadScrollViewWithPage:0];
		[self loadScrollViewWithPage:1];
		[self loadScrollViewWithPage:2];
		
		// stopping the activivity indicator
		[activityIndicator stopAnimating];
		[self.navigationItem setRightBarButtonItem:nil];
		[activityIndicator release];
		UIBarButtonItem *changeSynchroniousModeButton = [[UIBarButtonItem alloc] initWithTitle:@"synchron" style:UIBarButtonItemStyleBordered 
																				   target:self action:@selector(changeSynchroniousMode)]; 
		
		self.navigationItem.rightBarButtonItem = changeSynchroniousModeButton;
		[changeSynchroniousModeButton release];
	}
}

- (void)changeSynchroniousMode
{
	[self setSynchronious: !synchronious];
	
	UIBarButtonItem *changeSynchroniousModeButton;
	if (synchronious)
	{
		changeSynchroniousModeButton = [[UIBarButtonItem alloc] initWithTitle:@"synchron" style:UIBarButtonItemStyleBordered 
																					target:self action:@selector(changeSynchroniousMode)];
	} else {
		changeSynchroniousModeButton = [[UIBarButtonItem alloc] initWithTitle:@"asynchron" style:UIBarButtonItemStyleBordered 
																						target:self action:@selector(changeSynchroniousMode)];		
	}
	
	self.navigationItem.rightBarButtonItem = changeSynchroniousModeButton;
	[changeSynchroniousModeButton release];
}


# pragma mark -
# pragma mark scrollView methods

// scrollview method
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
	CGFloat pageWidth = scrollView.frame.size.width;
    int newPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth);
	
	if(currentPageInScrollView != newPage) {
		NSLog(@"scrolling page: %i", newPage);
		currentPageInScrollView = newPage;
		if(newPage < imageCount && newPage > -1)
		{
			if(synchronious)
			{
				[self setPhoto:[NSString stringWithFormat:@"%d", newPage]];
			}
		}

		// remove images which are not visible
		if(currentPageInScrollView-3 > -1)
		{
			UIImageView *iView = (UIImageView *)[scrollView viewWithTag:PHOTOTAGSSTART+currentPageInScrollView-3];
			if(iView != nil)
			{
				[iView removeFromSuperview];
			}
		}
		
		if(currentPageInScrollView+3 < imageCount)
		{
			UIImageView *iView = (UIImageView *)[scrollView viewWithTag:PHOTOTAGSSTART+currentPageInScrollView+3];
			if(iView != nil)
			{
				[iView removeFromSuperview];
			}
		}
		
		// load images which are visible und the images which are near the current image
		[self loadScrollViewWithPage:currentPageInScrollView - 2];
		[self loadScrollViewWithPage:currentPageInScrollView + 2];
	}
}

- (void)loadScrollViewWithPage:(int)pageNumber
{
    if (pageNumber < 0) return;
    if (pageNumber >= imageCount) return;
	
	UIImageView *iView = (UIImageView *)[scrollView viewWithTag:PHOTOTAGSSTART+pageNumber];
	if(iView == nil)
	{
		[NSThread detachNewThreadSelector:@selector(loadImage:) toTarget:self withObject:[NSString stringWithFormat:@"%i", pageNumber]];
	}
}

- (void)loadImage:(NSString *) photoNumber
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	int photoNr = [photoNumber intValue];
	
	if(photoNr < imageCount && photoNr > -1)
	{
		UIImageView *iView = (UIImageView *)[scrollView viewWithTag:PHOTOTAGSSTART+photoNr];
		if(iView == nil)
		{
			//NSURL *url = [[NSURL alloc] initWithScheme:@"http" 
			//									  host:[NSString stringWithFormat:@"%@:%@", [[PHCConnectionManager getConnectionManager] serverIP], @"55598"]
			//									  path:[NSString stringWithFormat:@"%@%@", currentDirectory, [[[PHCConnectionManager getConnectionManager] currentPictures] objectAtIndex:photoNr]]];
			NSURL *url = [[NSURL alloc] initWithScheme:@"http" 
												  host:[NSString stringWithFormat:@"%@:%@", [[PHCConnectionManager getConnectionManager] serverIP], @"55598"]
												  path:[NSString stringWithFormat:@"%@%@", currentDirectory, photoNumber]];
			
			NSData *data = [[NSData alloc] initWithContentsOfURL:url];
			UIImage *smallImage = [[UIImage alloc] initWithData:data];
			if (smallImage)
			{
				UIImageView *imageView = [[UIImageView alloc] initWithImage:smallImage];
				
				CGRect frame = scrollView.frame;
				frame.origin.x = frame.size.width * (photoNr + 1); // +1 because the first image in the scrollView is the introduction image
				frame.origin.y = 0;
				imageView.frame = frame;
				imageView.tag = PHOTOTAGSSTART + photoNr;
				[scrollView addSubview:imageView];
				[imageView setNeedsDisplay];
				[imageView release];	
			}
			[smallImage release];
			[data release];
			[url release];
		}
	}


	[pool release];
	[NSThread exit];
}

// called when the images are loaded
-(void)done
{
	activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:INDICATOR_VIEW];	
	[activityIndicator stopAnimating];
}


-(void)setPhoto:(NSString *)photo
{
	[[[PHCConnectionManager getConnectionManager] client] sendString:[NSString stringWithFormat:@"%@%@\n", currentDirectory, photo]];
}

@end
