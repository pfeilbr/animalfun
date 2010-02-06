#import <UIKit/UIKit.h>

@interface BPInfoViewController : UIViewController<UIWebViewDelegate> {
	UIWebView *_webView;
	NSURL *url;
}

@property(nonatomic, retain) IBOutlet UIWebView *webView;
@property(nonatomic, retain) NSURL *url;

@end
