#import "PHCDirectoryViewController.h"

@implementation PHCDirectoryViewController


@synthesize subDirectories;
@synthesize pictures;
@synthesize currentDirectory;
@synthesize currentDirectoryName;
@synthesize picturesOfCurrentDirectory;
@synthesize conManager;
@synthesize dirViewController;
@synthesize cvc;
@synthesize nothingReceivedCounter;

enum {
	selectionOfCurrentDirectory = 0,
	selectionOfDirectory
};

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = currentDirectory;
	noSubDirectories = false;
	nothingReceivedCounter = 0;
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

- (void)viewWillAppear:(BOOL)animated {
	// make sure that every view controller has the right title
	[self.navigationItem setTitle:self.currentDirectory];
	[super viewWillAppear:animated];
}

- (void)dealloc {
    [super dealloc];
}

# pragma mark -
# pragma mark methods for the tableView

- (void)refresh {
	[conManager setRefreshing];
	[[conManager client] sendString:@"### SEND DIRECTORY ###\n"];
	[[conManager client] sendString:[NSString stringWithFormat:@"%@\n", currentDirectory]];
	[[conManager client] sendString:@"### END SEND DIRECTORY ###\n"];
	[[self tableView] reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2; // two sections - one for selecting the current directory, one for selecting an different directory
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == selectionOfCurrentDirectory) {
		return 1;
	} else {
		if([conManager isReceiving])
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
	if([conManager isReceiving])
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
		imageCount = [self.conManager imageCount];
		NSArray *dirArray = [[NSArray alloc] initWithArray:[self.conManager currentSubDirectories]];
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
			cell.text = NSLocalizedString(@"SelectThisDirectory", @"Select this directory!");
			cell.image = [UIImage imageNamed:@"picture.png"];
		} else {
			cell.text = NSLocalizedString(@"NoPhotosInThisDirectory", @"No Photos in this directory!");
			cell.image = nil;
		}
	}
	
	// table column for selection of subdirectories
	if(indexPath.section == selectionOfDirectory)
	{
		if (noSubDirectories)
		{
			cell.text = NSLocalizedString(@"NoSubdirectories", @"No Subdirectories!");
			cell.image = nil;
		} else {
			cell.text = [self.subDirectories objectAtIndex: indexPath.row];
			cell.image = [UIImage imageNamed:@"folder.png"];
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

- (UITableViewCellAccessoryType)tableView:(UITableView *)table accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == selectionOfCurrentDirectory)
	{
		if (imageCount > 0)
			return UITableViewCellAccessoryDisclosureIndicator;
	}
	if(indexPath.section == selectionOfDirectory)
	{
		if (!noSubDirectories)
			return UITableViewCellAccessoryDisclosureIndicator;
	}
	return UITableViewCellAccessoryNone;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if(indexPath.section == selectionOfCurrentDirectory)
	{
		if (imageCount > 0)
		{
			// requesting picturelist from server
			[conManager setRefreshing];
			[[conManager client] sendString:@"### START PICTURELIST ###\n"];
			[[conManager client] sendString:[NSString stringWithFormat:@"%@\n", self.currentDirectory]];
			[[conManager client] sendString:@"### END PICTURELIST ###\n"];
				
			// set the back button title of the pushed view controller
			[self.navigationItem setTitle:NSLocalizedString(@"BackButtonCurrentDirectorySelected", @"back")];

			cvc = [[PHCClientViewController alloc] initWithNibName:@"ClientViewController" bundle:[NSBundle mainBundle] synchron:YES];
			
			[cvc setConManager: self.conManager];
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
				PHCDirectoryViewController *view = [[PHCDirectoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
				//DirectoryViewController *view = [[DirectoryViewController alloc] initWithNibName:@"DirectoryViewController" bundle:[NSBundle mainBundle]];
				
				[self setDirViewController: view];
				[view release];
				
				// set the back button title of the pushed view controller
				[self.navigationItem setTitle:NSLocalizedString(@"BackButtonDirectorySelected", @"back")];
				
				[[self dirViewController] setConManager: self.conManager];
				[[self dirViewController] setCurrentDirectory: [NSString stringWithFormat:@"%@%@/", [self currentDirectory], [[self subDirectories] objectAtIndex: indexPath.row]]];
				[[self dirViewController] setCurrentDirectoryName: [[self subDirectories] objectAtIndex: indexPath.row]];
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