//
//  MMLBubblesScene.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import "MMLBubblesScene.h"


typedef NS_ENUM(uint32_t, MMLBubblesSceneColliderType) {
    MMLBubblesSceneColliderTypeWall = 0x1 << 0,
    MMLBubblesSceneColliderTypeBubble = 0x1 << 1,
};


@interface MMLBubblesScene ()

@property (nonatomic, strong) NSMutableArray *bubbleNodes;

@end


@implementation MMLBubblesScene


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.bubbleNodes = [NSMutableArray array];
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    }
    return self;
}



- (void)setTopics:(NSArray *)topics
{
    [topics enumerateObjectsUsingBlock:^(MMLHotTopic *topic, NSUInteger idx, BOOL *stop) {
        [self addBubbleNodeWithTopic:topic];
    }];
}


- (void)didMoveToView:(SKView *)view
{
    [self setupWorld];
    [self setupBoundaries];
}



- (void)setupWorld
{
    self.physicsWorld.gravity = CGVectorMake(0.f, 1.f);
}


- (void)setupBoundaries
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    // top
    SKNode *edge = [SKNode node];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(viewWidth, 0.f)];
    edge.physicsBody.dynamic = NO;
    edge.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeWall;
    edge.position = CGPointMake(0.f, viewHeight -64.f);
    [self addChild:edge];
    
    // left
    edge = [SKNode node];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointZero toPoint:CGPointMake(0.f, viewHeight)];
    edge.physicsBody.dynamic = NO;
    edge.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeWall;
    [self addChild:edge];
    
    // right
    edge = [SKNode node];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(viewWidth, 0.f) toPoint:CGPointMake(viewWidth, viewHeight)];
    edge.physicsBody.dynamic = NO;
    edge.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeWall;
    [self addChild:edge];
}



- (void)addBubbleNodeWithTopic:(MMLHotTopic *)topic
{
    SKSpriteNode *bubbleNode = [[SKSpriteNode alloc] initWithImageNamed:@"bubble"];
    
    CGFloat size = randomValue() * 150.f;
    bubbleNode.size = CGSizeMake(size, size);
    
    bubbleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bubbleNode.size.width/2];
    bubbleNode.physicsBody.dynamic = YES;
    
    bubbleNode.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeBubble;
    bubbleNode.physicsBody.contactTestBitMask = MMLBubblesSceneColliderTypeWall | MMLBubblesSceneColliderTypeBubble;
    bubbleNode.physicsBody.collisionBitMask = MMLBubblesSceneColliderTypeWall | MMLBubblesSceneColliderTypeBubble;
    
    bubbleNode.physicsBody.allowsRotation = NO;
    bubbleNode.physicsBody.restitution = 0.8f;
    bubbleNode.physicsBody.friction = 0.f;
    bubbleNode.physicsBody.linearDamping = 0.f;
    
    bubbleNode.position = CGPointMake(randomValue() * CGRectGetWidth(self.view.frame), 0.f);
    
    [self addChild:bubbleNode];
    
    [self.bubbleNodes addObject:bubbleNode];
}


- (void)removeBubbleNode:(SKNode *)bubbleNode
{
    [bubbleNode removeFromParent];
    [self.bubbleNodes removeObject:bubbleNode];
}


CGFloat randomValue() {
    return arc4random() / (CGFloat)0x100000000;
}



@end
