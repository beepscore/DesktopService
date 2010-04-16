//
//  ListenService.h
//  DesktopService
//
//  Created by Steve Baker on 4/15/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ApplicationController;


@interface ListenService : NSObject {

#pragma mark Instance variables
    ApplicationController* appController_;
    CFSocketRef socket_;
    NSFileHandle* connectionFileHandle_;
}

- (void)startService;
- (void)publishService;
- (void)handleIncomingConnection;
- (void)readIncomingData;
- (void)stopReceivingForFileHandle:(NSFileHandle*)fileHandleToStop 
                   closeFileHandle:(NSFileHandle*)fileHandleToClose;


@end
