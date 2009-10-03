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


#import <UIKit/UIKit.h>
#import "DirectoryViewController.h"
#import "AboutViewController.h"

@interface RootViewController : UITableViewController <UIActionSheetDelegate> {
	DirectoryViewController *directoryViewController;
	NSNetServiceBrowser *browser;
	NSMutableArray *services;
}
@property (nonatomic, retain) DirectoryViewController *directoryViewController;

- (void)refresh:(id)sender;
- (void)helpSelector;

@end
