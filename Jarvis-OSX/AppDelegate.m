//
//  AppDelegate.m
//  Jarvis-OSX
//
//  Created by Kyle Yoon on 3/30/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "AppDelegate.h"
#import "JVSMenu.h"

@interface AppDelegate ()

@property (strong, nonatomic) IBOutlet JVSMenu *menu;
@property (strong, nonatomic) NSStatusItem *statusItem;
@property (strong, nonatomic) MultipeerClient *multipeer;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.menu = self.menu;
    self.statusItem.title = @"Jarvis";
    self.statusItem.highlightMode = YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
