//
//  NSWindow+SAAdditions.m
//  Safe
//
//  Created by Matt Patenaude on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "NSWindow+SAAdditions.h"


@implementation NSWindow (SAAdditions)

- (void)centerOnScreen:(NSScreen *)theScreen
{
	NSRect currentFrame = [self frame];
	NSRect visibleRect = [theScreen visibleFrame];
	[self setFrame:NSMakeRect(floor((visibleRect.size.width - currentFrame.size.width) / 2.0) + visibleRect.origin.x, floor((visibleRect.size.height - currentFrame.size.height) / 2.0) + visibleRect.origin.y, currentFrame.size.width, currentFrame.size.height) display:YES animate:NO];
}
- (void)dialogPositionWindowOnScreen:(NSScreen *)theScreen
{
	NSRect currentFrame = [self frame];
	NSRect visibleRect = [theScreen visibleFrame];
	[self setFrame:NSMakeRect(floor((visibleRect.size.width - currentFrame.size.width) / 2.0) + visibleRect.origin.x, floor((visibleRect.size.height * (2.0/3.0)) - (currentFrame.size.height / 2.0)) + visibleRect.origin.y, currentFrame.size.width, currentFrame.size.height) display:YES animate:NO];
}

@end
