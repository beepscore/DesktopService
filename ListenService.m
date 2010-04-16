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
NSString* const kServiceNameString = @"HW3_1 listen service";
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


// create socket for listening
- (void)startService{
    socket_ = CFSocketCreate(
                             kCFAllocatorDefault,
                             PF_INET,
                             SOCK_STREAM,
                             IPPROTO_TCP,
                             0,
                             NULL,
                             NULL
                             );    
    
    
    int fileDescriptor = CFSocketGetNative(socket_);
    
    // ????: Reuse
    NSInteger reuse;
    
    // set socket for reuse
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
    
}

- (void)publishService{
    
}


- (void)handleIncomingConnection{
    
}


- (void)readIncomingData{
    
}


- (void)stopReceivingForFileHandle:(NSFileHandle*)fileHandleToStop 
                   closeFileHandle:(NSFileHandle*)fileHandleToClose{
    
}

@end
