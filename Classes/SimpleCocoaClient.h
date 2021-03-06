//  
//  SimpleCocoaClient, a basic client class written in objectiv-c for use in cocoa applications
//   -- v0.3 --
//   SimpleCocoaClient.h
//   ------------------------------------------------------
//  | Created by David J. Koster, release 04.05.2009.      |
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

#import <UIKit/UIKit.h>

//return values of connect message
enum SCCInit {
    SCCInitOK = 1,
    SCCInitError_Connected = 2,
	SCCInitError_Host = 4,
	SCCInitError_Port = 8,
	SCCInitError_Delegate = 16,
	SCCInitError_NoConnection = 32,
	SCCInitError_Timeout = 64,
	SCCInitError_NoSocket = 128,
	SCCInitError_Unknown = 256
};
typedef enum SCCInit SCCInit;

#define SCCDefaultConnectionTimeout 30

@interface SimpleCocoaClient : NSObject {
@private
	
	id			delegate;
	NSString	*remoteHost;
	int			remotePort;
	NSFileHandle *fileHandle;
	BOOL		isConnected;
	BOOL		hasBeenInitialized;
	BOOL		stayingConnected;
	//BOOL		waitingForReply;
	int			connectionTimeout;
	NSStringEncoding defaultStringEncoding;
	
}

+ (id)client;
+ (id)clientWithHost:(NSString *)initHost port:(int)initPort andDelegate:(id)initDl;
+ (id)clientConnectedTo:(NSString *)initHost onPort:(int)initPort withDelegate:(id)initDl;

- (id)init;
- (id)initWithHost:(NSString *)initHost port:(int)initPort delegate:(id)initDl;

- (SCCInit)connect;
- (void)disconnect;

- (BOOL)sendData:(NSData *)data;
- (BOOL)sendString:(NSString *)string;
- (BOOL)sendString:(NSString *)string withEncoding:(NSStringEncoding)encoding;

- (BOOL)setNewHost:(NSString *)newHost andPort:(int)newPort;
- (BOOL)isConnected;

- (id)delegate;
- (BOOL)setDelegate:(id)newDl;
- (NSString *)remoteHost;
- (NSString *)remoteHostName;
- (BOOL)setRemoteHost:(NSString *)newHost;
- (int)remotePort;
- (BOOL)setRemotePort:(int)newPort;
- (BOOL)stayingConnected;
- (void)setStayingConnected:(BOOL)flag;
- (int)connectionTimeout;
- (void)setConnectionTimeout:(int)newTimeout;
- (NSStringEncoding)defaultStringEncoding;
- (void)setDefaultStringEncoding:(NSStringEncoding)encoding;

@end
