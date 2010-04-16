//
//  DesktopServiceAppDelegate.h
//  DesktopService
//
//  Created by Steve Baker on 4/15/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class ListenService;

@interface DesktopServiceAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
    ListenService *listenService_;    
}

@property (assign) IBOutlet NSWindow *window;

@end
