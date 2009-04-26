#import "TabBarViewController.h"

#define COVERFLOWVIEW 1111

@implementation TabBarViewController

@synthesize tabBarController;

@synthesize conManager;
@synthesize currentDirectory;
@synthesize imageCount;
@synthesize activityIndicator;
@synthesize picturesOfCurrentDirectory;
@synthesize cvc;

-(void)loadView
{
	coverFlowLoaded = NO;
	
	// setup the activivity indicator in the navigation bar
	activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
	[activityIndicator startAnimating];
	UIBarButtonItem *activityItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
	self.navigationItem.rightBarButtonItem = activityItem;
	[activityItem release];
	
	if([conManager isReceiving])
	{
		getPicturesTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
															target: self
														  selector: @selector(handleTimer:)
														  userInfo: nil
														   repeats: YES];
	} else {
		// save the picture names of the current directory
		NSArray *currentPics = [[NSArray alloc] initWithArray:[self.conManager currentPictures]];
		[self setPicturesOfCurrentDirectory: currentPics];
		[currentPics release];
	}
	
	[conManager setRefreshing];
	[[conManager client] sendString:@"### START PICTURELIST ###\n"];
	[[conManager client] sendString:[NSString stringWithFormat:@"%@\n", self.currentDirectory]];
	[[conManager client] sendString:@"### END PICTURELIST ###\n"];
	
	
	self.title = @"Photo Control";
	
	tabBarController = [[UITabBarController alloc] init];
	NSMutableArray *localViewControllersArray = [[NSMutableArray alloc] initWithCapacity:3];
	
	ClientViewController *view = [[ClientViewController alloc] initWithNibName:@"ClientViewController" bundle:[NSBundle mainBundle] synchron:YES];
	view.title = @"Synchron";
	view.tabBarItem.image = [UIImage imageNamed:@"icon_synchron.png"];
	view.conManager = self.conManager;
	view.currentDirectory = self.currentDirectory;
	view.imageCount  = imageCount;

	[localViewControllersArray addObject:view];
	[view release];	
	
	view = [[ClientViewController alloc] initWithNibName:@"ClientViewController" bundle:[NSBundle mainBundle] synchron:NO];
	view.title = @"Asynchron";
	view.tabBarItem.image = [UIImage imageNamed:@"icon_asynchron.png"];
	view.conManager = self.conManager;
	view.currentDirectory = self.currentDirectory;
	view.imageCount  = imageCount;
	
	[localViewControllersArray addObject:view];
	[view release];	
	
	UIViewController *dummyTab = [[UIViewController alloc] init];
	dummyTab.title = @"Cover Flow";
	dummyTab.tabBarItem.image = [UIImage imageNamed:@"coverflow_icon.png"];
	UIView *myView = [[UIView alloc] initWithFrame:CGRectMake(0, 64, 320, 372)];
	[dummyTab setView:myView];
	[myView release];
	[localViewControllersArray addObject:dummyTab];
	[dummyTab release];
	
	
	tabBarController.viewControllers = localViewControllersArray;
	[localViewControllersArray release];
	tabBarController.delegate = self;
	self.view = tabBarController.view;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
	if( [viewController.title isEqualToString:@"Asynchron"])
	{
		[[self.tabBarController.viewControllers objectAtIndex:1] loadScrollViewWithPage:0];
		[[self.tabBarController.viewControllers objectAtIndex:1] loadScrollViewWithPage:1];
		[[self.tabBarController.viewControllers objectAtIndex:1] loadScrollViewWithPage:2];
	}
	if( [viewController.title isEqualToString:@"Cover Flow"])
	{
		if(!coverFlowLoaded)
		{
			coverFlowLoaded = YES;
			UIView *myView = [viewController view];
			cvc = [[CoverViewController alloc] initWithRect:CGRectMake(0, 0, 320, 372) andConManager: self.conManager andDirectory: self.currentDirectory];
			cvc.tabBarItem.image = [UIImage imageNamed:@"computer.png"];
			
			[myView addSubview:cvc.view];	
			[cvc release];	
		}
	}
}

- (void)handleTimer:(NSTimer *)timer
{
	if([conManager isReceiving])
	{
		NSLog(@"nothing received");
	} else {
		NSLog(@"invalidate");
		[timer invalidate];
		
		// load the first three images of the scroll views
		int i;
		for (i=0; i < [tabBarController.viewControllers count]; i++)
		{
			if([[tabBarController.viewControllers objectAtIndex:i] isKindOfClass:[ClientViewController class]])
			{
				[[tabBarController.viewControllers objectAtIndex:i] loadScrollViewWithPage:0];
				[[tabBarController.viewControllers objectAtIndex:i] loadScrollViewWithPage:1];
				[[tabBarController.viewControllers objectAtIndex:i] loadScrollViewWithPage:2];
			}
		}
		
		// stopping the activivity indicator
		[activityIndicator stopAnimating];
		[self.navigationItem setRightBarButtonItem:nil];
		[activityIndicator release];
	}
}


- (void)viewDidLoad 
{
    [super viewDidLoad];
}



- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[self setPicturesOfCurrentDirectory:nil];
	[self setConManager:nil];
	[self setCurrentDirectory:nil];
	for(UIViewController *view in tabBarController.viewControllers)
	{
		[view release];
	}
	[tabBarController release];
	[conManager release];
    [super dealloc];
}


@end
