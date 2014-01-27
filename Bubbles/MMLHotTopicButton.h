//
//  MMLHotTopicButton.h
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import <UIKit/UIKit.h>
#import "MMLHotTopic.h"


@interface MMLHotTopicButton : UIButton

@property (nonatomic, strong) MMLHotTopic *topic;
@property (nonatomic) CGPoint targetCenter;

@end
