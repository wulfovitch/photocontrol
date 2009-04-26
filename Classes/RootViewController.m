#import "RootViewController.h"
#import <arpa/inet.h>
#import <netinet/in.h>

@implementation RootViewController

@synthesize directoryViewController;
@synthesize conManager;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Servers";
	
	browser = [[NSNetServiceBrowser alloc] init];
    [browser setDelegate:self];
	services = [[NSMutableArray array] retain];
	conManager = [[ConnectionManager alloc] init];
    
    [browser searchForServicesOfType:@"_photofoto._tcp." inDomain:@""];
}

- (void)dealloc {
	[browser release];
	[services release];
	[conManager release];
    [super dealloc];
}

- (void)refresh:(id)sender {
	[[self tableView] reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [services count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	static NSString *MyIdentifier = @"MyIdentifier";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
	}
	NSNetService *netService = [services objectAtIndex: [indexPath row]];
	if([netService respondsToSelector:@selector(name)])
		[cell setText: [netService name]];
	else
		[cell setText:@"Photo Server"];
	cell.image = [UIImage imageNamed:@"iMac.png"];
	
	return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if(self.directoryViewController == nil) {		
		//DirectoryViewController *view = [[DirectoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
		DirectoryViewController *view = [[DirectoryViewController alloc] initWithNibName:@"DirectoryViewController" bundle:[NSBundle mainBundle]];
		
		self.directoryViewController = view;
		[view release];
		
		// hide the back button if the user connect to a server
		[[self.directoryViewController navigationItem] setHidesBackButton:YES];
		
		// connect to server
		[self netServiceDidResolveAddress: [services objectAtIndex: [indexPath row]]];
		self.directoryViewController.conManager = self.conManager;
		self.directoryViewController.currentDirectory = @"/";
		[self.directoryViewController.conManager setRefreshing];
	}
	
	[self.navigationController pushViewController:self.directoryViewController animated:YES];
}

- (UITableViewCellAccessoryType)tableView:(UITableView *)table accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellAccessoryDisclosureIndicator;
}



- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
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
    [services removeObject:aNetService];
	NSLog(@"netservice count: %i", [services count]);
	
    if(!moreComing)
	{
		[[self tableView] reloadData];        
    }
}

- (void)netServiceDidStop:(NSNetService *)sender
{
	//[services removeObject:sender];
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
					[sender release];
					//serviceBeingResolved = nil;
					
					break;
				case AF_INET6:
					// PictureSharing server doesn't support IPv6
					return;
			}
		}   
		
		if (ipAddressString) [conManager setServerIP: ipAddressString];
		if (portString) [conManager setServerPort: portString];
		
		[conManager setClient: [[SimpleCocoaClient alloc] initWithHost:[conManager serverIP] port:[[conManager serverPort] intValue] delegate:conManager]];
		[[conManager client] connect];
	}
}


@end

