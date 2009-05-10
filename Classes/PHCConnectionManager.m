#import "PHCConnectionManager.h"

@interface PHCConnectionManager (Private)  
- (id)initConnectionManager;
@end 

@implementation PHCConnectionManager (Private)

- (id)initConnectionManager {
	[super init];
	self.currentSubDirectories = [[NSMutableArray alloc] init];
	self.currentPictures = [[NSMutableArray alloc] init];
	return self;
}

@end



@implementation PHCConnectionManager

@synthesize client;
@synthesize serverIP;
@synthesize serverPort;
@synthesize currentDirectory;
@synthesize currentSubDirectories;
@synthesize currentPictures;

enum {
	receivingNothing = 0,
	gettingSubDirs,
	gettingImageCount,
	gettingPictureList
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

/*
- (id)init {
	[super init];
	self.currentSubDirectories = [[NSMutableArray alloc] init];
	self.currentPictures = [[NSMutableArray alloc] init];
	return self;
}
*/

- (void)dealloc {
	[currentSubDirectories release];
	[currentPictures release];
	[super dealloc];
}

# pragma mark -
# pragma mark delegate methods for receiving strings

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
					if([messageLine isEqualToString:@"### START PICTURELIST ###"])
					{
						NSLog(@"starting picturelist");
						receiving = gettingPictureList;
						[currentPictures removeAllObjects];
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
				
				case gettingPictureList:
					if([messageLine isEqualToString:@"### END PICTURELIST ###"])
					{
						NSLog(@"stopping picturelist");
						receiving = receivingNothing;
						refreshing = false;
					} else {
						NSLog(@"picturelist: '%@'", messageLine);
						[currentPictures addObject:messageLine];
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
