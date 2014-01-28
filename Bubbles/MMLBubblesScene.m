//
//  MMLBubblesScene.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import "MMLBubblesScene.h"
#import "MMLBubbleSpriteNode.h"
#import "MMLAppDelegate.h"


static const CGFloat MMLBubbleVariableSize = 75.f;
static const CGFloat MMLBubbleMinSize = 50.f;

static const CGFloat MMLBubblePhysicsBodyFriction = 0.05f;
static const CGFloat MMLBubblePhysicsBodyRestitution = 0.2f;
static const CGFloat MMLBubblePhysicsBodyLinearDamping = 0.1f;

static const NSUInteger MMLBubbleTopBarrierJointCount = 20;


typedef NS_ENUM(uint32_t, MMLBubblesSceneColliderType) {
    MMLBubblesSceneColliderTypeWall = 0x1 << 1,
    MMLBubblesSceneColliderTypeBubble = 0x1 << 2,
};


@interface MMLBubblesScene ()

@property (nonatomic, strong) NSArray *bubbleTopics;
@property (nonatomic, strong) NSMutableArray *bubbleNodes;
@property (nonatomic) NSUInteger totalTweetsCount;
@property (nonatomic, strong) SKEmitterNode *backgroundBubbleEmitter;
@property (nonatomic) CGFloat horizontalGravity;
@property (nonatomic) CGFloat verticleGravity;

@end


@implementation MMLBubblesScene


#pragma mark - Setup & Teardown


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.bubbleNodes = [NSMutableArray array];
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];
    }
    return self;
}


- (void)didMoveToView:(SKView *)view
{
    [self setupAppearance];
    [self setupWorld];
    [self setupBoundaries];
    [self setupTopBarrier];
    [self setupBackgroundEmitter];
}


#pragma mark - Public


- (void)update:(NSTimeInterval)currentTime
{
    self.horizontalGravity = cosf(currentTime) * 0.2f;
    self.verticleGravity = 0.2f + sinf(currentTime) * 0.3f;
    
    NSLog(@"h: %.2f, v: %.2f", self.horizontalGravity, self.verticleGravity);
    
    self.physicsWorld.gravity = CGVectorMake(self.horizontalGravity, self.verticleGravity);
}


- (void)setTopics:(NSArray *)topics
{
    NSArray *oldTopicHashtags = [self.bubbleTopics valueForKey:@"hashtag"];
    
    NSArray *unsortedTopics = topics;
    
    self.bubbleTopics = [unsortedTopics sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO],
                                                                      [NSSortDescriptor sortDescriptorWithKey:@"hashtag" ascending:YES]]];
    
    self.totalTweetsCount = 0;
    [self.bubbleTopics enumerateObjectsUsingBlock:^(MMLHotTopic *topic, NSUInteger idx, BOOL *stop) {
        self.totalTweetsCount += topic.count;
    }];
    
    NSArray *newTopicHashtags = [self.bubbleTopics valueForKey:@"hashtag"];
    
    NSMutableArray *buttonsToRemove = [NSMutableArray array];
    
    for (NSUInteger index = 0; index < [oldTopicHashtags count]; index++) {
        NSString *hashtag = oldTopicHashtags[index];
        NSUInteger newIndex = [newTopicHashtags indexOfObject:hashtag];
        
        if (newIndex == NSNotFound) {
            [self.bubbleNodes enumerateObjectsUsingBlock:^(MMLBubbleSpriteNode *button, NSUInteger idx, BOOL *stop) {
                if ([button.topic.hashtag isEqualToString:hashtag]) {
                    [buttonsToRemove addObject:button];
                }
            }];
        }
    }
    
    [buttonsToRemove enumerateObjectsUsingBlock:^(MMLBubbleSpriteNode *button, NSUInteger idx, BOOL *stop) {
        [self removeBubbleNode:button];
    }];
    
    for (NSUInteger index = 0; index < [newTopicHashtags count]; index++) {
        
        NSString *hashtag = newTopicHashtags[index];
        NSUInteger oldIndex = [oldTopicHashtags indexOfObject:hashtag];
        
        if (oldTopicHashtags != nil && oldIndex != NSNotFound) {
            // TODO: Update existing button
        }
        else {
            // TODO: Add button
            double delayInSeconds = 0.5 * index;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self addBubbleNodeWithTopic:[self.bubbleTopics objectAtIndex:[newTopicHashtags indexOfObject:hashtag]]];
            });
        }
    }
}


#pragma mark - Private


- (void)setupAppearance
{
    self.backgroundColor = [UIColor colorWithRed:21.f/255 green:7.f/255 blue:0.f/255 alpha:1.f];
}


- (void)setupWorld
{
    self.horizontalGravity = 0.f;
    self.verticleGravity = 1.f;
    self.physicsWorld.gravity = CGVectorMake(self.horizontalGravity, self.verticleGravity);
}


- (void)setupBoundaries
{
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    // left
    SKNode *edge = [SKNode node];
    edge = [SKNode node];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(0.f, -viewHeight*2) toPoint:CGPointMake(0.f, viewHeight)];
    edge.physicsBody.dynamic = NO;
    edge.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeWall;
    [self addChild:edge];
    
    // right
    edge = [SKNode node];
    edge.physicsBody = [SKPhysicsBody bodyWithEdgeFromPoint:CGPointMake(viewWidth, -viewHeight*2) toPoint:CGPointMake(viewWidth, viewHeight)];
    edge.physicsBody.dynamic = NO;
    edge.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeWall;
    [self addChild:edge];
}


- (void)setupTopBarrier
{
    NSUInteger numberOfJoints = MMLBubbleTopBarrierJointCount;
    CGFloat jointWidth = CGRectGetWidth(self.view.frame) / numberOfJoints;
    CGFloat jointHeight = 25.f;
    
    CGFloat dx = jointWidth * 0.5f;
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
        jointNode.path = [UIBezierPath bezierPathWithRect:CGRectMake(-jointWidth * 0.5f, -jointHeight * 0.5f, jointWidth, jointHeight)].CGPath;
        [self addChild:jointNode];
        
        jointNode.position = CGPointMake(dx, dy);
        
        jointNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(jointWidth, jointHeight)];
        jointNode.physicsBody.affectedByGravity = NO;
        jointNode.physicsBody.restitution = 0.95f;
        jointNode.physicsBody.friction = 1.0f;
        jointNode.physicsBody.linearDamping = 0.95f;
        
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


- (void)setupBackgroundEmitter
{
    self.backgroundBubbleEmitter.particlePositionRange = CGVectorMake(CGRectGetWidth(self.view.frame), 0.0f);
    self.backgroundBubbleEmitter.position = CGPointMake(CGRectGetMidX(self.view.frame), -50.0f);
    [self addChild:self.backgroundBubbleEmitter];
}


- (void)addBubbleNodeWithTopic:(MMLHotTopic *)topic
{
    MMLBubbleSpriteNode *bubbleNode = [[MMLBubbleSpriteNode alloc] initWithImageNamed:@"bubble"];
    [self addChild:bubbleNode];
    bubbleNode.topic = topic;
    
    NSUInteger topicIndex = [self.bubbleTopics indexOfObject:topic];
    CGFloat percentOfMaxSize = 1.f - topicIndex / (CGFloat)self.bubbleTopics.count;
    
    CGFloat size = MMLBubbleMinSize + percentOfMaxSize * MMLBubbleVariableSize;
    bubbleNode.size = CGSizeMake(size, size);
    
    CGFloat radius = size * 0.5f;
    
    bubbleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    bubbleNode.physicsBody.dynamic = YES;
    bubbleNode.physicsBody.density = percentOfMaxSize;
    
    bubbleNode.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeBubble;
    bubbleNode.physicsBody.collisionBitMask = MMLBubblesSceneColliderTypeWall | MMLBubblesSceneColliderTypeBubble;
    
    bubbleNode.physicsBody.allowsRotation = NO;
    bubbleNode.physicsBody.restitution = MMLBubblePhysicsBodyRestitution;
    bubbleNode.physicsBody.friction = MMLBubblePhysicsBodyFriction;
    bubbleNode.physicsBody.linearDamping = MMLBubblePhysicsBodyLinearDamping;
    
    CGFloat halfViewWidth = CGRectGetWidth(self.view.frame) * 0.5f;
    CGFloat xp = halfViewWidth + (randRange(-halfViewWidth*.5, halfViewWidth*.5));
    
    bubbleNode.position = CGPointMake(xp, -radius - (MMLBubbleMinSize + MMLBubbleVariableSize) * topicIndex);
    
    [self.bubbleNodes addObject:bubbleNode];
}


- (void)removeBubbleNode:(SKNode *)bubbleNode
{
    [self.bubbleNodes removeObject:bubbleNode];
    
    
    SKAction *delayAction = [SKAction waitForDuration:randomValue()];
    [bubbleNode runAction:delayAction completion:^{
        
        bubbleNode.physicsBody.categoryBitMask = 0;
        bubbleNode.physicsBody.collisionBitMask = 0;
        
        SKAction *popAction = [SKAction scaleTo:1.2f duration:0.1f];
        popAction.timingMode = SKActionTimingEaseIn;
        
        [bubbleNode runAction:popAction
                   completion:^{
                       [bubbleNode removeFromParent];
                   }];
    }];
    
}


#pragma mark - Accessors


- (SKEmitterNode *)backgroundBubbleEmitter
{
    if (_backgroundBubbleEmitter == nil) {
        NSString *emitterPath = [[NSBundle mainBundle] pathForResource:@"SodaBubbles" ofType:@"sks"];
        _backgroundBubbleEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:emitterPath];
    }
    return _backgroundBubbleEmitter;
}


#pragma mark - Math Functions


CGFloat randomValue() {
    return arc4random() / (CGFloat)0x100000000;
}


CGFloat randRange(CGFloat low, CGFloat high)
{
	return ((CGFloat)arc4random() / (CGFloat)0x100000000 * (high-low))+low;
}


@end
