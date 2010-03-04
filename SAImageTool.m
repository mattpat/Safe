//
//  SAImageTool.m
//  Safe
//
//  Created by Matt Patenaude on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SAImageTool.h"
#import "MPTidbits.h"


@implementation SAImageTool

#pragma mark Mounting methods
+ (NSString *)mountImageWithPath:(NSString *)path password:(NSString *)password
{
	NSTask *hdiutil = [[NSTask alloc] init];
	[hdiutil setLaunchPath:@"/usr/bin/hdiutil"];
	
	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"attach", @"-plist", path, nil];
	if (password)
	{
		[args insertObject:@"-stdinpass" atIndex:2];
		
		NSPipe *passPipe = [NSPipe pipe];
		[hdiutil setStandardInput:passPipe];
		[[passPipe fileHandleForWriting] writeData:[password dataUsingEncoding:NSUTF8StringEncoding]];
		[[passPipe fileHandleForWriting] closeFile];
	}
	
	NSPipe *result = [NSPipe pipe];
	[hdiutil setStandardOutput:result];
	[hdiutil setArguments:args];
	[hdiutil launch];
	
	NSData *resultData = [[result fileHandleForReading] readDataToEndOfFile];
	NSString *resultString = [[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding] autorelease];
	
	if ([resultString rangeOfString:@"failed"].location == NSNotFound)
	{
		NSString *err = nil;
		NSDictionary *resultDict = [NSPropertyListSerialization propertyListFromData:resultData mutabilityOption:NSPropertyListImmutable format:NULL errorDescription:&err];
		if (err)
		{
			NSLog(@"Unexpected results: %@", err);
			[err release];
			return nil;
		}
		
		NSArray *items = [resultDict objectForKey:@"system-entities"];
		for (NSDictionary *item in items)
		{
			if ([item containsKey:@"mount-point"])
				return [item objectForKey:@"mount-point"];
		}
	}
	
	return nil;
}
+ (BOOL)unmountImageWithDeviceName:(NSString *)name
{
	return NO;
}

#pragma mark Creation methods
+ (BOOL)createEmptyImageAtPath:(NSString *)path volumeName:(NSString *)volname encryption:(NSString *)encType password:(NSString *)password
{
	NSTask *hdiutil = [[NSTask alloc] init];
	[hdiutil setLaunchPath:@"/usr/bin/hdiutil"];
	
	NSMutableArray *args = [NSMutableArray arrayWithObjects:@"create", @"-plist", @"-size", @"10g", @"-type", @"SPARSE", @"-volname", volname, @"-fs", @"HFS+", path, nil];
	if (encType)
	{
		[args insertObject:@"-encryption" atIndex:8];
		[args insertObject:encType atIndex:9];
	}
	
	if (password)
	{
		[args insertObject:@"-stdinpass" atIndex:2];
		
		NSPipe *passPipe = [NSPipe pipe];
		[hdiutil setStandardInput:passPipe];
		[[passPipe fileHandleForWriting] writeData:[password dataUsingEncoding:NSUTF8StringEncoding]];
		[[passPipe fileHandleForWriting] closeFile];
	}
	
	NSPipe *result = [NSPipe pipe];
	[hdiutil setStandardOutput:result];
	[hdiutil setArguments:args];
	[hdiutil launch];
	
	NSData *resultData = [[result fileHandleForReading] readDataToEndOfFile];
	NSString *resultString = [[[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding] autorelease];
	
	if ([resultString rangeOfString:@"failed"].location == NSNotFound)
		return YES;
	
	return NO;
}

@end
