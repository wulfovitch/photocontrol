//  
//  SimpleCocoaClient, a basic client class written in objectiv-c for use in cocoa applications
//   -- v0.1 --
//   SimpleCocoaClient.m
//   ------------------------------------------------------
//  | Created by David J. Koster, release 28.05.2008.      |
//  | Copyright 2008 David J. Koster. All rights reserved. |
//  | http://www.david-koster.de/code/simpleserver         |
//  | code@david-koster.de for help or see:                |
//  | http://sourceforge.net/projects/simpleserver         |
//   ------------------------------------------------------
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
	return self;
}

- (id)initWithHost:(NSString *)initHost port:(int)initPort delegate:(id)initDl
{
	if(self = [self init]) {
		[self setRemoteHost:initHost];
		[self setRemotePort:initPort];
		[self setDelegate:initDl];
	} else {
		return nil;
	}
	return self;
}

- (void)dealloc
{
	if(isConnected) {
		[[NSNotificationCenter defaultCenter] removeObserver:self];
		[fileHandle release];
	}
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
		
		int retVal = CFSocketConnectToAddress(socket, (CFDataRef)address4, connectionTimeout);
		
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
	[nc addObserver:self
		   selector:@selector(dataReceivedNotification:)
			   name:NSFileHandleReadCompletionNotification
			 object:nil];
	[fileHandle readInBackgroundAndNotify];
	
	isConnected = YES;
	return SCCInitOK;
}

- (void)disconnect
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	CFSocketRef socket = CFSocketCreateWithNative(kCFAllocatorDefault,[fileHandle fileDescriptor],1,NULL,NULL);
	CFSocketInvalidate(socket);
	CFRelease(socket);
	[fileHandle release];
	isConnected = NO;
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
	return [self sendData:[string dataUsingEncoding:NSASCIIStringEncoding]];
}

- (void)dataReceivedNotification:(NSNotification *)notification
{
	NSData *data = [[notification userInfo] objectForKey:NSFileHandleNotificationDataItem];
	
	if ([data length] == 0) {
		// NSFileHandle's way of telling us that the client closed the connection
		[self disconnect];
	} else {
		[fileHandle readInBackgroundAndNotify];
		NSString *received = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
		//NSLog(@"%@",received);
		if([delegate respondsToSelector:@selector(processMessage:fromClient:)]) {
			[delegate processMessage:received fromClient:self];
		}
	}
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
	[self setRemoteHost:newHost];
	[self setRemotePort:newPort];
	return YES;
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

- (int)connectionTimeout
{
	return connectionTimeout;
}

- (void)defaultTimeout
{
	connectionTimeout = 30;
}

- (void)setConnectionTimeout:(int)newTimeout
{
	connectionTimeout = newTimeout;
}

@end
