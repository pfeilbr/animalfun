#import "BPUtl.h"
#import "JSON.h"

@implementation BPUtl

+(NSString*)getUUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString*)string autorelease];
}

+(id)getObjectFromJSONFile:(NSString*)path {
	NSError *error;
	NSString *fileContents = [NSString stringWithContentsOfFile:path encoding:NSASCIIStringEncoding error:&error];
	return [fileContents JSONValue];
}

@end
