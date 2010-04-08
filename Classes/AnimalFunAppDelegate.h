#import <UIKit/UIKit.h>

@class BPSceneViewController;

@interface AnimalFunAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	BPSceneViewController *_sceneViewController;
	id _splitViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) BPSceneViewController *sceneViewController;
@property (nonatomic, retain) IBOutlet id splitViewController;

@end

