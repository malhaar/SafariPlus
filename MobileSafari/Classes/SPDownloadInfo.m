// SPDownloadInfo.m
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

#import "SPDownloadInfo.h"

#import "SPDownload.h"

@implementation SPDownloadInfo

- (SPDownloadInfo*)initWithRequest:(NSURLRequest*)request
{
  self = [super init];

  _request = request;

  return self;
}

- (SPDownloadInfo*)initWithImage:(UIImage*)image
{
  self = [super init];

  _image = image;

  return self;
}

- (SPDownloadInfo*)initWithDownload:(SPDownload*)download
{
  self = [super init];

  _request = download.request;
  _filesize = download.filesize;
  _filename = download.filename;
  _targetPath = download.targetPath;

  return self;
}

- (NSURL*)pathURL
{
  return [_targetPath URLByAppendingPathComponent:_filename];
}

- (NSString*)pathString
{
  return [self pathURL].path;
}

- (BOOL)fileExists
{
  return [[NSFileManager defaultManager] fileExistsAtPath:[self pathString]];
}

- (void)removeExistingFile
{
  if([self fileExists])
  {
    [[NSFileManager defaultManager] removeItemAtPath:[self pathString] error:nil];
  }
}
@end
