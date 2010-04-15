//
//  DesktopServiceAppDelegate.h
//  DesktopService
//
//  Created by Steve Baker on 4/15/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface DesktopServiceAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
