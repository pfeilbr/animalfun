    //
//  BPSceneListViewController.m
//  AnimalFun
//
//  Created by Brian Pfeil on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "BPSceneListViewController.h"
#import "BPScene.h"
#import "BPSceneManager.h"
#import "BPSceneViewController.h"
#import "UIImageResizing.h"
#import "AnimalFunAppDelegate.h"

@implementation BPSceneListViewController

@synthesize tableViewDataWrapper;
@synthesize mypopoverController=_mypopoverController;

- (void)viewDidLoad {
	[super viewDidLoad];
	self.title = @"Animals";
	
	// only show close button on iPhone/iPod Touch
	if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(closeSceneListView:)];
	}
}

-(void)closeSceneListView:(id)sender {
	[self.navigationController dismissModalViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark Table Data Source Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if ([self.tableViewDataWrapper.sectionTitles count] > 0) {
		return [self.tableViewDataWrapper.sectionTitles count];
	} else {
		return 1;
	}	
}

- (NSString	 *) tableView: (UITableView *) tableView titleForHeaderInSection: (NSInteger) section {
	return [self.tableViewDataWrapper titleForHeaderInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.tableViewDataWrapper numberOfRowsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)_tableView 
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
		
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [_tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
		
	BPScene *scene = (BPScene*)[self.tableViewDataWrapper objectForRowAtIndexPath:indexPath];
	cell.textLabel.text = scene.description;
	UIImage *image = [[UIImage imageWithContentsOfFile:scene.imageFilePath] scaleToSize:CGSizeMake(40, 40)];
	cell.imageView.image = image;
	
	return cell;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)_tableView {
	return self.tableViewDataWrapper.alphabeticSectionTitles;
}

- (NSInteger)tableView:(UITableView *)_tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [self.tableViewDataWrapper.sectionTitles indexOfObject:[title lowercaseString]];
}


#pragma mark -
#pragma mark Table Delegate Methods
//- (UITableViewCellAccessoryType)tableView:(UITableView *)tableView 
//		 accessoryTypeForRowWithIndexPath:(NSIndexPath *)indexPath
//{
//	return UITableViewCellAccessoryDetailDisclosureButton;
//}

- (void)tableView:(UITableView *)_tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	// iPad
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		[self.searchDisplayController.searchBar resignFirstResponder];
		[self.mypopoverController performSelector:@selector(dismissPopoverAnimated:) withObject:self.mypopoverController];
	} else { // iPhone/iPod Touch
		[self.navigationController dismissModalViewControllerAnimated:YES];
	}

	[_tableView deselectRowAtIndexPath:indexPath animated:YES];	
	
	
	BPScene *scene = (BPScene*)[self.tableViewDataWrapper objectForRowAtIndexPath:indexPath];
	AnimalFunAppDelegate *appDelegate = (AnimalFunAppDelegate*)[UIApplication sharedApplication].delegate;
	[appDelegate.sceneViewController displaySelectedScene:scene];
}

- (UIImage*)imageByCropping:(UIImage *)imageToCrop toRect:(CGRect)rect
{
	//create a context to do our clipping in
	UIGraphicsBeginImageContext(rect.size);
	CGContextRef currentContext = UIGraphicsGetCurrentContext();
	
	//create a rect with the size we want to crop the image to
	//the X and Y here are zero so we start at the beginning of our
	//newly created context
	CGRect clippedRect = CGRectMake(0, 0, rect.size.width, rect.size.height);
	CGContextClipToRect( currentContext, clippedRect);
	
	//create a rect equivalent to the full size of the image
	//offset the rect by the X and Y we want to start the crop
	//from in order to cut off anything before them
	CGRect drawRect = CGRectMake(rect.origin.x * -1,
								 rect.origin.y * -1,
								 imageToCrop.size.width,
								 imageToCrop.size.height);
	
	//draw the image to our clipped context using our offset rect
	CGContextDrawImage(currentContext, drawRect, imageToCrop.CGImage);
	
	//pull the image from our cropped context
	UIImage *cropped = UIGraphicsGetImageFromCurrentImageContext();
	
	//pop the context to get back to the default
	UIGraphicsEndImageContext();
	
	//Note: this is autoreleased
	return cropped;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
	[self.tableViewDataWrapper.currentDataArray removeAllObjects];
	
	for (BPScene *scene in self.tableViewDataWrapper.dataArray)
	{
		NSString *itemText = scene.description;
		NSComparisonResult result = [itemText compare:searchText options:NSCaseInsensitiveSearch
												range:NSMakeRange(0, [searchText length])];
		if (result == NSOrderedSame)
		{
			[self.tableViewDataWrapper.currentDataArray addObject:scene];
		}
	}
	
	[self.tableView reloadData];}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return YES;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return YES;
}

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *)_searchBar
{
	// if a valid search was entered but the user wanted to cancel, bring back the saved list content
	if (self.searchDisplayController.searchBar.text.length > 0)
	{
		[self.tableViewDataWrapper.currentDataArray removeAllObjects];
		[self.tableViewDataWrapper.currentDataArray addObjectsFromArray:self.tableViewDataWrapper.dataArray];
	}
	
	[self.tableView reloadData];
	
	[self.searchDisplayController.searchBar resignFirstResponder];
	self.searchDisplayController.searchBar.text = @"";
}

// called when Search (in our case "Done") button pressed
- (void)searchBarSearchButtonClicked:(UISearchBar *)_searchBar
{
	[self.searchDisplayController.searchBar resignFirstResponder];
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
