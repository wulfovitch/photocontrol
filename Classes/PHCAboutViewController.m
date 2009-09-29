#import "PHCAboutViewController.h"


@implementation PHCAboutViewController

@synthesize applicationCanBeDownloadedAt;
@synthesize applicationWasCreatedBy;
@synthesize supportedBy;
@synthesize cameraIconBy; 

@synthesize urlToOpen;

- (void)viewDidLoad {
    [super viewDidLoad];
	
	[applicationCanBeDownloadedAt setText:NSLocalizedString(@"The server application can be downloaded at:", @"The server application can be downloaded at:")];
	[applicationWasCreatedBy setText:NSLocalizedString(@"Application was created by:", @"Application was created by:")];
	[supportedBy setText:NSLocalizedString(@"supported by:", @"supported by:")];
	[cameraIconBy setText:NSLocalizedString(@"Camera icon by:", @"Camera icon by:")];
}

- (void)viewWillAppear:(BOOL)animated
{
	self.title = NSLocalizedString(@"About", @"About");
	[super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [super dealloc];
}

-(IBAction)openURLofPhotoControlInSafari:(id)sender {
	urlToOpen = NSLocalizedString(@"photocontrolWebsite", @"http://www.photocontrol.net");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Safari will now open:", @"Safari will now open:") 
													message:urlToOpen 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
										  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
	[alert show];
	[alert release];
}


-(IBAction)openURLofOffisInSafari:(id)sender {
	urlToOpen = NSLocalizedString(@"offisWebsite", @"http://www.offis.de/index_e.php");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Safari will now open:", @"Safari will now open:") 
													message:urlToOpen 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
										  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
	[alert show];
	[alert release];
}

-(IBAction)openURLofUniOLInSafari:(id)sender {
	urlToOpen = NSLocalizedString(@"uniOLWebsite", @"http://www.uni-oldenburg.de/en/");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Safari will now open:", @"Safari will now open:") 
													message:urlToOpen 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
										  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
	[alert show];
	[alert release];
}

-(IBAction)openURLofRefuelDesignInSafari:(id)sender {
	urlToOpen = NSLocalizedString(@"refueldesign.com", @"http://refueldesign.com");
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Safari will now open:", @"Safari will now open:") 
													message:urlToOpen 
												   delegate:self 
										  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
										  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
	[alert show];
	[alert release];
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1) // OK button clicked
	{
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString: urlToOpen]];
	}
	else
	{
		// Do nothing
	}
}


@end
