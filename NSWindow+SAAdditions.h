//
//  NSWindow+SAAdditions.h
//  Safe
//
//  Created by Matt Patenaude on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface NSWindow (SAAdditions)

- (void)centerOnScreen:(NSScreen *)theScreen;
- (void)dialogPositionWindowOnScreen:(NSScreen *)theScreen;

@end
