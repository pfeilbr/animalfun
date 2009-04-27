#import "BPAudioPlayer.h"

NSString *alphaSoundsRelativeDirectoryPath = @"Data/Sounds/Alpha";

@implementation BPAudioPlayer

@synthesize playing=_playing;
@synthesize delegate=_delegate;
@synthesize currentSpellText=_currentSpellText;
@synthesize currentSpellTextIndex=_currentSpellTextIndex;

-(void)dealloc {
	[_audioPlayer release];
	[_letterQueue release];
	[_currentSpellText release];
	[_currentSpellTextIndex release];
	[super dealloc];
}

-(id)init {
	if (self = [super init]) {
		_audioPlayer = nil;
		_playing = NO;
	}
	return self;
}

-(void)playAudioFile:(NSString*)path {
	[_audioPlayer release];
	NSError *error = nil;
	_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];	
	_audioPlayer.delegate = self;
	[_audioPlayer play];	
}

-(void)playLetter:(NSString*)letter {
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *alphaDirectoryPath = [bundlePath stringByAppendingPathComponent:alphaSoundsRelativeDirectoryPath];
	NSString *letterAudioFile = [alphaDirectoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.aiff", letter]];
	[self playAudioFile:letterAudioFile];
}

-(void)playNextLetter {
	if (_letterQueue && ([_letterQueue count] > 0)) {
		NSString *letter = [[_letterQueue objectAtIndex:0] retain];
		[_letterQueue removeObjectAtIndex:0];
		
		// ignore spaces
		if (![letter isEqualToString:@" "]) {
			SEL sel = @selector(spellText:playingLetterAtIndex:);
			if (_delegate && [_delegate respondsToSelector:sel]) {
				[_delegate performSelector:sel withObject:_currentSpellText withObject:_currentSpellTextIndex];
			}
			
			[self playLetter:letter];
		}
		self.currentSpellTextIndex = [NSNumber numberWithInt:([_currentSpellTextIndex intValue] + 1)];
	} else {
		_playing = NO;
		self.currentSpellTextIndex = [NSNumber numberWithInt:0];
		SEL sel = @selector(spellTextDidFinish);
		if (_delegate && [_delegate respondsToSelector:sel]) {
			[_delegate performSelector:sel];
		}
	}
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	[self playNextLetter];
}


-(void)spellText:(NSString*)text {
	_playing = YES;
	
	self.currentSpellText = text;
	self.currentSpellTextIndex = [NSNumber numberWithInt:0];
	
	if (!_letterQueue) {
		_letterQueue = [[NSMutableArray alloc] init];
	}
	
	for(int i = 0; i < [text length]; i++) {
		NSString *letter = [text substringWithRange:NSMakeRange(i, 1)];
		[_letterQueue addObject:letter];
	}
	
	[self playNextLetter];
}

-(BOOL)isPlaying {
	return _playing;
}

@end
