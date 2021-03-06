//
//  BPSceneListViewController.h
//  AnimalFun
//
//  Created by Brian Pfeil on 2/10/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewDataWrapper.h"


@interface BPSceneListViewController : UITableViewController<UISearchDisplayDelegate, UISearchBarDelegate> {
	TableViewDataWrapper *tableViewDataWrapper;
	id _mypopoverController;
}

@property (nonatomic, retain) TableViewDataWrapper *tableViewDataWrapper;
@property (nonatomic, retain) id mypopoverController;

@end
