//
//  ListenService.h
//  DesktopService
//
//  Created by Steve Baker on 4/15/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ApplicationController;


@interface ListenService : NSObject <NSNetServiceDelegate> {

#pragma mark Instance variables
    ApplicationController* appController_;
    CFSocketRef socket_;
    NSFileHandle* connectionFileHandle_;
}

- (BOOL)startService;
- (void)handleIncomingConnection:(NSNotification*)notification;
- (void)readIncomingData:(NSNotification*) notification;

- (void)stopReceivingForFileHandle:(NSFileHandle*)fileHandleToStop 
                   closeFileHandle:(BOOL)closeFileBool;

- (void)publishService;

@end
