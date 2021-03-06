// Application.xm
// (c) 2017 opa334

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

#import "../SafariPlus.h"

#import "../Shared.h"
#import "../Defines.h"
#import "../Classes/SPDownloadManager.h"
#import "../Classes/SPPreferenceManager.h"

%hook Application

%new
- (void)application:(UIApplication *)application
  handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)(void))completionHandler
{
  //The bare existence of this method causes background downloads to finish properly...
  //didFinishDownloadingToURL gets called, don't ask me why tho :D
  //Otherwise files would only be moved on the next app-resume
  //I presume the application only gets resumed if this method exists

  dispatch_async(dispatch_get_main_queue(),
  ^{
    completionHandler();
  });
}

//Auto switch mode on app resume
- (void)applicationWillEnterForeground:(id)arg1
{
  %orig;
  if(preferenceManager.forceModeOnResumeEnabled)
  {
    for(BrowserController* controller in browserControllers())
    {
      //Switch mode to specified mode
      [controller modeSwitchAction:preferenceManager.forceModeOnResumeFor];
    }
  }
}

//Auto close tabs when Safari gets closed
- (void)applicationWillTerminate
{
  if(preferenceManager.autoCloseTabsEnabled &&
    preferenceManager.autoCloseTabsOn == 1 /*Safari closed*/)
  {
    for(BrowserController* controller in browserControllers())
    {
      //Close all tabs for specified modes
      [controller autoCloseAction];
    }
  }

  if(preferenceManager.autoDeleteDataEnabled &&
    preferenceManager.autoDeleteDataOn == 1 /*Safari closed*/)
  {
    for(BrowserController* controller in browserControllers())
    {
      //Clear browser data
      [controller clearData];
    }
  }

  %orig;
}

//Auto close tabs when Safari gets minimized
- (void)applicationDidEnterBackground:(id)arg1
{
  if(preferenceManager.autoCloseTabsEnabled &&
    preferenceManager.autoCloseTabsOn == 2 /*Safari minimized*/)
  {
    for(BrowserController* controller in browserControllers())
    {
      //Close all tabs for specified modes
      [controller autoCloseAction];
    }
  }

  if(preferenceManager.autoDeleteDataEnabled &&
    preferenceManager.autoDeleteDataOn == 2 /*Safari closed*/)
  {
    for(BrowserController* controller in browserControllers())
    {
      //Clear browser data
      [controller clearData];
    }
  }

  %orig;
}

%end

%group iOS9Up
%hook Application

- (BOOL)application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
  BOOL orig = %orig;

  //Auto switch mode on launch
  if(preferenceManager.forceModeOnStartEnabled && !launchOptions[UIApplicationLaunchOptionsURLKey])
  {
    for(BrowserController* controller in browserControllers())
    {
      //Switch mode to specified mode
      [controller modeSwitchAction:preferenceManager.forceModeOnStartFor];
    }
  }

  if(preferenceManager.enhancedDownloadsEnabled)
  {
    downloadManager = [SPDownloadManager sharedInstance];
  }

  if(![[NSFileManager defaultManager] fileExistsAtPath:safariPlusCachePath])
  {
    [[NSFileManager defaultManager] createDirectoryAtPath:safariPlusCachePath
      withIntermediateDirectories:NO attributes:nil error:nil];
  }

  return orig;
}

%end
%end

%group iOS8
%hook Application

- (void)applicationOpenURL:(NSURL*)URL
{
  if(preferenceManager.forceModeOnExternalLinkEnabled && URL)
  {
    //Switch mode to specified mode
    [browserControllers().firstObject modeSwitchAction:preferenceManager.forceModeOnExternalLinkFor];
  }

  %orig;
}

- (void)applicationDidFinishLaunching:(id)arg1
{
  %orig;

  //Auto switch mode on launch
  if(preferenceManager.forceModeOnStartEnabled)
  {
    //Switch mode to specified mode
    [browserControllers().firstObject modeSwitchAction:preferenceManager.forceModeOnStartFor];
  }

  if(preferenceManager.enhancedDownloadsEnabled)
  {
    downloadManager = [SPDownloadManager sharedInstance];
  }

  if(![[NSFileManager defaultManager] fileExistsAtPath:safariPlusCachePath])
  {
    [[NSFileManager defaultManager] createDirectoryAtPath:safariPlusCachePath
      withIntermediateDirectories:NO attributes:nil error:nil];
  }
}

%end
%end

%ctor
{
  if(kCFCoreFoundationVersionNumber >= kCFCoreFoundationVersionNumber_iOS_9_0)
  {
    %init(iOS9Up);
  }
  else
  {
    %init(iOS8);
  }
  %init;
}
