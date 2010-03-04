//
//  SAController.h
//  Safe
//
//  Created by Matt Patenaude on 3/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface SAController : NSObject {
	IBOutlet NSWindow *passwordWindow;
	IBOutlet NSSecureTextField *passwordField;
	IBOutlet NSTextField *instructionField;
	NSString *openingFile;
	
	IBOutlet NSWindow *newSafeWindow;
	IBOutlet NSTextField *newSafeNameField;
	IBOutlet NSSecureTextField *newSafePasswordField;
	IBOutlet NSSecureTextField *newSafePasswordConfirmField;
	IBOutlet NSPopUpButton *newSafeEncryptionType;
	
	BOOL hasFinishedLaunching;
	BOOL fileTriggeredLaunch;
}

// Application delegate methods
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification;

// File methods
- (IBAction)openSafe:(id)sender;
- (void)mountImage:(NSString *)filename withName:(NSString *)theName;
- (IBAction)completeMount:(id)sender;
- (IBAction)cancelMount:(id)sender;
- (IBAction)newSafe:(id)sender;
- (IBAction)completeCreate:(id)sender;
- (IBAction)cancelCreate:(id)sender;

@end
