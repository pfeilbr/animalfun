#import "BPInfoViewController.h"

@implementation BPInfoViewController

@synthesize webView=_webView;

- (void)viewDidLoad {
    [super viewDidLoad];
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
