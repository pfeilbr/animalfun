#import "BPScene.h"
#import "BPUtl.h"

@implementation BPScene

@synthesize uid=_uid;
@synthesize name=_name;
@synthesize description=_description;
@synthesize imageFilePath=_imageFilePath;
@synthesize imageSoundDescriptionFilePath=_imageSoundDescriptionFilePath;
@synthesize imageSoundEffectFilePath=_imageSoundEffectFilePath;

-(void)dealloc {
	[_imageFilePath release];
	[_imageSoundDescriptionFilePath release];
	[_imageSoundEffectFilePath release];
	[super dealloc];
}

-(id)init {
	if (self = [super init]) {
		_uid = [BPUtl getUUID];
		_imageFilePath = nil;
		_imageSoundDescriptionFilePath = nil;
		_imageSoundEffectFilePath = nil;
	}
	return self;
}

@end
