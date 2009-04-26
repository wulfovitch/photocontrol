#import "ClientViewController.h"

#define INDICATOR_VIEW	99
#define PHOTOTAGSSTART 100

@implementation ClientViewController

@synthesize conManager;
@synthesize currentDirectory;
@synthesize picturesOfCurrentDirectory;
@synthesize scrollView;
@synthesize imageCount;
@synthesize loadedImagesInScrollView;
@synthesize currentPageInScrollView;

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
	return self;
}

 

- (void)viewWillAppear:(BOOL)animated
{
	self.title=@"Synchron";
	[super viewWillAppear:animated];
}


- (void)viewDidLoad
{
    [super viewDidLoad];

	currentPageInScrollView = 0;
	
	//UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 32.0f, 32.0f)];
	CGRect scrollViewBounds = [scrollView bounds];
	
	//Get the height of the parent view.
	CGFloat scrollViewHeight = CGRectGetHeight(scrollViewBounds);
	CGFloat scrollViewWidth = CGRectGetWidth(scrollViewBounds);
	
	// setup the activity indicator
	//[activityIndicator setCenter:CGPointMake((imageViewWidth / 2), (imageViewHeight / 2))];
    //[activityIndicator setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleWhiteLarge];
	//activityIndicator.tag = INDICATOR_VIEW;
    //[scrollView addSubview:activityIndicator];
	//[activityIndicator startAnimating];
	//[activityIndicator release];
	
	
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
	[scrollView setContentSize:CGSizeMake((imageCount * scrollViewWidth), scrollViewHeight)]; // scrollview is as width as the number of images
	
	if(!synchronious)
	{
		[scrollView setClientViewController:self];
	}
}

- (void)dealloc
{
	[scrollView release];
    [super dealloc];
}


// scrollview method
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
	CGFloat pageWidth = scrollView.frame.size.width;
    int newPage = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
	
	if(currentPageInScrollView != newPage) {
		//NSLog(@"scrolling page: %i", newPage);
		if(newPage < imageCount && newPage > -1)
		{
			if(synchronious)
			{
				[self setPhoto:[NSString stringWithFormat:@"%@", [[self.conManager currentPictures] objectAtIndex:newPage]]];
			}
			currentPageInScrollView = newPage;
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
		//[self loadScrollViewWithPage:currentPageInScrollView - 1];
		//[self loadScrollViewWithPage:currentPageInScrollView];
		//[self loadScrollViewWithPage:currentPageInScrollView + 1];
		[self loadScrollViewWithPage:currentPageInScrollView + 2];
		
		/* DEBUG
		int i=0;
		NSArray *bla = [scrollView subviews];
		for (UIImageView *blaa in bla) {
			i++;
		}
		NSLog(@"scrollview subview count: %i", i);
		*/
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
			NSString *path = [NSString stringWithFormat:@"http://%@:55598%@%@", [conManager serverIP], currentDirectory, [[self.conManager currentPictures] objectAtIndex:photoNr]];
			NSURL *url = [NSURL URLWithString:path];
			NSData *data = [[NSData alloc] initWithContentsOfURL:url];
			UIImage *smallImage = [[UIImage alloc] initWithData:data];
			if (smallImage)
			{
				UIImageView *imageView = [[UIImageView alloc] initWithImage:smallImage];
				
				CGRect frame = scrollView.frame;
				frame.origin.x = frame.size.width * photoNr;
				frame.origin.y = 0;
				imageView.frame = frame;
				imageView.tag = PHOTOTAGSSTART + photoNr;
				[scrollView addSubview:imageView];
				[imageView setNeedsDisplay];
				[imageView release];	
			}
			[smallImage release];
			[data release];
		}
	}
		//[self performSelectorOnMainThread:@selector(done) withObject:nil waitUntilDone:NO];

	[pool release];
	[NSThread exit];
}

// called when the images are loaded
-(void)done
{
	UIActivityIndicatorView *activityIndicator = (UIActivityIndicatorView *)[self.view viewWithTag:INDICATOR_VIEW];	
	[activityIndicator stopAnimating];
}


-(void)setPhoto:(NSString *)photo
{
	if(!asynchronousMode)
	{
		[[conManager client] sendString:[NSString stringWithFormat:@"%@%@\n", currentDirectory, photo]];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
