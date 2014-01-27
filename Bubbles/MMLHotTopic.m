//
//  MMLHotTopic.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import "MMLHotTopic.h"


@implementation MMLHotTopic


- (id)initWithHashtag:(NSString *)hashtag count:(int32_t)count
{
    if (self = [super init]) {
        self.hashtag = hashtag;
        self.count = count;
    }
    return self;
}


@end
