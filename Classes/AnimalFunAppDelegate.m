#import "AnimalFunAppDelegate.h"
#import "BPSceneViewController.h"
#import "BPSceneManager.h"

@implementation AnimalFunAppDelegate

@synthesize window;
@synthesize sceneViewController=_sceneViewController;
@synthesize splitViewController=_splitViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	BOOL hasBeenLaunchedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasBeenLaunchedBefore"];
	if (!hasBeenLaunchedBefore) {
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasBeenLaunchedBefore"];
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Instructions" message:@"Tap the screen to change to the next animal and use the arrows to naviagte back and forth." delegate:nil cancelButtonTitle:@"Close" otherButtonTitles:nil];
		[alertView show];
		[alertView release];
	}
	
	NSString *defaultSoundTypeName = [[NSUserDefaults standardUserDefaults] stringForKey:@"defaultSoundType"];
	if (!defaultSoundTypeName) {
		[[NSUserDefaults standardUserDefaults] setObject:@"Animal Name And Sound" forKey:@"defaultSoundType"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"shakeToChange"];
		[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"vibrateOnChange"];		
	}
	
	[[NSUserDefaults standardUserDefaults] synchronize];
	
    [UIApplication sharedApplication].statusBarHidden = YES;
	
	self.sceneViewController = [[BPSceneViewController alloc] initWithNibName:@"SceneView" bundle:nil];
	_sceneViewController.sceneManager = [BPSceneManager defaultSceneManager];
	[_sceneViewController.sceneManager loadScenes];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		BPSceneListViewController *sceneListViewController = [[BPSceneListViewController alloc] initWithNibName:@"SceneListView" bundle:nil];
		sceneListViewController.tableViewDataWrapper = [[TableViewDataWrapper alloc] initWithArray:[BPSceneManager defaultSceneManager].scenes];		
		[sceneListViewController retain];
		
		UINavigationController *navController = [[UINavigationController alloc] init];
		[navController pushViewController:sceneListViewController animated:NO];		
		
		Class splitVCClass = NSClassFromString(@"UISplitViewController");
		self.splitViewController = (id)[[splitVCClass alloc] init];
		[self.splitViewController performSelector:@selector(setDelegate:) withObject:self.sceneViewController];
		[self.splitViewController setViewControllers:[NSArray arrayWithObjects:navController, self.sceneViewController, nil]];
		[window addSubview:[self.splitViewController view]];
	}
	else
	{
		[window addSubview:_sceneViewController.view];
	}
	
    
    
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [_sceneViewController release];
    [window release];
    [super dealloc];
}


@end
