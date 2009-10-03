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


#import "DirectoryViewController.h"

@implementation DirectoryViewController


@synthesize subDirectories;
@synthesize pictures;
@synthesize currentDirectory;
@synthesize currentDirectoryName;
@synthesize picturesOfCurrentDirectory;
@synthesize dirViewController;
@synthesize cvc;
@synthesize nothingReceivedCounter;

enum {
	selectionOfCurrentDirectory = 0,
	selectionOfDirectory
};

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = currentDirectoryName;
	noSubDirectories = false;
	nothingReceivedCounter = 0;
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

- (void)viewWillAppear:(BOOL)animated {
	// make sure that every view controller has the right title
	[self.navigationItem setTitle:self.currentDirectoryName];
	[super viewWillAppear:animated];
}

- (void)dealloc {
    [super dealloc];
}

# pragma mark -
# pragma mark methods for the tableView

- (void)refresh {
	[[ConnectionManager getConnectionManager] setRefreshing];
	[[[ConnectionManager getConnectionManager] client] sendString:@"### SEND DIRECTORY ###\n"];
	[[[ConnectionManager getConnectionManager] client] sendString:[NSString stringWithFormat:@"%@\n", currentDirectory]];
	[[[ConnectionManager getConnectionManager] client] sendString:@"### END SEND DIRECTORY ###\n"];
	[[self tableView] reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // two sections - one for selecting the current directory, one for selecting an different directory
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == selectionOfCurrentDirectory) {
		return 1;
	} else {
		if([[ConnectionManager getConnectionManager] isReceiving])
		{
			// setup timer if the server is busy
			reloadDirectoriesTimer = [NSTimer scheduledTimerWithTimeInterval: 0.1
													 target: self
												   selector: @selector(handleTimer:)
												   userInfo: nil
													repeats: YES];
			return 0;
		} else {
			if ([self.subDirectories count] > 0)
			{
				return [self.subDirectories count];
			} else {
				noSubDirectories = true;
				return 1;
			}
		}
	} 
}

- (void)handleTimer:(NSTimer *)timer
{
	if([[ConnectionManager getConnectionManager] isReceiving])
	{
		nothingReceivedCounter++;
		NSLog(@"nothing received: %d", nothingReceivedCounter);
		if(nothingReceivedCounter > 50) // the value 50 is arbitrarily choosen
		{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:NSLocalizedString(@"connection lost", @"The connection to the server seems to be lost. Please restart the application and establish the connection again!") 
														   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			[timer invalidate];
		}
	} else {
		nothingReceivedCounter = 0;
		NSLog(@"invalidate");
		imageCount = [[ConnectionManager getConnectionManager] imageCount];
		NSArray *dirArray = [[NSArray alloc] initWithArray:[[ConnectionManager getConnectionManager] currentSubDirectories]];
		[self setSubDirectories: dirArray];
		[dirArray release];
		[self.tableView reloadData];
		[timer invalidate];
	}
} 

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
	// table column for selection of current directory
	if(indexPath.section == selectionOfCurrentDirectory)
	{
		if (imageCount > 0)
		{
			[[cell textLabel] setText: NSLocalizedString(@"SelectThisDirectory", @"Select this directory!")];
			[[cell imageView] setImage: [UIImage imageNamed:@"picture.png"]];
			[cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator];
		} else {
			[[cell textLabel] setText: NSLocalizedString(@"NoPhotosInThisDirectory", @"No Photos in this directory!")];
			[[cell imageView] setImage: nil];
			[cell setAccessoryType: UITableViewCellAccessoryNone];
		}
	}
	
	// table column for selection of subdirectories
	if(indexPath.section == selectionOfDirectory)
	{
		if (noSubDirectories)
		{
			[[cell textLabel] setText: NSLocalizedString(@"NoSubdirectories", @"No Subdirectories!")];
			[[cell imageView] setImage:nil];
			[cell setAccessoryType:UITableViewCellAccessoryNone];
		} else {
			NSString *cellText = [self.subDirectories objectAtIndex: indexPath.row];
			NSRange delimiter = [cellText rangeOfString:@"_"];
			
			//NSLog(@"substringtoindex: %@", [cellText substringToIndex: delimiter.location]);
			//NSLog(@"substringfromindex: %@", [cellText substringFromIndex: delimiter.location+1]);

			[[cell textLabel] setText: [[cellText substringFromIndex: delimiter.location+1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
			[[cell imageView] setImage: [UIImage imageNamed:@"folder.png"]];
			[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		}
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == selectionOfCurrentDirectory) {
		return [NSString stringWithFormat: NSLocalizedString(@"CurrentDirectoryCount", @"Current Directory (%i Photos)"), imageCount];
	} else {
		return NSLocalizedString(@"Subdirectories", @"Subdirectories");
	}
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == selectionOfCurrentDirectory)
	{
		if (imageCount > 0)
		{
			// set the back button title of the pushed view controller
			[self.navigationItem setTitle:NSLocalizedString(@"BackButtonCurrentDirectorySelected", @"back")];

			cvc = [[PhotoViewController alloc] initWithNibName:@"PhotoViewController" bundle:[NSBundle mainBundle] synchron:YES];
			
			[cvc setCurrentDirectory: [NSString stringWithFormat:@"%@", self.currentDirectory]];
			[cvc setCurrentDirectoryName: self.currentDirectoryName];
			[cvc setImageCount: imageCount];
			
			[self.navigationController pushViewController:cvc animated:YES];
			[cvc release];
		} else {
			// if the folder contains no pictures, we do not want it to be marked as selected
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	}


	if(indexPath.section == selectionOfDirectory)
	{
		if (!noSubDirectories)
		{
			if(self.dirViewController == nil || self.dirViewController.currentDirectory !=  [NSString stringWithFormat:@"%@%@/", self.currentDirectory, [self.subDirectories objectAtIndex: indexPath.row]])
			{
				DirectoryViewController *view = [[DirectoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
				
				[self setDirViewController: view];
				[view release];
				
				// set the back button title of the pushed view controller
				[self.navigationItem setTitle:NSLocalizedString(@"BackButtonDirectorySelected", @"back")];
				
				NSString *subDirText = [self.subDirectories objectAtIndex: indexPath.row];
				NSRange delimiter = [subDirText rangeOfString:@"_"];
				NSLog(@"currentDirectoryName: %@", currentDirectoryName);
				[[self dirViewController] setCurrentDirectory: [NSString stringWithFormat:@"%@/", [subDirText substringToIndex: delimiter.location]]];
				[[self dirViewController] setCurrentDirectoryName: [[subDirText substringFromIndex: delimiter.location+1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
				[[self dirViewController] refresh];
			}
			[self.navigationController pushViewController:self.dirViewController animated:YES];
		} else {
			// if the folder contains no subdirectories, we do not want it to be marked as selected
			[tableView deselectRowAtIndexPath:indexPath animated:NO];
		}
	}
}

@end