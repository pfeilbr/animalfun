#import <Foundation/Foundation.h>

@class BPScene;

@interface BPSceneManager : NSObject {
	NSArray *_scenes;
	BPScene *_currentScene;
	BPScene *_nextScene;	
	BPScene *_previousScene;	
	NSMutableArray *_sceneQueue;
	NSMutableArray *_sceneHistory;
	int _currentHistoryIndex;
}

@property(nonatomic, retain) NSArray *scenes;
@property(nonatomic, retain) BPScene *currentScene;
@property(nonatomic, retain) BPScene *nextScene;
@property(nonatomic, retain) BPScene *previousScene;

+(BPSceneManager*)defaultSceneManager;

-(void)loadScenes;
-(BPScene*)nextScene:(BPScene*)scene;
-(BPScene*)previousScene;
-(BOOL)hasPreviousScene;

@end
