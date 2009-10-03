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


#import "PHCConnectionManager.h"

@interface PHCConnectionManager (Private)  
- (id)initConnectionManager;
@end 

@implementation PHCConnectionManager (Private)

- (id)initConnectionManager {
	[super init];
	self.currentSubDirectories = [[NSMutableArray alloc] init];
	return self;
}

@end



@implementation PHCConnectionManager

@synthesize client;
@synthesize serverIP;
@synthesize serverPort;
@synthesize currentDirectory;
@synthesize currentSubDirectories;

enum {
	receivingNothing = 0,
	gettingSubDirs,
	gettingImageCount
};


// instance of the singleton
static PHCConnectionManager *conManager = nil;

+ (PHCConnectionManager *)getConnectionManager {
	if(conManager == NULL)
	{
		conManager = [[self alloc] initConnectionManager];
	}
	return conManager;
}

+ (void)terminateConnectionManager {
	conManager = nil;
}

- (void)dealloc {
	[currentSubDirectories release];
	[super dealloc];
}

# pragma mark -
# pragma mark delegate methods for receiving strings

-(void)processData:(NSData *)data fromClient:(SimpleCocoaClient *)fromClient {
	NSLog(@"incoming data");
	
	NSString *received = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	[self processMessage:received fromClient:fromClient];
	[received release];
}


-(void)processMessage:(NSString *)message fromClient:(SimpleCocoaClient *)fromClient {
	NSLog(@"%@", message);
	NSArray *messageArray = [message componentsSeparatedByString:@"\n"];
	
	NSUInteger i, count = [messageArray	count];
	for (i = 0; i < count; i++) {
		NSString *messageLine = [messageArray objectAtIndex:i];
		
		if(![messageLine isEqualToString: @""])
		{
			switch (receiving) {
				case receivingNothing:
					if([messageLine isEqualToString:@"### START DIRECTORIES ###"])
					{
						NSLog(@"starting dirs");
						receiving = gettingSubDirs;
						[currentSubDirectories removeAllObjects];
					}
					if([messageLine isEqualToString:@"### START IMAGECOUNT ###"])
					{
						NSLog(@"starting imagecount");
						receiving = gettingImageCount;
					}
					break;
					
				case gettingSubDirs:
					if([messageLine isEqualToString:@"### END DIRECTORIES ###"])
					{
						NSLog(@"ending dirs");
						receiving = gettingImageCount;
						refreshing = false;
					} else {
						NSLog(@"adding object: '%@'", messageLine);
						[currentSubDirectories addObject:messageLine];
					}
					break;
					
				case gettingImageCount:
					if([messageLine isEqualToString:@"### END IMAGECOUNT ###"])
					{
						NSLog(@"stopping imagecount");
						receiving = receivingNothing;
						refreshing = false;
					} else {
						NSLog(@"imagecount: '%@'", messageLine);
						imageCount = [messageLine intValue];
					}
					break;
			}
		}
	}
}



# pragma mark -
# pragma mark getter / setter

- (BOOL)isReceiving
{
	if (self.currentSubDirectories == nil || refreshing)
		return TRUE;
	
	return receiving > receivingNothing;
}

- (void)setRefreshing
{
	refreshing = true;
}

- (NSInteger)imageCount
{
	return imageCount;
}

@end
