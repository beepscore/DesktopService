//
//  ListenService.m
//  DesktopService
//
//  Created by Steve Baker on 4/15/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//
// Class that handles listening for incoming connections
// and advertises its service via Bonjour

#import "ListenService.h"

#import "ApplicationController.h"
#import <sys/socket.h>  // for socket(), PF_INET
#import <netinet/in.h>  // for IPPROTO_TCP

// Ref Class 3 video 02:29:01, 02:31:09
NSString* const kServiceTypeString = @"_uwcelistener._tcp.";
NSString* const kServiceNameString = @"Beepscore listen service";
const NSUInteger kListenPort = 8081;


@implementation ListenService

- (id)init {
    if (self = [super init]) {
        
        appController_ = [ApplicationController sharedApplicationController];
        socket_ = nil;
        connectionFileHandle_ = nil;
    }
    return self;
}


- (BOOL)startService{
    
    // create socket for listening
    socket_ = CFSocketCreate(
                             kCFAllocatorDefault,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             0,
                             NULL,
                             NULL
                             );    
    
    // set socket for reuse
    int fileDescriptor = CFSocketGetNative(socket_);
    int reuse = true;
    int result = setsockopt(
                            fileDescriptor,
                            SOL_SOCKET,
                            SO_REUSEADDR,
                            (void *)&reuse,
                            sizeof(int)
                            );
    
    if (-1 == result) {
        NSLog(@"ERROR setsockopt");
    }
    
    // set socket structure
    struct sockaddr_in address;
	memset(&address, 0, sizeof(address));
	address.sin_len = sizeof(address);
	address.sin_family = AF_INET;
	address.sin_addr.s_addr = htonl(INADDR_ANY);
	address.sin_port = htons(kListenPort);    
    
    // wrap socket structure in CFData
    CFDataRef addressData = CFDataCreate(NULL, (const UInt8 *)&address, sizeof(address));	
	[(id)addressData autorelease];
    
	// bind socket to the address
	if (CFSocketSetAddress(socket_, addressData) != kCFSocketSuccess)
	{
		[appController_ appendStringToLog:@"Unable to bind socket to address\n"];
		return NO;
	}
    
    [appController_ appendStringToLog:
     [NSString stringWithFormat:@"Listening to socket on port %d\n", kListenPort]];
    
    
    // wrap the file descriptor associated with socket in a NSFileHandle
    connectionFileHandle_ = [[NSFileHandle alloc] initWithFileDescriptor:fileDescriptor closeOnDealloc:YES];
	
    // register for connection notifications
	[[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(handleIncomingConnection:) 
     name:NSFileHandleConnectionAcceptedNotification
     object:nil];
	
	[connectionFileHandle_ acceptConnectionInBackgroundAndNotify];
    return YES;
}


// handle NSFileHandleConnectionAcceptedNotifications
- (void)handleIncomingConnection:(NSNotification*)notification
{
	NSDictionary*	userInfo			=	[notification userInfo];
	NSFileHandle*	readFileHandle		=	[userInfo objectForKey:NSFileHandleNotificationFileHandleItem];
	
    if(readFileHandle)
	{
		[[NSNotificationCenter defaultCenter]
		 addObserver:self
		 selector:@selector(readIncomingData:)
		 name:NSFileHandleDataAvailableNotification
		 object:readFileHandle];
		
		[appController_ appendStringToLog:@"Opened an incoming connection."];
		
        [readFileHandle waitForDataInBackgroundAndNotify];
    }
	
	[connectionFileHandle_ acceptConnectionInBackgroundAndNotify];
}


- (void) readIncomingData:(NSNotification*) notification
{
	NSFileHandle*	readFileHandle	= [notification object];
	NSData*			data			= [readFileHandle availableData];
	
	if ([data length] == 0)
	{
		[appController_ appendStringToLog:@"\nNo more data in file handle, closing.\n"];
		
		[self stopReceivingForFileHandle:readFileHandle closeFileHandle:YES];
		return;
	}	
    
    NSString *dataString = [[NSString alloc]initWithUTF8String:[data bytes]];
	[appController_ appendStringToLog:@"\nGot a message: "];
	[appController_ appendStringToLog:dataString];
    [self respondToCommandString:dataString];
    [dataString release];
	
	// wait for a read again
	[readFileHandle waitForDataInBackgroundAndNotify];	
}


- (void)stopReceivingForFileHandle:(NSFileHandle*)fileHandleToStop 
                   closeFileHandle:(BOOL)closeFileBool{
    
}


- (void)publishService{
    // publish on the default domains
	// domain can be @"" or @"local."
    NSNetService* netService = [[NSNetService alloc] initWithDomain:@"" 
                                                               type:kServiceTypeString
                                                               name:kServiceNameString 
                                                               port:kListenPort];
    [netService setDelegate:self];
    [netService publish];
    [appController_ appendStringToLog:
     [NSString stringWithFormat:@"Published service type:%@ with name %@ on port %d\n",
      kServiceTypeString, kServiceNameString, kListenPort]];
}


- (void)respondToCommandString:(NSString *)commandString
{
    // toggle shouldDrawColor1,2,3
    if ([commandString isEqualToString:@"color1"]) {
        [appController_ setShouldDrawColor1:![appController_ shouldDrawColor1]];
    }
    if ([commandString isEqualToString:@"color2"]) {
        [appController_ setShouldDrawColor2:![appController_ shouldDrawColor2]];
    }
    if ([commandString isEqualToString:@"color3"]) {
        [appController_ setShouldDrawColor3:![appController_ shouldDrawColor3]];
    }
}

@end
