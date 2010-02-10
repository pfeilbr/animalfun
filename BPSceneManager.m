#import "BPSceneManager.h"
#import "BPUtl.h"
#import "BPScene.h"

NSString *sceneRelativeDirectoryPath = @"Data/Scenes";
NSString *metadataFileName = @"metadata.json";

static BPSceneManager *gDefaultSceneManager = nil;

@interface BPSceneManager(PrivateMethods)
-(BPScene*)getRandomScene;
@end

@implementation BPSceneManager

@synthesize scenes=_scenes;
@synthesize currentScene=_currentScene;
@synthesize nextScene=_nextScene;
@synthesize previousScene=_previousScene;

-(void)dealloc {
	[_scenes release];
	[_sceneQueue release];	
	[_sceneHistory release];
	[_currentScene release];
	[_nextScene release];	
	[_previousScene release];
	[super dealloc];
}

-(id)init {
	if (self = [super init]) {
		_scenes = nil;
		_sceneQueue = nil;
		_sceneHistory = [[[NSMutableArray alloc] init] retain];
		_currentHistoryIndex = -1;
		_currentScene = nil;
		_nextScene = nil;		
		_previousScene = nil;
	}
	return self;
}

+(BPSceneManager*)defaultSceneManager {
	if (!gDefaultSceneManager) {
		gDefaultSceneManager = [[[[self class] alloc] init] retain];
	}
	return gDefaultSceneManager;
}

-(void)loadScenes {
	NSString *bundlePath = [[NSBundle mainBundle] bundlePath];
	NSString *sceneDirectoryPath = [bundlePath stringByAppendingPathComponent:sceneRelativeDirectoryPath];
	NSString *metadataFilePath = [sceneDirectoryPath stringByAppendingPathComponent:metadataFileName];
	
	NSArray *scenesMetadata = (NSArray*)[BPUtl getObjectFromJSONFile:metadataFilePath];
	
	NSMutableArray *tmpScenes = [[NSMutableArray alloc] init];
	for (NSDictionary *sceneMetadata in scenesMetadata) {
		NSString *imageDescriptionText = [sceneMetadata valueForKey:@"image_description_text"];
		NSString *imageFileName = [sceneMetadata valueForKey:@"image_file_name"];
		NSString *imageSoundDescriptionFileName = [sceneMetadata valueForKey:@"image_sound_description_file_name"];
		NSString *imageSoundEffectFileName = [sceneMetadata valueForKey:@"image_sound_effect_file_name"];
		BPScene *scene = [[BPScene alloc] init];
		scene.description = imageDescriptionText;
		scene.imageFilePath = [sceneDirectoryPath stringByAppendingPathComponent:imageFileName];
		scene.imageSoundDescriptionFilePath = [sceneDirectoryPath stringByAppendingPathComponent:imageSoundDescriptionFileName];
		scene.imageSoundEffectFilePath = [sceneDirectoryPath stringByAppendingPathComponent:imageSoundEffectFileName];
		[tmpScenes addObject:scene]; 
	}
		
	_scenes = [NSArray arrayWithArray:tmpScenes];
	[_scenes retain];
	_sceneQueue = [[NSMutableArray arrayWithArray:_scenes] retain];
}

-(BPScene*)nextScene {
	BPScene *scene = nil;
	if (_currentHistoryIndex == -1 || _currentHistoryIndex == ([_sceneHistory count] - 1)) {
		scene = [self getRandomScene];
		[_sceneHistory addObject:scene];
		_currentHistoryIndex = [_sceneHistory count] - 1;
		
	} else {
		_currentHistoryIndex += 1;
		scene = [_sceneHistory objectAtIndex:_currentHistoryIndex];
	}
	
	self.currentScene = scene;
	return scene;
}

-(BOOL)hasPreviousScene {
	return _currentHistoryIndex > 0;
}

-(BPScene*)previousScene {
	BPScene *scene = nil;
	if (_currentHistoryIndex > 0) {
		_currentHistoryIndex -= 1;
		scene = [_sceneHistory objectAtIndex:_currentHistoryIndex];
		self.currentScene = scene;
	}
	return scene;
}


-(BPScene*)getRandomScene {
	// queue is empty so repopulate with all scenes
	if ([_sceneQueue count] == 0) {
		[_sceneQueue addObjectsFromArray:_scenes];
	}
	
	srandom(time(NULL));
	int sceneQueueCount = [_sceneQueue count];
	int index = random() % sceneQueueCount;
	BPScene *scene = [_sceneQueue objectAtIndex:index];
	[_sceneQueue removeObjectAtIndex:index];
	return scene;
}

@end
