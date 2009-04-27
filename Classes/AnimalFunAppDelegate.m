#import "AnimalFunAppDelegate.h"
#import "BPSceneViewController.h"
#import "BPSceneManager.h"

@implementation AnimalFunAppDelegate

@synthesize window;
@synthesize sceneViewController=_sceneViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	BOOL hasBeenLaunchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunchedBefore"];
	if (!hasBeenLaunchedBefore) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunchedBefore"];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instructions" message:@"Tap the screen to change to the next animal" delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	NSString *defaultSoundTypeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultSoundType"];
	if (!defaultSoundTypeName) {
		[[NSUserDefaults standardUserDefaults] setObject:@"Animal Name" forKey:@"defaultSoundType"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shakeToChange"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibrateOnChange"];		
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    [UIApplication sharedApplication].statusBarHidden = YES;
	
	self.sceneViewController = [[BPSceneViewController alloc] initWithNibName:@"SceneView" bundle:nil];
	_sceneViewController.sceneManager = [BPSceneManager defaultSceneManager];
	[_sceneViewController.sceneManager loadScenes];
    
    [window addSubview:_sceneViewController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [_sceneViewController release];
    [window release];
    [super dealloc];
}


@end
