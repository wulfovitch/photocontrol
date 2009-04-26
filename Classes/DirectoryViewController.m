#import "DirectoryViewController.h"

@implementation DirectoryViewController


@synthesize subDirectories;
@synthesize pictures;
@synthesize currentDirectory;
@synthesize conManager;
@synthesize dirViewController;
@synthesize tabBarViewController;

enum {
	selectionOfCurrentDirectory = 0,
	selectionOfDirectory
};

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = currentDirectory;
	noSubDirectories = false;
	
	UIBarButtonItem *refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
	self.navigationItem.rightBarButtonItem = refreshButton;
	[refreshButton release];
}

- (void)refresh {
	[conManager setRefreshing];
	[[conManager client] sendString:@"### SEND DIRECTORY ###\n"];
	[[conManager client] sendString:[NSString stringWithFormat:@"%@\n", currentDirectory]];
	[[conManager client] sendString:@"### END SEND DIRECTORY ###\n"];
	[[self tableView] reloadData];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section == 0) {
		return 1;
	} else {
		if([conManager isReceiving])
		{
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
		NSLog(@"nothing received");
	} else {
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
    
	if(indexPath.section == selectionOfCurrentDirectory)
	{
		if (imageCount > 0)
		{
			cell.text = @"Select this directory!";
			cell.image = [UIImage imageNamed:@"picture.png"];
		} else {
			cell.text = @"No Photos in this directory!";
			cell.image = nil;
		}
	}
	if(indexPath.section == selectionOfDirectory)
	{
		if (noSubDirectories)
		{
			cell.text = @"No Subdirectories!";
			cell.image = nil;
		} else {
			cell.text = [self.subDirectories objectAtIndex: indexPath.row];
			cell.image = [UIImage imageNamed:@"folder.png"];
		}
	}
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	if (section == 0) {
		return [NSString stringWithFormat: @"Current Directory (%i Photos)", imageCount];
	} else {
		return @"Subdirectories";
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
{
	if (imageCount > 0)
	{
		if(indexPath.section == selectionOfCurrentDirectory)
		{
			//if(self.clientViewController == nil || self.clientViewController.currentDirectory !=  [NSString stringWithFormat:@"%@%@/", self.currentDirectory, [self.subDirectories objectAtIndex: indexPath.row]])
			if(self.tabBarViewController == nil)
			{
				TabBarViewController *view = [[TabBarViewController alloc] init];
				self.tabBarViewController = view;
				[view release];
				[conManager setRefreshing];
				self.tabBarViewController.conManager = self.conManager;
				self.tabBarViewController.imageCount = imageCount;
				self.tabBarViewController.currentDirectory = [NSString stringWithFormat:@"%@", self.currentDirectory];

				
				// set the back button title of the pushed view controller
				[self.navigationItem setTitle:@"back"];
				

				
				/*
				//ClientViewController *view = [[ClientViewController alloc] initWithStyle:UITableViewStyleGrouped];
				ClientViewController *view = [[ClientViewController alloc] initWithNibName:@"ClientViewController" bundle:[NSBundle mainBundle]];
				
				self.clientViewController = view;
				[view release];
				
				// set the back button title of the pushed view controller
				[self.navigationItem setTitle:@"back"];
				
				self.clientViewController.conManager = self.conManager;
				self.clientViewController.currentDirectory = [NSString stringWithFormat:@"%@", self.currentDirectory];
				self.clientViewController.imageCount  = [NSNumber numberWithInt: imageCount];
				[conManager setRefreshing];
				[[conManager client] sendString:@"### START PICTURELIST ###\n"];
				[[conManager client] sendString:[NSString stringWithFormat:@"%@\n", currentDirectory]];
				[[conManager client] sendString:@"### END PICTURELIST ###\n"];
				*/
			}
			[self.navigationController pushViewController:self.tabBarViewController animated:YES];
		}
	}

	if (!noSubDirectories)
		if(indexPath.section == selectionOfDirectory)
		{
			if(self.dirViewController == nil || self.dirViewController.currentDirectory !=  [NSString stringWithFormat:@"%@%@/", self.currentDirectory, [self.subDirectories objectAtIndex: indexPath.row]])
			{
				DirectoryViewController *view = [[DirectoryViewController alloc] initWithStyle:UITableViewStyleGrouped];
				//DirectoryViewController *view = [[DirectoryViewController alloc] initWithNibName:@"DirectoryViewController" bundle:[NSBundle mainBundle]];
				
				[self setDirViewController: view];
				[view release];
				
				// set the back button title of the pushed view controller
				[self.navigationItem setTitle:@"back"];
				
				[[self dirViewController] setConManager: self.conManager];
				[[self dirViewController] setCurrentDirectory: [NSString stringWithFormat:@"%@%@/", [self currentDirectory], [[self subDirectories] objectAtIndex: indexPath.row]]];
				[[self dirViewController] refresh];
			}
			[self.navigationController pushViewController:self.dirViewController animated:YES];
		}
	}
}



- (void)viewWillAppear:(BOOL)animated {
	// make sure that every view controller has the right title
	[self.navigationItem setTitle:self.currentDirectory];
	[super viewWillAppear:animated];
}
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
}
*/
/*
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
*/

- (void)dealloc {
    [super dealloc];
}


@end