//  
//  SimpleCocoaClient, a basic client class written in objectiv-c for use in cocoa applications
//   -- v0.3 --
//   SimpleCocoaClient.m
//   ------------------------------------------------------
//  | Created by David J. Koster, release 28.05.2008.      |
//  | Copyright 2008 David J. Koster. All rights reserved. |
//  | http://www.david-koster.de/code/simpleserver         |
//  | code@david-koster.de for help or see:                |
//  | http://sourceforge.net/projects/simpleserver         |
//   ------------------------------------------------------
//	| slightly modified by Wolfgang König                  |
//	| for the photocontrol client                          |
//	| see http://photocontrol.net                          |
//	 ------------------------------------------------------
// 
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
// 
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
// 
//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>. */
//

#import "SimpleCocoaClient.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netdb.h>
#import <arpa/inet.h>

@interface SimpleCocoaClient (PrivateMethods)

- (void)setIsConnected:(BOOL)val;

@end


@implementation SimpleCocoaClient

#pragma mark Class Methods

+ (id)client
{
	SimpleCocoaClient *c = [[SimpleCocoaClient alloc] init];
	return c;
}

+ (id)clientWithHost:(NSString *)initHost port:(int)initPort andDelegate:(id)initDl
{
	SimpleCocoaClient *c = [[SimpleCocoaClient alloc] initWithHost:initHost port:initPort delegate:initDl];
	return c;
}

+ (id)clientConnectedTo:(NSString *)initHost onPort:(int)initPort withDelegate:(id)initDl
{
	SimpleCocoaClient *c = [[SimpleCocoaClient alloc] initWithHost:initHost port:initPort delegate:initDl];
	
	if(c) {
		if([c connect] == SCCInitOK) {
			[c setIsConnected:YES];
			return c;
		}
	}
	return nil;
}

#pragma mark Instance Methods

- (id)init
{
	if(hasBeenInitialized)
		return nil;
	self = [super init];
	isConnected = NO;
	hasBeenInitialized = YES;
	stayingConnected = YES;
	// stayingConnected = NO;
	//waitingForReply = NO;
	defaultStringEncoding = NSUTF8StringEncoding;
	return self;
}

- (id)initWithHost:(NSString *)initHost port:(int)initPort delegate:(id)initDl
{
	if(self = [self init]) {
		if(![self setRemoteHost:initHost])
			return nil;
		if(![self setRemotePort:initPort])
			return nil;
		if(![self setDelegate:initDl])
			return nil;
	} else {
		return nil;
	}
	return self;
}

- (void)dealloc
{
	if(isConnected) {
		[self disconnect];
	}
	[remoteHost release];
	[delegate release];
	[super dealloc];
}

#pragma mark Connecting

- (SCCInit)connect
{
	if(isConnected)
		return SCCInitError_Connected;
	if(!remoteHost)
		return SCCInitError_Host;
	if(remotePort < 1)
		return SCCInitError_Port;
	if(!delegate)
		return SCCInitError_Delegate;
	
	int filedescriptor = -1;
	CFSocketRef socket = CFSocketCreate(kCFAllocatorDefault, PF_INET, SOCK_STREAM, IPPROTO_TCP, 1, NULL, NULL);
	
	if(socket) {
		
		filedescriptor = CFSocketGetNative(socket);
		
		//this code prevents the socket from existing after the server has crashed or been forced to close
		
		int yes = 1;
		setsockopt(filedescriptor, SOL_SOCKET, SO_REUSEADDR, (void *)&yes, sizeof(yes));
		
		struct sockaddr_in addr4;
		memset(&addr4, 0, sizeof(addr4));
		addr4.sin_len = sizeof(addr4);
		addr4.sin_family = AF_INET;
		addr4.sin_port = htons(remotePort);
		inet_pton(AF_INET, [remoteHost UTF8String], &addr4.sin_addr);

		NSData *address4 = [NSData dataWithBytes:&addr4 length:sizeof(addr4)];
		
		int retVal = CFSocketConnectToAddress(socket, (CFDataRef)address4, [self connectionTimeout]);
		
		if(retVal == kCFSocketError)
			return SCCInitError_NoConnection;
		if(retVal == kCFSocketTimeout)
			return SCCInitError_Timeout;
		if(retVal != kCFSocketSuccess)
			return SCCInitError_Unknown;
		
	} else {
		return SCCInitError_NoSocket;
	}
	
	fileHandle = [[NSFileHandle alloc] initWithFileDescriptor:filedescriptor
											   closeOnDealloc:YES];
	NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
	if([self stayingConnected]) {
		[nc addObserver:self
			   selector:@selector(dataReceivedNotification:)
				   name:NSFileHandleReadCompletionNotification
				 object:nil];
		[fileHandle readInBackgroundAndNotify];
	} else {
		[nc addObserver:self
			   selector:@selector(dataReceivedNotification:)
				   name:NSFileHandleReadToEndOfFileCompletionNotification
				 object:nil];
		[fileHandle readToEndOfFileInBackgroundAndNotify];
	}
	isConnected = YES;
	return SCCInitOK;
}

- (void)disconnect
{
	if([delegate respondsToSelector:@selector(connectionWillClose:)])
		[delegate performSelector:@selector(connectionWillClose:) withObject:self];
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault,[fileHandle fileDescriptor],1,NULL,NULL);
	CFSocketInvalidate(socket);
	CFRelease(socket);
	[fileHandle release];
	isConnected = NO;
	if([delegate respondsToSelector:@selector(connectionDidClose:)])
		[delegate performSelector:@selector(connectionDidClose:) withObject:self];
}

#pragma mark Sending and Receiving

- (BOOL)sendData:(NSData *)data
{
	@try {
		[fileHandle writeData:data];
    }
    @catch (NSException *exception) {
		//[self processDataSendingError:exception forConnection:con]; //Not used in this version. Perhaps used and documented in future versions.
		return NO;
    }
	return YES;
}

- (BOOL)sendString:(NSString *)string
{
	return [self sendData:[string dataUsingEncoding:[self defaultStringEncoding]]];
}

- (BOOL)sendString:(NSString *)string withEncoding:(NSStringEncoding)encoding
{
	return [self sendData:[string dataUsingEncoding:encoding]];
}

- (void)dataReceivedNotification:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	if([data length] == 0) {
		[self disconnect];
		return;
	}
	if([self stayingConnected]) {
		[fileHandle readInBackgroundAndNotify];
	} else {
		[self disconnect];
	}
	if([delegate respondsToSelector:@selector(processData:fromClient:)])
		[delegate performSelector:@selector(processData:fromClient:) withObject:data withObject:self];
}


#pragma mark Other Methods

- (void)setIsConnected:(BOOL)val
{
	isConnected = val;
}

- (BOOL)setNewHost:(NSString *)newHost andPort:(int)newPort
{
	if(isConnected)
		return NO;
	if(![self setRemoteHost:newHost])
		return NO;
	if(![self setRemotePort:newPort])
		return NO;
	return YES;
}

- (BOOL)isConnected {
	return isConnected;
}
#pragma mark Accessor Methods

- (id)delegate
{
	return delegate;
}

- (BOOL)setDelegate:(id)newDl
{
	if(isConnected)
		return NO;
	newDl = [newDl retain];
	[delegate release];
	delegate = newDl;
	return YES;
}

- (NSString *)remoteHost
{
	return remoteHost;
}

- (NSString *)remoteHostName
{
	struct in_addr IPaddr;
	struct hostent *host;
	inet_pton(AF_INET, [remoteHost UTF8String], &IPaddr);
	host = gethostbyaddr((char *) &IPaddr, sizeof(IPaddr),AF_INET);
	return [NSString stringWithUTF8String:(host->h_name)];
}

- (BOOL)setRemoteHost:(NSString *)newHost
{
	if(isConnected)
		return NO;
	newHost = [newHost retain];
	if(!newHost)
		return NO;
	
	struct in_addr IPaddr;
	struct hostent *host;
	int IPok = inet_pton(AF_INET, [newHost UTF8String], &IPaddr);
	if(!IPok) {
		host = gethostbyname([newHost UTF8String]);
		if(host) {
			[newHost release];
			char ipchar[16];
			inet_ntop(AF_INET,host->h_addr_list[0], ipchar, sizeof(ipchar));
			newHost = [NSString stringWithUTF8String:ipchar];
		} else
			return NO;
	}
	[remoteHost release];
	remoteHost = newHost;
	return YES;
}


- (int)remotePort
{
	return remotePort;
}

- (BOOL)setRemotePort:(int)newPort
{
	if(isConnected)
		return NO;
	remotePort = newPort;
	return YES;
}

- (BOOL)stayingConnected
{
	return stayingConnected;
}

- (void)setStayingConnected:(BOOL)flag
{
	stayingConnected = flag;
}

- (int)connectionTimeout
{
	if(connectionTimeout < 1)
		return SCCDefaultConnectionTimeout;
	return connectionTimeout;
}

- (void)setConnectionTimeout:(int)newTimeout
{
	connectionTimeout = newTimeout;
}

- (NSStringEncoding)defaultStringEncoding
{
	return defaultStringEncoding;
}

- (void)setDefaultStringEncoding:(NSStringEncoding)encoding
{
	defaultStringEncoding = encoding;
}

@end
