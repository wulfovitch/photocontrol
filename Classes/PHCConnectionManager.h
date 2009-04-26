#import <UIKit/UIKit.h>
#import "SimpleCocoaClient.h"


@interface PHCConnectionManager : NSObject {
	
	// SimpleCocoaClient settings
	SimpleCocoaClient *client;
	NSString *serverIP;
	NSString *serverPort;
	
	// path of the current directory
	NSString *currentDirectory;
	
	// content of the current directory
	NSMutableArray *currentSubDirectories;
	NSMutableArray *currentPictures;
	
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
@property (nonatomic, retain) NSMutableArray *currentPictures;

- (BOOL)isReceiving;
- (void)setRefreshing;
- (NSInteger)imageCount;

@end
