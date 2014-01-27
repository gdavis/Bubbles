//
//  MMLHotTopic.h
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import <Foundation/Foundation.h>

@interface MMLHotTopic : NSObject

@property (nonatomic, strong) NSString *hashtag;
@property (nonatomic) int32_t count;

- (id)initWithHashtag:(NSString *)hashtag count:(int32_t)count;

@end
