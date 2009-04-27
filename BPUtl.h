#import <Foundation/Foundation.h>

@interface BPUtl : NSObject {

}

+(NSString*)getUUID;
+(id)getObjectFromJSONFile:(NSString*)path;

@end
