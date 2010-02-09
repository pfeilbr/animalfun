#import "BPSettings.h"

@implementation BPSettings

-(void)dealloc {
	[super dealloc];
}

-(id)init {
	if (self = [super init]) {
	}
	return self;
}

+(BPSettings*)sharedInstance {
	static BPSettings *sharedInstance = nil;
	if (!sharedInstance) {
		sharedInstance = [[BPSettings alloc] init];
	}
	return sharedInstance;
}

-(BOOL)shakeToChange {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"shakeToChange"];
}

-(BOOL)vibrateOnChange {
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"vibrateOnChange"];
}

-(BPSoundType)defaultSoundType {
	NSString *defaultSoundTypeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultSoundType"];
	BPSoundType soundType;
	
	if ([defaultSoundTypeName isEqualToString:@"Animal Name"]) {
		soundType = kBPSounds_AnimalName;
	} else if ([defaultSoundTypeName isEqualToString:@"Animal Sound"]) {
		soundType = kBPSounds_AnimalSound;
	} else if ([defaultSoundTypeName isEqualToString:@"Spell Name"]) {
		soundType = kBPSOunds_SpellName;
	} else if ([defaultSoundTypeName isEqualToString:@"Animal Name And Sound"]) {
		soundType = kBPSounds_AnimalNameAndSound;
	}
	
	return soundType;
}

@end
