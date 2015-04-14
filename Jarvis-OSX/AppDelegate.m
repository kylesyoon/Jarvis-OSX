//
//  AppDelegate.m
//  Jarvis-OSX
//
//  Created by Kyle Yoon on 3/30/15.
//  Copyright (c) 2015 Kyle Yoon. All rights reserved.
//

#import "AppDelegate.h"
#import "JARObjectController.h"

@interface AppDelegate()

@property (strong, nonatomic) NSStatusItem *statusItem;
@property (weak) IBOutlet NSMenu *menu;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.menu = self.menu;
    self.statusItem.title = @"Jarvis";
    self.statusItem.highlightMode = YES;
    JARObjectController *objectController = [[JARObjectController alloc] init];
    objectController.menu = self.menu;
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    
}

@end
