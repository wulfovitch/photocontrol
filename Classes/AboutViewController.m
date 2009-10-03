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


#import "AboutViewController.h"

@implementation AboutViewController

@synthesize urlToOpen;

- (void)loadView
{
	CGRect applicationFrame = [[UIScreen mainScreen] applicationFrame];
	
	UIWebView *webView = [[[UIWebView alloc] initWithFrame:applicationFrame] autorelease];
	[webView setDelegate:self];
	
	self.view = webView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	NSString *path = [NSString pathWithComponents:[NSArray arrayWithObjects:[[NSBundle mainBundle] resourcePath], NSLocalizedString(@"aboutHTMLFile", @"about_en.html"), nil]];
	NSURL *baseURL = [[[NSURL alloc] initFileURLWithPath:path] autorelease];
	NSError *error;
	[(UIWebView *)self.view loadHTMLString:[NSString stringWithContentsOfURL:baseURL encoding:NSUTF8StringEncoding error:&error] baseURL:baseURL];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)dealloc
{
	[super dealloc];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
	NSURL *url = [request URL];
	
	if (![[url scheme] isEqualToString:@"file"])
	{
		self.urlToOpen = url;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Safari will now open:", @"Safari will now open:") 
														message:[url relativeString]
													   delegate:self 
											  cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel")
											  otherButtonTitles:NSLocalizedString(@"OK", @"OK"), nil];
		[alert show];
		[alert release];
		
		return NO;
	}
	
	return YES;
}

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	// the user clicked one of the OK/Cancel buttons
	if (buttonIndex == 1) // OK button clicked
	{
		[[UIApplication sharedApplication] openURL:urlToOpen];
	}
	else
	{
		// Do nothing
	}
}


@end
