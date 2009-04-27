#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "BPAudioPlayer.h"
#import "BPInfoViewController.h"

@class BPSceneManager;

@interface BPSceneViewController : UIViewController<AVAudioPlayerDelegate,UIAccelerometerDelegate,BPSpellDelegate> {
	BPSceneManager *_sceneManager;
	AVAudioPlayer *_audioPlayer;
	BPAudioPlayer *_spellTextAudioPlayer;
	UILabel *_imageTitleLabel;
	UIWebView *_imageTitleWebView;
	UIImageView *_imageView;
	UIView *_touchOverlayView;
	UIButton *_nameButton;
	UIButton *_soundButton;
	UIButton *_spellButton;
	UIButton *_infoButton;
	MPVolumeView *_volumeView;
	UIAccelerationValue _accelerometer[3];
	CFTimeInterval _lastTimeMotionDetected;
	BPInfoViewController *_infoViewController;
	BOOL _displayedFirstScene;
}

@property(nonatomic, retain) BPSceneManager *sceneManager;
@property(nonatomic, retain) UIWebView *imageTitleWebView;
@property(nonatomic, retain) IBOutlet UIButton *nameButton;
@property(nonatomic, retain) IBOutlet UIButton *soundButton;
@property(nonatomic, retain) IBOutlet UIButton *spellButton;
@property(nonatomic, retain) IBOutlet UIButton *infoButton;
@property(nonatomic, retain) MPVolumeView *volumeView;
@property(nonatomic, retain) BPInfoViewController *infoViewController;

-(IBAction)playName:(id)sender;
-(IBAction)playSound:(id)sender;
-(IBAction)playSpell:(id)sender;

-(IBAction)infoView:(id)sender;

@end
