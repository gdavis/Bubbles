//
//  MMLHotTopicBubbleBehavior.h
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import <UIKit/UIKit.h>

@interface MMLHotTopicBubbleBehavior : UIDynamicBehavior

- (instancetype)initWithItems:(NSArray *)items;

- (void)addItem:(id <UIDynamicItem>)item;
- (void)removeItem:(id <UIDynamicItem>)item;

@end
