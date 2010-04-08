#import "BPSceneViewController.h"
#import "BPSceneManager.h"
#import "BPScene.h"
#import "BPSceneListViewController.h"
#import "BPSettings.h"
#include <AudioToolbox/AudioToolbox.h>

// accelerometer constants
#define kAccelerometerFrequency      25 //Hz
#define kFilteringFactor             0.1
#define kMinEraseInterval            0.5
#define kEraseAccelerationThreshold  2.0

// color
#define kColorBlueGrey [UIColor colorWithRed:105/255.0f green:123/255.0f blue:160/255.0f alpha:1]

@interface BPSceneViewController(PrivateMethods)
-(void)displayNextScene;
-(void)renderNextScene;
-(void)renderScene:(BPScene*)scene;
-(NSString*)getFormattedHTMLTitle:(NSString*)title;
-(void)setFormattedHTMLTitle:(NSString*)html;
-(void)playAudio:(NSString*)audioFilePath;
-(void)spellText:(NSString*)text;
-(void)updateUI;
-(BOOL)isAudioPlaying;
-(void)enableAudioButtons:(BOOL)enabled;
-(void)centerImageView;
@end

@implementation BPSceneViewController

@synthesize sceneManager=_sceneManager;
@synthesize imageTitleWebView=_imageTitleWebView;
@synthesize touchOverlayView=_touchOverlayView;
@synthesize toolbar=_toolbar;
@synthesize nameButton=_nameButton;
@synthesize soundButton=_soundButton;
@synthesize spellButton=_spellButton;
@synthesize tocButton=_tocButton;
@synthesize infoButton=_infoButton;
@synthesize nextButton=_nextButton;
@synthesize previousButton=_previousButton;
@synthesize volumeView=_volumeView;
@synthesize sceneListViewController=_sceneListViewController;
@synthesize infoViewController=_infoViewController;
@synthesize mypopoverController=_mypopoverController;

- (id)init {
	if (self = [super init]) {
		_sceneManager = nil;
		_imageTitleWebView = nil;
		_audioPlayer = nil;
		_spellTextAudioPlayer = nil;
		_imageTitleLabel = nil;
		_imageView = nil;
		_touchOverlayView = nil;
		_nameButton = nil;
		_soundButton = nil;
		_spellButton = nil;
		_infoButton = nil;
		_previousButton = nil;
		_volumeView = nil;
		_infoViewController = nil;
		_mypopoverController = nil;
		
		_displayedFirstScene = NO;
		_playSoundNext = NO;
		_sceneTransitionInProgress = NO;
		
		self.view.autoresizesSubviews = YES;
		self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
	}
	return self;
}

- (void)awakeFromNib {
	[self init];
}

- (void)loadView {
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
		
	// image view
	_imageView = [[UIImageView alloc] init];
	[self.view addSubview:_imageView];
	
	CGRect volumeViewFrame;
	
	// sound/volume view
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// The device is an iPad running iPhone 3.2 or later.
	}
	else
	{
		// iPhone/iPod Touch
		volumeViewFrame = CGRectMake(40, 400, 240, 30);
	}

	self.volumeView = [[MPVolumeView alloc] initWithFrame:volumeViewFrame];
	[self.view addSubview:_volumeView];	
				
	// shake to change functionality
	[[UIAccelerometer sharedAccelerometer] setUpdateInterval:(1.0 / kAccelerometerFrequency)];
	[UIAccelerometer sharedAccelerometer].delegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];

	// render 1st scene
	if (!_displayedFirstScene) {
		[self renderNextScene];
		_displayedFirstScene = YES;
	}
}

-(void)updateUI {
	[self centerImageView];
	_previousButton.enabled = ![_sceneManager hasPreviousScene];
}

-(void)centerImageView {
	CGPoint imageViewCenterPoint;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		// portrait
		if (self.interfaceOrientation ==  UIInterfaceOrientationPortrait || self.interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
			imageViewCenterPoint = CGPointMake(384, 512);
		} else { //landscape
			imageViewCenterPoint = CGPointMake(352, 384);
		}			
	} else {
		imageViewCenterPoint = self.view.center;
	}
	
	_imageView.center = imageViewCenterPoint;
	[self.view setNeedsDisplay];
	[self.view setNeedsLayout];	
}

-(IBAction)displayNextScene:(id)sender {
	if (!_sceneTransitionInProgress && ![self isAudioPlaying]) {
		_sceneTransitionInProgress = YES;
		[self renderNextScene];
	}	
}

-(void)renderNextScene {
	BPScene *scene = [_sceneManager nextScene:nil];
	[self renderScene:scene];
}


-(IBAction)displayPreviousScene:(id)sender {
	if (!_sceneTransitionInProgress && ![self isAudioPlaying]) {
		_sceneTransitionInProgress = YES;
		[self renderPreviousScene];
	}	
}

-(void)renderPreviousScene {
	BPScene *scene = [_sceneManager previousScene];
	[self renderScene:scene];
}

-(void)displaySelectedScene:(BPScene*)_scene {
	BPScene *scene = [[BPSceneManager defaultSceneManager] nextScene:_scene];
	[self renderScene:scene];
}

- (void)renderScene:(BPScene*)scene {
	[UIView beginAnimations:@"fadeOutSceneAnimation" context:scene];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeOutDidStop:context:)];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	
	_imageView.alpha = 0;
	[self setFormattedHTMLTitle:@""];
	[UIView commitAnimations];	

}

- (void)fadeOutDidStop:(NSString *)animationID context:(void *)context {
	
	BPScene* scene = _sceneManager.currentScene;
			
	CGRect imageViewFrame;
	UIImage *image;
	
	// iPad
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		image = [UIImage imageWithContentsOfFile:scene.imageFilePath];
		imageViewFrame = CGRectMake(0, 0, image.size.width * 2, image.size.height * 2);
		image = [image scaleToSize:imageViewFrame.size];
	}
	else // iPhone/iPod Touch
	{
		image = [UIImage imageWithContentsOfFile:scene.imageFilePath];
		imageViewFrame = CGRectMake(0, 0, image.size.width, image.size.height);
	}
	
	_imageView.frame = imageViewFrame;
	_imageView.image = image;	
	[self centerImageView];
	
	[UIView beginAnimations:@"fadeInSceneAnimation" context:scene];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(fadeInDidStop:context:)];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];	
	_imageView.alpha = 1;
	
	NSString *imageTitleHTML = [self getFormattedHTMLTitle:[scene.description uppercaseString]];
	[self setFormattedHTMLTitle:imageTitleHTML];
	
	[UIView commitAnimations];	
}

- (void)fadeInDidStop:(NSString *)animationID context:(void *)context {
		
	if ([[BPSettings sharedInstance] vibrateOnChange]) {
		AudioServicesPlaySystemSound (kSystemSoundID_Vibrate);
	}
	
	BPSoundType soundType = [[BPSettings sharedInstance] defaultSoundType];
	switch (soundType) {
		case kBPSounds_AnimalName:
			[self playName:self];
			break;
			
		case kBPSounds_AnimalSound:
			[self playSound:self];
			break;
			
		case kBPSOunds_SpellName:
			[self playSpell:self];
			break;
			
		case kBPSounds_AnimalNameAndSound:
			[self playNameAndSound:self];
			break;
			
			
		default:
			break;
	}
	
	[self updateUI];
	_sceneTransitionInProgress = NO;
}

-(NSString*)getFormattedHTMLTitle:(NSString*)title {
	NSString *titleHTML = [NSString stringWithFormat:@"<div style='color: #6D84A2; text-align: center; font-size: 18pt; font-weight: bold'>%@</div>", title];
	return titleHTML;
}

-(void)setFormattedHTMLTitle:(NSString*)html {
	[_imageTitleWebView loadHTMLString:html baseURL:nil];
}

-(void)playAudio:(NSString*)audioFilePath {
	// stop any audio playing (only 1 sound at a time)
	if (_audioPlayer && [_audioPlayer isPlaying]) {
		[_audioPlayer stop];
	}
	
	[_audioPlayer release];
	
	NSError *error = nil;
	_audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:audioFilePath] error:&error];
		
	_audioPlayer.delegate = self;
	[_audioPlayer prepareToPlay];
	[_audioPlayer play];
}

-(void)spellText:(NSString*)text {
	if (!_spellTextAudioPlayer) {
		_spellTextAudioPlayer = [[BPAudioPlayer alloc] init];
		_spellTextAudioPlayer.delegate = self;
	}
	
	[_spellTextAudioPlayer spellText:text];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
	if (_playSoundNext) {
		[self playSound:self];
		_playSoundNext = NO;
	} else {
		[self enableAudioButtons:YES];
	}
	
}

-(void)spellTextDidFinish {
	BPScene *scene = [_sceneManager currentScene];
	NSString *imageTitleHTML = [self getFormattedHTMLTitle:[scene.description uppercaseString]];
	[self setFormattedHTMLTitle:imageTitleHTML];
	
	[self enableAudioButtons:YES];
}

-(void)spellText:(NSString*)text playingLetterAtIndex:(NSNumber*)index {
	int idx = [index intValue];
	NSString *uppercaseText = [text uppercaseString];
	NSString *characterAsString = [uppercaseText substringWithRange:NSMakeRange(idx, 1)];
	NSString *charAsFormattedHTMLString = [NSString stringWithFormat:@"<span style='color: red'>%@</span>", characterAsString];
	NSString *unwrappedHTMLTitle = [uppercaseText stringByReplacingCharactersInRange:NSMakeRange(idx, 1) withString:charAsFormattedHTMLString];
	NSString *formattedHTMLTitle = [self getFormattedHTMLTitle:unwrappedHTMLTitle];
	[self setFormattedHTMLTitle:formattedHTMLTitle];
}

-(IBAction)playName:(id)sender {
	[self enableAudioButtons:NO];
	BPScene *scene = [_sceneManager currentScene];
	[self playAudio:scene.imageSoundDescriptionFilePath];
}

-(IBAction)playSound:(id)sender {
	[self enableAudioButtons:NO];	
	BPScene *scene = [_sceneManager currentScene];
	[self playAudio:scene.imageSoundEffectFilePath];
}

-(IBAction)playSpell:(id)sender {
	[self enableAudioButtons:NO];	
	BPScene *scene = [_sceneManager currentScene];
	[self spellText:scene.description];
}

-(IBAction)playNameAndSound:(id)sender {
	[self enableAudioButtons:NO];
	BPScene *scene = [_sceneManager currentScene];
	_playSoundNext = YES;
	[self playAudio:scene.imageSoundDescriptionFilePath];
}


-(void)enableAudioButtons:(BOOL)enabled {
	_nameButton.enabled = enabled;
	_soundButton.enabled = enabled;
	_spellButton.enabled = enabled;
	_tocButton.enabled = enabled;
	_infoButton.enabled = enabled;
	_nextButton.enabled = enabled;
	_previousButton.enabled = enabled;
	
	if (enabled) {
		_previousButton.enabled = [_sceneManager hasPreviousScene];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
	{
		return YES;
	}
	else
	{
		return (interfaceOrientation == UIInterfaceOrientationPortrait);
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self updateUI];
}

#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {

	// if toc button exists, exit right away
	if ([[self.toolbar items] indexOfObject:_tocButton] != NSNotFound) {
		return;
	}		
    
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
	[items addObject:_tocButton];
	
	UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
	[items addObject:spacer];
	
    [self.toolbar setItems:items animated:YES];
    [items release];
    self.mypopoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
	
	// if toc button doesn't exists, exit right away
	if ([[self.toolbar items] indexOfObject:_tocButton] == NSNotFound) {
		return;
	}	
	
    NSMutableArray *items = [[self.toolbar items] mutableCopy];

	// remove the last 2 items (spacer button and toc button)
	[items removeLastObject];
	[items removeLastObject];
    [self.toolbar setItems:items animated:YES];
    [items release];
	[self.mypopoverController dismissPopoverAnimated:YES];
    self.mypopoverController = nil;
}


-(BOOL)isAudioPlaying {
	return (_audioPlayer && _audioPlayer.playing) || (_spellTextAudioPlayer && _spellTextAudioPlayer.playing);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	UITouch *touch = [touches anyObject];
	if ([_touchOverlayView pointInside:[touch locationInView:_touchOverlayView] withEvent:nil]) {
	//if (touch.view == _touchOverlayView) {
		[self displayNextScene:self];
	//}
	}
}

-(void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration {
    UIAccelerationValue length, x, y, z;
    
    _accelerometer[0] = acceleration.x * kFilteringFactor + _accelerometer[0] * (1.0 - kFilteringFactor);
    _accelerometer[1] = acceleration.y * kFilteringFactor + _accelerometer[1] * (1.0 - kFilteringFactor);
    _accelerometer[2] = acceleration.z * kFilteringFactor + _accelerometer[2] * (1.0 - kFilteringFactor);
    
    x = acceleration.x - _accelerometer[0];
    y = acceleration.y - _accelerometer[0];
    z = acceleration.z - _accelerometer[0];
    
    length = sqrt(x * x + y * y + z * z);
    
    if((length >= kEraseAccelerationThreshold) && (CFAbsoluteTimeGetCurrent() > _lastTimeMotionDetected + kMinEraseInterval)) {
        // action(s) to take when shaken
		if ([[BPSettings sharedInstance] shakeToChange]) {
			[self displayNextScene:self];
		}	
    }
}

-(IBAction)sceneListView:(id)sender {
	if (!_sceneListViewController) {
		self.sceneListViewController = [[BPSceneListViewController alloc] initWithNibName:@"SceneListView" bundle:nil];
		self.sceneListViewController.tableViewDataWrapper = [[TableViewDataWrapper alloc] initWithArray:[BPSceneManager defaultSceneManager].scenes];
	}
	UINavigationController *navController = [[UINavigationController alloc] init];
	[navController pushViewController:_sceneListViewController animated:NO];
	
	// iPad
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		// if the popover is showing, just dismiss it
		if (self.mypopoverController != nil && [self.mypopoverController isPopoverVisible]) {
			[self.mypopoverController dismissPopoverAnimated:YES];
			return;
		}
		
		Class uiPopoverControllerClass = NSClassFromString(@"UIPopoverController");
		self.mypopoverController = (id)[[uiPopoverControllerClass alloc] initWithContentViewController:navController];
		self.sceneListViewController.mypopoverController = self.mypopoverController;
		[self.mypopoverController presentPopoverFromBarButtonItem:sender
									   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];		
	} else { // iPhone/iPod Touch
		[self presentModalViewController:navController animated:YES];
	}
	
	
	[navController release];	
}

-(IBAction)infoView:(id)sender {
	if (!_infoViewController) {
		self.infoViewController = [[BPInfoViewController alloc] initWithNibName:@"InfoView" bundle:nil];
	}
	
	UINavigationController *navController = [[UINavigationController alloc] init];
	[navController pushViewController:_infoViewController animated:NO];
	[self presentModalViewController:navController animated:YES];
	[navController release];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[_sceneManager release];
	[_imageTitleWebView release];
	[_imageTitleLabel release];
	[_imageView release];
	[_touchOverlayView release];
	[_audioPlayer release];
	[_spellTextAudioPlayer release];
	[_nameButton release];
	[_soundButton release];
	[_spellButton release];
	[_infoButton release];
	[_volumeView release];
	[_infoViewController release];
	[_mypopoverController release];
    [super dealloc];
}


@end
