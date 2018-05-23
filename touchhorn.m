/*
 * Copyright 2018 Colin Houghton
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#import <Cocoa/Cocoa.h>

static const NSTouchBarItemIdentifier kGroupButton = @"com.colout.touchhorn.group";
static const NSTouchBarItemIdentifier buttonMute = @"com.colout.touchhorn.b1";
static const NSTouchBarItemIdentifier buttonAirhornLow = @"com.colout.touchhorn.b2";
static const NSTouchBarItemIdentifier buttonAirhornMid = @"com.colout.touchhorn.b3";
static const NSTouchBarItemIdentifier buttonAirhornHigh = @"com.colout.touchhorn.b4";
static const NSTouchBarItemIdentifier scrubberVolume = @"com.colout.touchhorn.b6";

extern void DFRElementSetControlStripPresenceForIdentifier(NSString *, BOOL);
extern void DFRSystemModalShowsCloseBoxWhenFrontMost(BOOL);

NSSound * airhorn;

@interface NSTouchBarItem ()
+ (void)addSystemTrayItem:(NSTouchBarItem *)item;
@end

@interface NSTouchBar ()
+ (void)presentSystemModalFunctionBar:(NSTouchBar *)touchBar systemTrayItemIdentifier:(NSString *)identifier;
@end

@interface AppDelegate : NSObject <NSApplicationDelegate,NSTouchBarDelegate>
@end

NSTouchBar *_groupTouchBar;

@implementation AppDelegate

- (NSTouchBar *)groupTouchBar {
    if (!_groupTouchBar) {
        NSTouchBar *groupTouchBar = [[NSTouchBar alloc] init];
        groupTouchBar.defaultItemIdentifiers = @[ buttonAirhornLow, buttonAirhornMid, buttonAirhornHigh, buttonMute, scrubberVolume ];
        groupTouchBar.delegate = self;
        _groupTouchBar = groupTouchBar;
    }
    return _groupTouchBar;
}

-(void)setGroupTouchBar: (NSTouchBar*)bar {
    _groupTouchBar = bar;
}

- (void)airhornlow:(id)sender {
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:@"set volume 1"];
    [as executeAndReturnError:nil]; 

    [airhorn stop];
    [airhorn play];
}


- (void)airhornmid:(id)sender {
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:@"set volume 3"];
    [as executeAndReturnError:nil]; 

    [airhorn stop];
    [airhorn play];
}


- (void)airhornhigh:(id)sender {
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:@"set volume 10"];
    [as executeAndReturnError:nil]; 

    [airhorn stop];
    [airhorn play];
}

- (void)mute:(id)sender {
    NSAppleScript* as = [[NSAppleScript alloc] initWithSource:@"set volume 0"];
    [as executeAndReturnError:nil]; 
}

- (void)present:(id)sender {
    [NSTouchBar presentSystemModalFunctionBar:self.groupTouchBar
                     systemTrayItemIdentifier:kGroupButton];
}

- (NSTouchBarItem *)touchBar:(NSTouchBar *)touchBar
       makeItemForIdentifier:(NSTouchBarItemIdentifier)identifier
{
    NSCustomTouchBarItem *item = nil;
    if ([identifier isEqualToString:buttonAirhornLow]) {
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:buttonAirhornLow];
        item.view = [NSButton buttonWithTitle:@"\U0001F508 \U0001F4E3" target:self action:@selector(airhornlow:)];
    }

    else if ([identifier isEqualToString:buttonAirhornMid]) {
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:buttonAirhornMid];
        item.view = [NSButton buttonWithTitle:@"\U0001F509 \U0001F4E3" target:self action:@selector(airhornmid:)];
    }

    else if ([identifier isEqualToString:buttonAirhornHigh]) {
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:buttonAirhornHigh];
        item.view = [NSButton buttonWithTitle:@"\U0001F50A \U0001F4E3" target:self action:@selector(airhornhigh:)];
    }

    else if ([identifier isEqualToString:buttonMute]) {
        item = [[NSCustomTouchBarItem alloc] initWithIdentifier:buttonMute];
        item.view = [NSButton buttonWithTitle:@"\U0001F507" target:self action:@selector(mute:)];
    }
    return item;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DFRSystemModalShowsCloseBoxWhenFrontMost(YES);
    NSCustomTouchBarItem *item = [[NSCustomTouchBarItem alloc] initWithIdentifier:kGroupButton];
    item.view = [NSButton buttonWithTitle:@"\U0001F4A9" target:self action:@selector(present:)];
    [NSTouchBarItem addSystemTrayItem:item];
    DFRElementSetControlStripPresenceForIdentifier(kGroupButton, YES);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    [_groupTouchBar release];
    _groupTouchBar = nil;
}
@end

int main(){
    airhorn = [NSSound soundNamed:@"airhorn"];
    [NSAutoreleasePool new];
    [NSApplication sharedApplication];
    AppDelegate *del = [[AppDelegate alloc] init];
    [NSApp setDelegate: del];
    [NSApp setActivationPolicy:NSApplicationActivationPolicyAccessory];
    [NSApp run];
    return 0;
}
