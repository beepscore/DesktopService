//
//  ApplicationController.h
//  DesktopService
//
//  Created by Steve Baker on 4/16/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface ApplicationController : NSObject {

    NSTextView* logTextView;
}

#pragma mark properties
@property(nonatomic,retain)IBOutlet NSTextView *logTextView;

// singleton pattern
+(ApplicationController*)sharedApplicationController;

-(void)appendStringToLog:(NSString*)aString;

@end
