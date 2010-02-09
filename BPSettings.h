#import <Foundation/Foundation.h>

typedef enum tagBPSoundType {
	kBPSounds_AnimalName,
	kBPSounds_AnimalSound,
	kBPSOunds_SpellName,
	kBPSounds_AnimalNameAndSound
} BPSoundType;

@interface BPSettings : NSObject {

}

+(BPSettings*)sharedInstance;
-(BOOL)shakeToChange;
-(BOOL)vibrateOnChange;
-(BPSoundType)defaultSoundType;

@end
