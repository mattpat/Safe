//
//  SAImageTool.h
//  Safe
//
//  Created by Matt Patenaude on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SAImageTool : NSObject {

}

// Mounting methods
+ (NSString *)mountImageWithPath:(NSString *)path password:(NSString *)password;
+ (BOOL)unmountImageWithDeviceName:(NSString *)name;

// Creation methods
+ (BOOL)createEmptyImageAtPath:(NSString *)path volumeName:(NSString *)volname encryption:(NSString *)encType password:(NSString *)password;

@end
