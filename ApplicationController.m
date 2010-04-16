//
//  ApplicationController.m
//  DesktopService
//
//  Created by Steve Baker on 4/16/10.
//  Copyright 2010 Beepscore LLC. All rights reserved.
//

#import "ApplicationController.h"


@implementation ApplicationController

#pragma mark properties
@synthesize logTextView;


// FIXME: Implement singleton pattern
+(ApplicationController*)sharedApplicationController{
    return self;
}

- (void)dealloc {
    [logTextView release], logTextView = nil;
    
    [super dealloc];
}

-(void)appendStringToLog:(NSString*)aString{
    
}

@end
