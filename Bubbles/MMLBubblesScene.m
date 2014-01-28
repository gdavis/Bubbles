//
//  MMLBubblesScene.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import "MMLBubblesScene.h"


typedef NS_ENUM(uint32_t, MMLBubblesSceneColliderType) {
    MMLBubblesSceneColliderTypeWall = 0x1 << 1,
    MMLBubblesSceneColliderTypeBubble = 0x1 << 2,
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
    [self setupTopBarrier];
}



- (void)setupWorld
{
    self.physicsWorld.gravity = CGVectorMake(0.f, 1.f);
}


- (void)setupBoundaries
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    // left
    SKNode *edge = [SKNode node];
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


- (void)setupTopBarrier
{
    NSUInteger numberOfJoints = 24;
    CGFloat jointWidth = CGRectGetWidth(self.view.frame) / numberOfJoints;
    CGFloat jointHeight = 25.f;
    
    CGFloat dx = 0.f;
    CGFloat dy = CGRectGetHeight(self.view.frame) - 100.f;
    
    SKNode *previousJointNode;
    SKNode *leftAnchorNode = [SKNode node];
    
    leftAnchorNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(jointWidth, jointHeight)];
    leftAnchorNode.physicsBody.dynamic = NO;
    leftAnchorNode.position = CGPointMake(dx, dy);
    [self addChild:leftAnchorNode];
    
    for (NSInteger i = 0; i < numberOfJoints; i++) {
        
        SKShapeNode *jointNode = [SKShapeNode node];
        jointNode.fillColor = [UIColor yellowColor];
        jointNode.path = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, jointWidth, jointHeight)].CGPath;
        [self addChild:jointNode];
        
        jointNode.position = CGPointMake(dx, dy);
        
        jointNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(jointWidth, jointHeight)];
        jointNode.physicsBody.affectedByGravity = NO;
        
        if (i == 0 || i+1 == numberOfJoints) {
            jointNode.physicsBody.dynamic = NO;
        }
        
        if (previousJointNode != nil) {
            
            SKPhysicsJointPin *pinJoint = [SKPhysicsJointPin jointWithBodyA:previousJointNode.physicsBody
                                                                      bodyB:jointNode.physicsBody
                                                                     anchor:jointNode.position];
            [self.physicsWorld addJoint:pinJoint];
        }
        
        previousJointNode = jointNode;
        
        dx += jointWidth;
    }
}



- (void)addBubbleNodeWithTopic:(MMLHotTopic *)topic
{
    SKSpriteNode *bubbleNode = [[SKSpriteNode alloc] initWithImageNamed:@"bubble"];
    
    CGFloat size = fmax(50.f, randomValue() * 100);
    bubbleNode.size = CGSizeMake(size, size);
    
    bubbleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:bubbleNode.size.width/2];
    bubbleNode.physicsBody.dynamic = YES;
    
    bubbleNode.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeBubble;
    bubbleNode.physicsBody.contactTestBitMask = MMLBubblesSceneColliderTypeWall | MMLBubblesSceneColliderTypeBubble;
    bubbleNode.physicsBody.collisionBitMask = MMLBubblesSceneColliderTypeWall | MMLBubblesSceneColliderTypeBubble;
    
    bubbleNode.physicsBody.allowsRotation = NO;
    bubbleNode.physicsBody.restitution = 0.8f;
    bubbleNode.physicsBody.friction = 0.1f;
    bubbleNode.physicsBody.linearDamping = 0.5f;
    
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
