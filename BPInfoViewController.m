#import "BPInfoViewController.h"

@implementation BPInfoViewController

@synthesize webView=_webView, url;

- (void)viewDidLoad {
    [super viewDidLoad];
	_webView.delegate = self;
	self.title = @"Info";
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(closeInfoView:)];
	
	NSBundle *bundle = [NSBundle mainBundle];
	NSString * urlPathString;
	if (urlPathString = [bundle pathForResource:@"info" ofType:@"html" inDirectory:@"www"]){
		[_webView  loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:urlPathString]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:20.0]];
	}
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	NSLog(@"expected:%d, got:%d", UIWebViewNavigationTypeLinkClicked, navigationType);
	if (navigationType == UIWebViewNavigationTypeLinkClicked) {
		self.url = request.URL;
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Open Link in Safari" message:[request.URL absoluteString] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK", nil];
		[alert show];
		[alert release];
		return NO;
	}	
	return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 1) {
        [[UIApplication sharedApplication] openURL:url];
	}
}

-(void)closeInfoView:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
	[_webView release];
    [super dealloc];
}


@end
