#import <Foundation/Foundation.h>

@interface BPScene : NSObject {
	NSString *_uid;
	NSString *_name;
	NSString *_description;
	NSString *_imageFilePath;
	NSString *_imageSoundDescriptionFilePath;	
	NSString *_imageSoundEffectFilePath;
}

@property(nonatomic, copy) NSString *uid;
@property(nonatomic, copy) NSString *name;
@property(nonatomic, copy) NSString *description;
@property(nonatomic, copy) NSString *imageFilePath;
@property(nonatomic, copy) NSString *imageSoundDescriptionFilePath;
@property(nonatomic, copy) NSString *imageSoundEffectFilePath;

- (NSComparisonResult)compare:(BPScene *)scene;
-(id)valueForKey:(NSString *)key;

@end
