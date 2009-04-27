#import <Foundation/Foundation.h>

@class BPScene;

@interface BPSceneManager : NSObject {
	NSArray *_scenes;
	BPScene *_currentScene;
	NSMutableArray *_sceneQueue;
}

@property(nonatomic, retain) NSArray *scenes;
@property(nonatomic, retain) BPScene *currentScene;

+(BPSceneManager*)defaultSceneManager;

-(void)loadScenes;
-(BPScene*)nextScene;

@end
