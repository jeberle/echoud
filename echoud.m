#import "kit.h"
#include <sys/socket.h>
#include <sys/un.h>

const char* SOCK_PATH = "ud";

@interface XYEcho : NSObject {
  NSFileHandle* pasv_; /* listener */
  NSFileHandle* f1_;  /* incoming */
  NSFileHandle* f2_;  /* outgoing */
}
@end

@implementation XYEcho

- (void)applicationDidFinishLaunching:(NSNotification*)note {
  [self listen];
  [NSApp activateIgnoringOtherApps:NO];
}

- (NSApplicationTerminateReply)applicationWillTerminate:(NSApplication*)app {
  [self release];
  unlink(SOCK_PATH);
  return YES;
}

- (void)dealloc {
  [pasv_ release];
  [f1_ release];
  [f2_ release];
  [super dealloc];
}

- (void)listen {
  // prepare passive socket
  int sock = 0;
  if ((sock = socket(AF_UNIX, SOCK_STREAM, 0)) == -1) {
    perror("socket");
    exit(1);
  }
  unlink(SOCK_PATH);
  struct sockaddr_un addr = {0};
  addr.sun_family = AF_UNIX;
  strcpy(addr.sun_path, SOCK_PATH);
  if (bind(sock, (struct sockaddr*)&addr, sizeof(addr)) == -1) {
    perror("bind");
    exit(1);
  }
  // listen for conns
  if (listen(sock, 1) == -1) {
    perror("listen");
    exit(1);
  }
  pasv_ = [[NSFileHandle alloc] initWithFileDescriptor:sock];
  // request connect events on file handle
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(accept:) name:NSFileHandleConnectionAcceptedNotification
    object:nil];
  [pasv_ acceptConnectionInBackgroundAndNotify];
}

- (void)accept:(NSNotification*)note {
  f1_ = [[note userInfo] valueForKey:NSFileHandleNotificationFileHandleItem];
  f2_ = f1_; // conn is bidi
  [f1_ retain];
  [f2_ retain];
  [[NSNotificationCenter defaultCenter] addObserver:self
    selector:@selector(data:) name:NSFileHandleReadCompletionNotification
      object:f1_];
  [f1_ readInBackgroundAndNotify];
}

- (void)data:(NSNotification*)note {
  NSData* data = [[note userInfo] valueForKey:NSFileHandleNotificationDataItem];
  printf("data len: %lu\n", [data length]);
  if ([data length] == 0) {
    [NSApp terminate:nil];
  }
  [f1_ readInBackgroundAndNotify];
  [f2_ writeData:data];
}

@end

int main(int argc, const char *argv[]) {
  [NSApplication sharedApplication];
  [NSApp setDelegate:[XYEcho new]];
  [NSApp run];
  return 0;
}

