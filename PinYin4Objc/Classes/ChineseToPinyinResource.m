//
//
//
//  Created by kimziv on 13-9-14.
//

#include "ChineseToPinyinResource.h"
#define LEFT_BRACKET @"("
#define RIGHT_BRACKET @")"
#define COMMA @","

#define kCacheKeyForUnicode2Pinyin @"cache.key.for.unicode.to.pinyin"

static inline NSString* cachePathForKey(NSString* directory, NSString* key) {
	return [directory stringByAppendingPathComponent:key];
}

@interface ChineseToPinyinResource ()
- (id<NSCoding>)cachedObjectForKey:(NSString*)key;
-(void)cacheObjec:(id<NSCoding>)obj forKey:(NSString *)key;

@end

@implementation ChineseToPinyinResource
//@synthesize unicodeToHanyuPinyinTable=_unicodeToHanyuPinyinTable;
//- (NSDictionary *)getUnicodeToHanyuPinyinTable {
//    return _unicodeToHanyuPinyinTable;
//}

- (id)init {
    if (self = [super init]) {
        _unicodeToHanyuPinyinTable = nil;
        [self initializeResource];
    }
    return self;
}

- (void)initializeResource {
    NSString* cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
	NSString* oldCachesDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"PinYinCache"] copy];
    
	if([[NSFileManager defaultManager] fileExistsAtPath:oldCachesDirectory]) {
		[[NSFileManager defaultManager] removeItemAtPath:oldCachesDirectory error:NULL];
	}
	
	_directory = [[[cachesDirectory stringByAppendingPathComponent:[[NSBundle mainBundle] bundleIdentifier]] stringByAppendingPathComponent:@"PinYinCache"] copy];
    
    NSDictionary *dataMap=(NSDictionary *)[self cachedObjectForKey:kCacheKeyForUnicode2Pinyin];
    if (dataMap) {
        self->_unicodeToHanyuPinyinTable=dataMap;
    }else{
        NSString *resourceName =[[NSBundle mainBundle] pathForResource:@"unicode_to_hanyu_pinyin" ofType:@"txt"];
        NSString *dictionaryText=[NSString stringWithContentsOfFile:resourceName encoding:NSUTF8StringEncoding error:nil];
        NSArray *lines = [dictionaryText componentsSeparatedByString:@"\r\n"];
        __block NSMutableDictionary *tempMap=[[NSMutableDictionary alloc] init];
        @autoreleasepool {
            [lines enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSArray *lineComponents=[obj componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                //NSLog(@"%@, %@",lineComponents[0],lineComponents[1]);
                [tempMap setObject:lineComponents[1] forKey:lineComponents[0]];
            }];
        }
        self->_unicodeToHanyuPinyinTable=tempMap;
        [self cacheObjec:self->_unicodeToHanyuPinyinTable forKey:kCacheKeyForUnicode2Pinyin];
    }
}

- (id<NSCoding>)cachedObjectForKey:(NSString*)key
{
    NSData *data = [NSData dataWithContentsOfFile:cachePathForKey(_directory, key) options:0 error:NULL];
    if (data) {
           return [NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return nil;
}

-(void)cacheObjec:(id<NSCoding>)obj forKey:(NSString *)key
{
    NSData* data= [NSKeyedArchiver archivedDataWithRootObject:obj];
    NSString* cachePath = cachePathForKey(_directory, key);
	dispatch_async(dispatch_get_main_queue(), ^{
        [data writeToFile:cachePath atomically:YES];
    });
}

- (NSArray *)getHanyuPinyinStringArrayWithChar:(unichar)ch {
    NSString *pinyinRecord = [self getHanyuPinyinRecordFromCharWithChar:ch];
    if (nil != pinyinRecord) {
        NSRange rangeOfLeftBracket= [pinyinRecord rangeOfString:LEFT_BRACKET];
        NSRange rangeOfRightBracket= [pinyinRecord rangeOfString:RIGHT_BRACKET];
        NSString *stripedString = [pinyinRecord substringWithRange:NSMakeRange(rangeOfLeftBracket.location+rangeOfLeftBracket.length, rangeOfRightBracket.location-rangeOfLeftBracket.location-rangeOfLeftBracket.length)];
        return [stripedString componentsSeparatedByString:COMMA];
    }
    else return nil;
}

- (BOOL)isValidRecordWithNSString:(NSString *)record {
    NSString *noneStr = @"(none0)";
    if ((nil != record) && ![record isEqual:noneStr] && [record hasPrefix:LEFT_BRACKET] && [record hasSuffix:RIGHT_BRACKET]) {
        return YES;
    }
    else return NO;
}

- (NSString *)getHanyuPinyinRecordFromCharWithChar:(unichar)ch {
    int codePointOfChar = ch;
    NSString *codepointHexStr =[[NSString stringWithFormat:@"%x", codePointOfChar] uppercaseString];
    NSString *foundRecord =[self->_unicodeToHanyuPinyinTable objectForKey:codepointHexStr];
    return [self isValidRecordWithNSString:foundRecord] ? foundRecord : nil;
}

+ (ChineseToPinyinResource *)getInstance {
    static ChineseToPinyinResource *sharedInstance=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance=[[self alloc] init];
    });
    return sharedInstance;
}

@end

