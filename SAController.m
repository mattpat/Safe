//
//  SAController.m
//  Safe
//
//  Created by Matt Patenaude on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SAController.h"
#import "SAImageTool.h"
#import "NSWindow+SAAdditions.h"
#import "MPTidbits.h"


@implementation SAController

#pragma mark Initializers
- (id)init
{
	if (self = [super init])
	{
		hasFinishedLaunching = NO;
		fileTriggeredLaunch = NO;
	}
	return self;
}

#pragma mark Deallocator
- (void)dealloc
{
	[openingFile release];
	[super dealloc];
}

#pragma mark Application delegate methods
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
	NSFileManager *fm = [NSFileManager defaultManager];
	NSString *fileType = [[filename pathExtension] lowercaseString];
	
	if (!hasFinishedLaunching)
		fileTriggeredLaunch = YES;
	
	if ([fileType isEqualToString:@"safe"])
	{
		// Safe file
		NSString *infoPath = [filename stringByAppendingPathComponent:@"Info.plist"];
		if ([fm fileExistsAtPath:infoPath])
		{
			NSDictionary *infoDict = [NSDictionary dictionaryWithContentsOfFile:infoPath];
			if ([infoDict containsKey:@"volumeName"] && [infoDict containsKey:@"volumeFile"])
			{
				NSString *imagePath = [filename stringByAppendingPathComponent:[infoDict objectForKey:@"volumeFile"]];
				NSString *imageName = [infoDict objectForKey:@"volumeName"];
				[self mountImage:imagePath withName:imageName];
				[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
				return YES;
			}
		}
	}
	else if ([fileType isEqualToString:@"exc"])
	{
		// Exces file
		NSString *imagePath = [filename stringByAppendingPathComponent:@"Main.sparseimage"];
		NSString *nameFile = [filename stringByAppendingPathComponent:@"mountName"];
		if ([fm fileExistsAtPath:imagePath])
		{
			[self mountImage:imagePath withName:[NSString stringWithContentsOfFile:nameFile encoding:NSUTF8StringEncoding error:NULL]];
			[[NSDocumentController sharedDocumentController] noteNewRecentDocumentURL:[NSURL fileURLWithPath:filename]];
			return YES;
		}
	}
	return NO;
}
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	hasFinishedLaunching = YES;
}

#pragma mark File methods
- (IBAction)openSafe:(id)sender
{
	NSOpenPanel *openPanel = [NSOpenPanel openPanel];
	[openPanel setAllowsMultipleSelection:NO];
	[openPanel setTreatsFilePackagesAsDirectories:NO];
	
	if ([openPanel runModalForTypes:[NSArray arrayWithObjects:@"safe", @"exc", nil]])
		[self application:[NSApplication sharedApplication] openFile:[[[openPanel URLs] objectAtIndex:0] path]];
}
- (void)mountImage:(NSString *)filename withName:(NSString *)theName
{
	[instructionField setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Enter password for \"%@\"", nil), theName]];
	[passwordField setStringValue:@""];
	if (openingFile)
	{
		[openingFile release];
		openingFile = nil;
	}
	openingFile = [filename copy];
	
	[passwordWindow dialogPositionWindowOnScreen:[NSScreen mainScreen]];
	[passwordWindow makeKeyAndOrderFront:nil];
}
- (IBAction)completeMount:(id)sender
{
	[passwordWindow orderOut:nil];
	if (openingFile)
	{
		NSString *result = [SAImageTool mountImageWithPath:openingFile password:[passwordField stringValue]];
		[openingFile release];
		openingFile = nil;
		
		if (result != nil)
		{
			[[NSWorkspace sharedWorkspace] openFile:result];
			if (fileTriggeredLaunch)
				[[NSApplication sharedApplication] terminate:nil];
		}
	}
}
- (IBAction)cancelMount:(id)sender
{
	[passwordWindow orderOut:nil];
	if (fileTriggeredLaunch)
		[[NSApplication sharedApplication] terminate:nil];
}
- (IBAction)newSafe:(id)sender
{
	[newSafeNameField setStringValue:@""];
	[newSafeEncryptionType selectItemWithTag:1];
	[newSafePasswordField setStringValue:@""];
	[newSafePasswordConfirmField setStringValue:@""];
	
	[newSafeWindow makeFirstResponder:newSafeNameField];
	[newSafeWindow dialogPositionWindowOnScreen:[NSScreen mainScreen]];
	[newSafeWindow makeKeyAndOrderFront:nil];
}
- (IBAction)completeCreate:(id)sender
{
	if (![[newSafePasswordField stringValue] isEqualToString:[newSafePasswordConfirmField stringValue]])
		return;
	
	[newSafeWindow orderOut:nil];
	
	NSSavePanel *savePanel = [NSSavePanel savePanel];
	[savePanel setAllowedFileTypes:[NSArray arrayWithObject:@"safe"]];
	[savePanel setAllowsOtherFileTypes:NO];
	[savePanel setTreatsFilePackagesAsDirectories:NO];
	[savePanel setCanSelectHiddenExtension:YES];
	[savePanel setExtensionHidden:YES];
	
	if ([savePanel runModalForDirectory:nil file:[NSString stringWithFormat:@"%@.safe", [newSafeNameField stringValue]]])
	{
		NSFileManager *fm = [NSFileManager defaultManager];
		
		NSString *path = [[savePanel URL] path];
		NSString *infoPath = [path stringByAppendingPathComponent:@"Info.plist"];
		NSString *imagePath = [path stringByAppendingPathComponent:@"Contents.sparseimage"];
		
		NSString *encType = nil;
		switch ([newSafeEncryptionType selectedTag])
		{
			case 0:
				encType = @"AES-128";
				break;
			case 1:
				encType = @"AES-256";
				break;
			default:
				break;
		}
		
		if ([fm fileExistsAtPath:path])
		{
			NSError *err;
			if (![fm removeItemAtPath:path error:&err])
				return;
		}
		
		[fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:[savePanel isExtensionHidden]] forKey:NSFileExtensionHidden] error:NULL];
		
		NSDictionary *infoDict = [NSDictionary dictionaryWithObjectsAndKeys:[newSafeNameField stringValue], @"volumeName", [imagePath lastPathComponent], @"volumeFile", nil];
		[infoDict writeToFile:infoPath atomically:YES];
		
		if ([SAImageTool createEmptyImageAtPath:imagePath volumeName:[newSafeNameField stringValue] encryption:encType password:[newSafePasswordField stringValue]])
		{
			NSString *result = [SAImageTool mountImageWithPath:imagePath password:[newSafePasswordField stringValue]];
			if (result != nil)
				[[NSWorkspace sharedWorkspace] openFile:result];
		}
	}
}
- (IBAction)cancelCreate:(id)sender
{
	[newSafeWindow orderOut:nil];
}

@end
