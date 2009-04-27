#import <UIKit/UIKit.h>

@class BPSceneViewController;

@interface AnimalFunAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BPSceneViewController *_sceneViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) BPSceneViewController *sceneViewController;

@end

