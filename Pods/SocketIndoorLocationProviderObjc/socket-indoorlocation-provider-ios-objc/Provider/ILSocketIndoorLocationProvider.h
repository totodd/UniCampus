#import <IndoorLocation/IndoorLocation.h>

@import SocketIO;

@interface ILSocketIndoorLocationProvider : ILIndoorLocationProvider    
    
- (instancetype) initWithUrl:(NSString*) url;
    
@end
