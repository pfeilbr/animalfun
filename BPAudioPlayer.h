#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol BPSpellDelegate
@optional
-(void)spellTextDidFinish;
-(void)spellText:(NSString*)text playingLetterAtIndex:(NSNumber*)index; 
@end

@interface BPAudioPlayer : NSObject<AVAudioPlayerDelegate> {
	AVAudioPlayer *_audioPlayer;
	NSMutableArray *_letterQueue;
	NSString *_currentSpellText;
	NSNumber *_currentSpellTextIndex;
	id _delegate;
	BOOL _playing;
}

@property(nonatomic, assign) id delegate;
@property(getter=isPlaying) BOOL playing;
@property(nonatomic, copy) NSString *currentSpellText;
@property(nonatomic, copy) NSNumber *currentSpellTextIndex;

-(void)spellText:(NSString*)text;
-(BOOL)isPlaying;

@end
