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


#import "RootViewController.h"
#import <arpa/inet.h>
#import <netinet/in.h>

@implementation RootViewController

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
	[ConnectionManager getConnectionManager];
    
    [browser searchForServicesOfType:@"_photocontrol._tcp." inDomain:@""];
	
	UIBarButtonItem *helpButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help", @"Help") style:UIBarButtonItemStylePlain target:self action:@selector(helpSelector)];
	
	self.navigationItem.rightBarButtonItem = helpButton;
	[helpButton release];
}

- (void)helpSelector {
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
				[[cell textLabel] setText: [netService name]];
			else
				[[cell textLabel] setText: NSLocalizedString(@"DefaultPhotoServer", @"default name of an photo control server")];
				[[cell imageView] setImage: [UIImage imageNamed:@"iMac.png"]];
				[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		} else {
			[[cell textLabel] setText: NSLocalizedString(@"NoServerFound", @"No server found")];
			[[cell imageView] setImage:nil];
		}
	}
	
	// table column for selection of current directory
	if(indexPath.section == sectionHelp)
	{
		if(indexPath.row == rowAbout)
		{
			[[cell textLabel] setText:NSLocalizedString(@"AboutThisApplication", @"about this Application")];
			[[cell imageView] setImage:[UIImage imageNamed:@"about.png"]];
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
			DirectoryViewController *view = [[DirectoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
			
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
			AboutViewController *view = [[AboutViewController alloc] init];
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
	
	[ConnectionManager terminateConnectionManager];
	
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
						ipAddressString = [NSString stringWithCString:buffer encoding: NSASCIIStringEncoding];
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
			[[ConnectionManager getConnectionManager] setServerIP: ipAddressString];
			[[ConnectionManager getConnectionManager] setServerPort: portString];
			SimpleCocoaClient *client = [[SimpleCocoaClient alloc] initWithHost:[[ConnectionManager getConnectionManager] serverIP] port:[[[ConnectionManager getConnectionManager] serverPort] intValue] delegate:[ConnectionManager getConnectionManager]];
			[[ConnectionManager getConnectionManager] setClient: client];
			[[[ConnectionManager getConnectionManager] client] connect];
			[client release];
		}
	}
}


@end

