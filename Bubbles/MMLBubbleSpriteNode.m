//
//  MMLBubbleSpriteNode.m
//  Bubbles
//
//  Created by Grant Davis on 1/28/14.
//
//

#import "MMLBubbleSpriteNode.h"


@interface MMLBubbleSpriteNode ()

@property (strong, nonatomic) SKLabelNode *labelNode;

@end


@implementation MMLBubbleSpriteNode

- (void)setTopic:(MMLHotTopic *)topic
{
    _topic = topic;
    self.labelNode.text = topic.hashtag;
}


- (SKLabelNode *)labelNode
{
    if (_labelNode == nil) {
        _labelNode = [SKLabelNode labelNodeWithFontNamed:@"HelveticaNeue"];
        _labelNode.fontSize = 12.0f;
        _labelNode.fontColor = [UIColor redColor];
        _labelNode.position = [self convertPoint:self.position fromNode:self.parent];
        _labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
        [self addChild:_labelNode];
    }
    return _labelNode;
}


@end
