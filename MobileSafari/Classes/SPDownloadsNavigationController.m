// SPDownloadsNavigationController.m
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

#import "SPDownloadsNavigationController.h"

#import "../Defines.h"
#import "../Shared.h"
#import "SPDownloadManager.h"
#import "SPDownloadsTableViewController.h"
#import "SPFileBrowserNavigationController.h"
#import "SPLocalizationManager.h"
#import "SPPreferenceManager.h"

@implementation SPDownloadsNavigationController

- (id)init
{
  self = [super init];

  //Set delegate of SPDownloadManager for communication
  downloadManager.navigationControllerDelegate = self;

  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];

  //Create recognizer with 5 second long press duration
  UILongPressGestureRecognizer* barRecognizer = [[UILongPressGestureRecognizer alloc] init];
  barRecognizer.minimumPressDuration = 5;
  [barRecognizer addTarget:self action:@selector(handleNavigationBarLongPress:)];

  //Add recognizer to navigationBar
  [self.navigationBar addGestureRecognizer:barRecognizer];
}

- (void)handleNavigationBarLongPress:(UILongPressGestureRecognizer*)sender
{
  if(sender.state == UIGestureRecognizerStateBegan)
  {
      UIAlertController* warningAlert = [UIAlertController
        alertControllerWithTitle:[localizationManager
        localizedSPStringForKey:@"WARNING"]
        message:[localizationManager localizedSPStringForKey:@"CLEAR_EVERYTHING_WARNING"]
        preferredStyle:UIAlertControllerStyleAlert];

      UIAlertAction* yesAction = [UIAlertAction actionWithTitle:[localizationManager
        localizedSPStringForKey:@"YES"]
        style:UIAlertActionStyleDestructive
        handler:^(UIAlertAction* action)
      {
        [downloadManager cancelAllDownloads];
        [downloadManager removeDownloadStorageFile];
        [downloadManager clearTempFiles];
      }];

      UIAlertAction* noAction = [UIAlertAction actionWithTitle:[localizationManager
        localizedSPStringForKey:@"NO"]
        style:UIAlertActionStyleCancel
        handler:nil];

      [warningAlert addAction:yesAction];
      [warningAlert addAction:noAction];

      [self presentViewController:warningAlert animated:YES completion:nil];
  }
}

- (NSURL*)rootPath
{
  if(preferenceManager.customDefaultPathEnabled)
  {
    //customDefaultPath enabled -> return custom path if it is valid
    NSURL* path = [NSURL fileURLWithPath:[NSString stringWithFormat:@"/var%@", preferenceManager.customDefaultPath]];
    BOOL isDir;
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:[path path] isDirectory:&isDir];
    if(isDir && exists)
    {
      return path;
    }
  }
  //customDefaultPath disabled or invalid -> return default path
  return [NSURL fileURLWithPath:defaultDownloadPath];
}

- (BOOL)shouldLoadPreviousPathElements
{
  return YES;
}

- (id)newTableViewControllerWithPath:(NSURL*)path
{
  //return instance of SPDownloadsTableViewController
  return [[SPDownloadsTableViewController alloc] initWithPath:path];
}

@end
