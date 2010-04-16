//
//  DesktopServiceAppDelegate.m
//  DesktopService
//
//  Created by Steve Baker on 4/15/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//  Reference Dalrymple Advanced Mac OS X Programming Ch 12 p 328

#import "DesktopServiceAppDelegate.h"
#import "ListenService.h"

@implementation DesktopServiceAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	// Insert code here to initialize your application 
    
    listenService_ = [[ListenService alloc] init];
    [listenService_ startService];
    [listenService_ publishService];
}

@end
