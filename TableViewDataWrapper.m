//
//  TableViewDataWrapper.m
//  MobilePharma
//
//  Created by Brian Pfeil on 2/16/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewDataWrapper.h"
#import "BPScene.h"


@implementation TableViewDataWrapper

@synthesize dataArray, itemNameKey, currentDataArray, filteredDataArray, savedDataArray, alphabeticSectionTitles;

-(id)initWithArray:(NSArray*)_dataArray {
	if ((self = [super init]) != NULL) {
		self.dataArray = _dataArray;
		self.currentDataArray = [NSMutableArray arrayWithArray:_dataArray];
		self.filteredDataArray = [NSMutableArray arrayWithArray:_dataArray];
		self.itemNameKey = @"Name"; // default value - can be overridden
		self.alphabeticSectionTitles =
			[NSArray arrayWithObjects:
			 @"#", @"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H",
			 @"I", @"J", @"K", @"L", @"M", @"N", @"O", @"P", @"Q",
			 @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", nil];
	}
	
	return self;
}

-(NSArray*)arrayOfFirstCharsFromArray:(NSArray*)array {
	NSMutableSet *set = [[NSMutableSet alloc] init];
	
	for(BPScene *item in array) {
		NSString *name = item.description;
		NSString *firstChar = [name substringToIndex:1];
		[set addObject:firstChar];
	}
	
	NSMutableArray *sortedFirstChars = [NSMutableArray arrayWithArray:[set allObjects]];
	[sortedFirstChars sortUsingSelector:@selector(compare:)];
	
	return sortedFirstChars;
}

-(NSDictionary*)firstCharToItemsMapFromArray:(NSArray*)array {
	
	NSMutableDictionary* firstCharToItemsMap = [[NSMutableDictionary alloc] init];
	
	for (BPScene *item in array) {
		NSString *name = item.description;
		NSString *firstChar = [name substringToIndex:1];
		
		NSMutableArray *itemsBeginWithChar = [firstCharToItemsMap valueForKey:firstChar];
		if (!itemsBeginWithChar) {
			itemsBeginWithChar = [NSMutableArray arrayWithObject:item];
			[firstCharToItemsMap setValue:itemsBeginWithChar forKey:firstChar];
		} else {
			[itemsBeginWithChar addObject:item];
		}
	}
	return firstCharToItemsMap;
}

-(NSArray*)getSectionTitles {
	return [self arrayOfFirstCharsFromArray:self.currentDataArray];
}

-(NSInteger)numberOfRowsInSection:(NSInteger)section {
	if ([self.currentDataArray count] == 0) {
		return 0;
	} else {
		NSString *c = [self.sectionTitles objectAtIndex:section];
		return [[[self firstCharToItemsMapFromArray:self.currentDataArray] valueForKey:c] count];
	}
}

-(NSString*)titleForHeaderInSection:(NSInteger)section {
	if ([self.currentDataArray count] == 0) {
		return @"";
	} else {
		return [self.sectionTitles objectAtIndex:section];
	}
}

-(NSString*)cellTextForRowAtIndexPath:(NSIndexPath*)indexPath {
	NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
	BPScene *item = [[[self firstCharToItemsMapFromArray:self.currentDataArray] valueForKey:sectionTitle] objectAtIndex:indexPath.row];
	NSString *cellText = item.description;
	return cellText;
}

-(id)objectForRowAtIndexPath:(NSIndexPath*)indexPath {
	NSString *sectionTitle = [self.sectionTitles objectAtIndex:indexPath.section];
	id obj = [[[self firstCharToItemsMapFromArray:self.currentDataArray] valueForKey:sectionTitle] objectAtIndex:indexPath.row];
	return obj;
}

@end
