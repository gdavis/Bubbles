//
//  MMLHotTopicBubbleBehavior.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import "MMLHotTopicBubbleBehavior.h"

const CGFloat MMLHotTopicBubbleElasticity = 0.9f;
const CGFloat MMLHotTopicBubbleFriction = 0.05f;
const CGFloat MMLHotTopicBubbleResistance = 0.05f;

const NSTimeInterval MMLHotTopicBubblePushUpdateInterval = 1.0f;


#define ARC4RANDOM_MAX      0x100000000


@interface MMLHotTopicBubbleBehavior ()

@property (nonatomic, strong) UIDynamicItemBehavior *itemBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;

@property (nonatomic, strong) NSTimer *pushTimer;

@end


@implementation MMLHotTopicBubbleBehavior

- (instancetype)initWithItems:(NSArray *)items
{
    if (self = [self init]) {
        
        [items enumerateObjectsUsingBlock:^(id <UIDynamicItem> item, NSUInteger idx, BOOL *stop) {
            [self.itemBehavior addItem:item];
            [self.pushBehavior addItem:item];
        }];
    }
    return self;
}


- (id)init
{
    if (self = [super init]) {
        
        [self addChildBehavior:self.itemBehavior];
        [self addChildBehavior:self.pushBehavior];
        
        [self startPushTimer];
    }
    return self;
}


#pragma mark - Public


- (void)addItem:(id <UIDynamicItem>)item
{
    [self.itemBehavior addItem:item];
    [self.pushBehavior addItem:item];
}


- (void)removeItem:(id <UIDynamicItem>)item
{
    [self.itemBehavior removeItem:item];
    [self.pushBehavior removeItem:item];
}


#pragma mark - Private


- (void)startPushTimer
{
    NSTimeInterval interval = [self randomValue] * MMLHotTopicBubblePushUpdateInterval;
    self.pushTimer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                      target:self
                                                    selector:@selector(pushTimerTick)
                                                    userInfo:nil
                                                     repeats:NO];
}


- (void)stopPushTimer
{
    if ([self.pushTimer isValid]) {
        [self.pushTimer invalidate];
        self.pushTimer = nil;
    }
}


- (void)pushTimerTick
{
    CGFloat angle = [self randomValue] * M_PI;
    CGFloat magnitude = ([self randomValue] * 1.f) + 0.1f;
    [self.pushBehavior setAngle:angle magnitude:magnitude];
    [self startPushTimer];
}


- (CGFloat)randomValue
{
    return (arc4random() / (CGFloat)ARC4RANDOM_MAX);
}


#pragma mark - Accessors

- (UIDynamicItemBehavior *)itemBehavior
{
    if (_itemBehavior == nil) {
        _itemBehavior = [[UIDynamicItemBehavior alloc] init];
        _itemBehavior.allowsRotation = NO;
        _itemBehavior.elasticity = MMLHotTopicBubbleElasticity;
        _itemBehavior.friction = MMLHotTopicBubbleFriction;
        _itemBehavior.resistance = MMLHotTopicBubbleResistance;
    }
    return _itemBehavior;
}


- (UIPushBehavior *)pushBehavior
{
    if (_pushBehavior == nil) {
        _pushBehavior = [[UIPushBehavior alloc] init];
    }
    return _pushBehavior;
}

@end
