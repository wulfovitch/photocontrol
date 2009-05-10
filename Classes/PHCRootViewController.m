#import "PHCRootViewController.h"
#import <arpa/inet.h>
#import <netinet/in.h>

@implementation PHCRootViewController

@synthesize directoryViewController;

// enum for sections in table view
enum {
	sectionServer = 0,
	sectionHelp
};

// enum for rows in table view
enum {
	rowAbout = 0
};

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = NSLocalizedString(@"ServerTitleKey", @"title of the servers page");
	
	browser = [[NSNetServiceBrowser alloc] init];
    [browser setDelegate:self];
	services = [[NSMutableArray array] retain];
	[PHCConnectionManager getConnectionManager];
    
    [browser searchForServicesOfType:@"_photocontrol._tcp." inDomain:@""];
	
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", @"Help") style:UIBarButtonItemStylePlain target:self action:@selector(helpSelector)];
	
	self.navigationItem.rightBarButtonItem = helpButton;
	[helpButton release];
}

- (void)helpSelector {
	//UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"Start Alert", @"Download the Server Application for the Mac at: www.photocontrol.net - The Mac and the iPhone / iPod Touch have to be in the same Network, therefore wireless lan has to be actived for using this app.") 
	//											   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	UIActionSheet *alert = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Start Alert", @"Download the Server Application for the Mac at: www.photocontrol.net - The Mac running the server application and your iPhone or iPod Touch have to be in the same Network. Therefore wireless lan has to be actived for using this application on this device.") 
													   delegate:self 
											  cancelButtonTitle:@"OK" 
										 destructiveButtonTitle:nil 
											  otherButtonTitles:nil];
	[alert showInView:[self view]];
	[alert release];	
}

- (void)dealloc {
	[browser release];
	[services release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; 
}

# pragma mark -
# pragma mark methods for the tableView

- (void)refresh:(id)sender {
	[[self tableView] reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == sectionServer) {
		if([services count] > 0)
		{
			return [services count]; // Serverlist Section
		} else {
			return 1; // Information is displayed that no server is available
		}
	} 	
	return 1; // About Section

}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	
	// table column for selection of current directory
	if(indexPath.section == sectionServer)
	{	
		if([services count] > 0)
		{
			NSNetService *netService = [services objectAtIndex: [indexPath row]];
			if([netService respondsToSelector:@selector(name)])
				[cell setText: [netService name]];
			else
				[cell setText: NSLocalizedString(@"DefaultPhotoServer", @"default name of an photo control server")];
			[cell setImage:[UIImage imageNamed:@"iMac.png"]];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		} else {
			[cell setText: NSLocalizedString(@"NoServerFound", @"No server found")];
			[cell setImage:nil];
		}
	}
	
	// table column for selection of current directory
	if(indexPath.section == sectionHelp)
	{
		if(indexPath.row == rowAbout)
		{
			[cell setText:NSLocalizedString(@"AboutThisApplication", @"about this Application")];
			[cell setImage:[UIImage imageNamed:@"about.png"]];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		}
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == sectionServer) {
		return NSLocalizedString(@"AvailableServers", @"Available Servers");
	} else {
		return NSLocalizedString(@"About", @"About");
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == sectionServer)
	{
		if([services count] > 0)
		{		
			PHCDirectoryViewController *view = [[PHCDirectoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
			
			self.directoryViewController = view;
			[view release];
			
			// hide the back button if the user connect to a server
			[[self.directoryViewController navigationItem] setHidesBackButton:YES];
			
			// connect to server
			[self netServiceDidResolveAddress: [services objectAtIndex: [indexPath row]]];
			[directoryViewController setCurrentDirectory: @"/"];
			[directoryViewController setCurrentDirectoryName: @"/"];
			[directoryViewController refresh];
			
			[self.navigationController pushViewController:self.directoryViewController animated:YES];
		} else {
			// if there are no servers running, we do not want it to be marked as selected
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	}
	if(indexPath.section == sectionHelp)
	{
		if(indexPath.row == rowAbout)
		{
			PHCAboutViewController *view = [[PHCAboutViewController alloc] initWithNibName:@"PHCAboutViewController" bundle:[NSBundle mainBundle]];
			[self.navigationController pushViewController:view animated:YES];
			[view release];
		}
	}
}





# pragma mark -
# pragma mark Bonjour discovery delage methods

// This object is the delegate of its NSNetServiceBrowser object. We're only interested in services-related methods, so that's what we'll call.
- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	[aNetService resolveWithTimeout:5.0];
	[services addObject:aNetService];
	
    if(!moreComing)
	{
       	[[self tableView] reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didRemoveService:(NSNetService *)aNetService moreComing:(BOOL)moreComing
{
	NSLog(@"netservice count: %i", [services count]);
    [services removeAllObjects];
	NSLog(@"netservice count: %i", [services count]);
	
	//[[[PHCConnectionManager getConnectionManager] client] disconnect];
	[PHCConnectionManager terminateConnectionManager];
	
	[self.navigationController popToRootViewControllerAnimated:YES];
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
													message:NSLocalizedString(@"connection lost", @"The connection to the server seems to be lost. Please restart the application and establish the connection again!") 
												   delegate:self
										  cancelButtonTitle:@"OK"
										  otherButtonTitles:nil];
	[alert show];
	[alert release];
	
    if(!moreComing)
	{
		[[self tableView] reloadData];        
    }
}
	
	
// This Methods resolves the IP Adress and the port of an given NSNetService
- (void)netServiceDidResolveAddress:(NSNetService *)sender {
	
	if ([[sender addresses] count] > 0) {
		NSData * address;
		struct sockaddr * socketAddress;
		NSString * ipAddressString = nil;
		NSString * portString = nil;
		//int socketToRemoteServer;
		char buffer[256];
		int index;
		
		// Iterate through addresses until we find an IPv4 address
		for (index = 0; index < [[sender addresses] count]; index++) {
			address = [[sender addresses] objectAtIndex:index];
			socketAddress = (struct sockaddr *)[address bytes];
			
			if (socketAddress->sa_family == AF_INET) break;
		}
		
		// Be sure to include <netinet/in.h> and <arpa/inet.h> or else you'll get compile errors.
		if (socketAddress) {
			switch(socketAddress->sa_family) {
				case AF_INET:
					if (inet_ntop(AF_INET, &((struct sockaddr_in *)socketAddress)->sin_addr, buffer, sizeof(buffer))) {
						ipAddressString = [NSString stringWithCString:buffer];
						portString = [NSString stringWithFormat:@"%d", ntohs(((struct sockaddr_in *)socketAddress)->sin_port)];
					}
					
					// Cancel the resolve now that we have an IPv4 address.
					[sender stop];
					//serviceBeingResolved = nil;
					
					break;
				case AF_INET6:
					// IPv6 isn't supported yet
					return;
			}
		}   
		
		if (ipAddressString && portString)
		{
			[[PHCConnectionManager getConnectionManager] setServerIP: ipAddressString];
			[[PHCConnectionManager getConnectionManager] setServerPort: portString];
			SimpleCocoaClient *client = [[SimpleCocoaClient alloc] initWithHost:[[PHCConnectionManager getConnectionManager] serverIP] port:[[[PHCConnectionManager getConnectionManager] serverPort] intValue] delegate:[PHCConnectionManager getConnectionManager]];
			[[PHCConnectionManager getConnectionManager] setClient: client];
			[[[PHCConnectionManager getConnectionManager] client] connect];
			[client release];
		}
	}
}


@end

