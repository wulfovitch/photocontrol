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
#import "SimpleCocoaClient.h"


@interface ConnectionManager : NSObject {
	
	// SimpleCocoaClient settings
	SimpleCocoaClient *client;
	NSString *serverIP;
	NSString *serverPort;
	
	// path of the current directory
	NSString *currentDirectory;
	
	// content of the current directory
	NSMutableArray *currentSubDirectories;
	
	// Boolean
	BOOL refreshing;
	NSInteger imageCount;
	NSInteger receiving;
}

@property (nonatomic, retain) SimpleCocoaClient *client;
@property (nonatomic, retain) NSString *serverIP;
@property (nonatomic, retain) NSString *serverPort;
@property (nonatomic, retain) NSString *currentDirectory;
@property (nonatomic, retain) NSMutableArray *currentSubDirectories;

+ (ConnectionManager *)getConnectionManager;
+ (void)terminateConnectionManager;
- (BOOL)isReceiving;
- (void)setRefreshing;
- (NSInteger)imageCount;

// delegate methods
-(void)processMessage:(NSString *)message fromClient:(SimpleCocoaClient *)fromClient;

@end
