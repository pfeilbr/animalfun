//
//  TableViewDataWrapper.h
//  MobilePharma
//
//  Created by Brian Pfeil on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TableViewDataWrapper : NSObject {
	NSArray *dataArray;
	NSString *itemNameKey;
	NSMutableArray *currentDataArray;
	NSMutableArray *filteredDataArray;
	NSArray *savedDataArray;
	NSArray *alphabeticSectionTitles;
}

@property (nonatomic, retain) NSArray *dataArray;
@property (nonatomic, retain) NSString *itemNameKey;
@property (nonatomic, retain) NSMutableArray *currentDataArray;
@property (nonatomic, retain) NSMutableArray *filteredDataArray;
@property (nonatomic, retain) NSArray *savedDataArray;
@property (nonatomic, retain) NSArray *alphabeticSectionTitles;
@property(readonly, getter=getSectionTitles) NSArray *sectionTitles;

-(id)initWithArray:(NSArray*)_dataArray;
-(NSArray*)arrayOfFirstCharsFromArray:(NSArray*)array;
-(NSDictionary*)firstCharToItemsMapFromArray:(NSArray*)array;
-(NSArray*)getSectionTitles;
-(NSInteger)numberOfRowsInSection:(NSInteger)section;
-(NSString*)titleForHeaderInSection:(NSInteger)section;
-(NSString*)cellTextForRowAtIndexPath:(NSIndexPath*)indexPath;
-(id)objectForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
