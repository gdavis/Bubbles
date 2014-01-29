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

static const BOOL MMLBubbleShowDebugOutlines = NO;

static const CGFloat MMLBubbleVariableSize = 75.f;
static const CGFloat MMLBubbleMinSize = 50.f;

static const CGFloat MMLBubblePhysicsBodyFriction = 0.05f;
static const CGFloat MMLBubblePhysicsBodyRestitution = 0.2f;
static const CGFloat MMLBubblePhysicsBodyLinearDamping = 0.1f;

static const CGFloat MMLBubbleBarrierJointPhysicsBodyFriction = 1.0f;
static const CGFloat MMLBubbleBarrierJointPhysicsBodyRestitution = 0.95f;
static const CGFloat MMLBubbleBarrierJointPhysicsBodyLinearDamping = 0.95f;

static const CGFloat MMLBubbleMaxAlpha = 0.98f;
static const CGFloat MMLBubbleMinAlpha = 0.85f;

static const NSUInteger MMLBubbleTopBarrierJointCount = 20;
static const CGFloat MMLBubbleTopBarrierJointHeight = 25.0f;
static const CGFloat MMLBubbleHexagonAspectRatio = 0.875f;

static NSString *MMLBubbleImageName = @"hexagon.png";


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
@property (nonatomic, strong) SKTexture *bubbleTexture;

@end


@implementation MMLBubblesScene


#pragma mark - Setup & Teardown


-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        
        self.bubbleNodes = [NSMutableArray array];
        self.bubbleTexture = [SKTexture textureWithImageNamed:MMLBubbleImageName];
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
            double delayInSeconds = 0.1 * index;
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
    self.horizontalGravity = 0.0f;
    self.verticleGravity = 1.0f;
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
    CGFloat jointHeight = MMLBubbleTopBarrierJointHeight;
    
    CGFloat dx = jointWidth * 0.5f;
    CGFloat dy = CGRectGetHeight(self.view.frame) - 64.0f; // -64.0f to place below nav bar
    
    SKNode *previousJointNode;
    
    SKNode *leftAnchorNode = [SKNode node];
    leftAnchorNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(jointWidth, jointHeight)];
    leftAnchorNode.physicsBody.dynamic = NO;
    leftAnchorNode.position = CGPointMake(dx, dy);
    [self addChild:leftAnchorNode];
    
    for (NSInteger i = 0; i < numberOfJoints; i++) {
        
        SKShapeNode *jointNode = [SKShapeNode node];
        jointNode.hidden = !MMLBubbleShowDebugOutlines;
        jointNode.fillColor = [UIColor yellowColor];
        jointNode.path = [UIBezierPath bezierPathWithRect:CGRectMake(-jointWidth * 0.5f, -jointHeight * 0.5f, jointWidth, jointHeight)].CGPath;
        [self addChild:jointNode];
        
        jointNode.position = CGPointMake(dx, dy);
        
        jointNode.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(jointWidth, jointHeight)];
        jointNode.physicsBody.affectedByGravity = NO;
        jointNode.physicsBody.restitution = MMLBubbleBarrierJointPhysicsBodyRestitution;
        jointNode.physicsBody.friction = MMLBubbleBarrierJointPhysicsBodyFriction;
        jointNode.physicsBody.linearDamping = MMLBubbleBarrierJointPhysicsBodyLinearDamping;
        
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
    NSUInteger topicIndex = [self.bubbleTopics indexOfObject:topic];
    CGFloat percentOfVariableSize = 1.0f - topicIndex / (CGFloat)self.bubbleTopics.count;
    
    CGFloat height = MMLBubbleMinSize + percentOfVariableSize * MMLBubbleVariableSize;
    CGSize size = CGSizeMake(height * MMLBubbleHexagonAspectRatio, height);
    
    UIColor *grayColor = [UIColor colorWithWhite:0.666f alpha:1.0f];
    MMLBubbleSpriteNode *bubbleNode = [[MMLBubbleSpriteNode alloc] initWithTexture:self.bubbleTexture
                                                                             color:grayColor
                                                                              size:size];
    [self addChild:bubbleNode];
    
    bubbleNode.colorBlendFactor = 1.0f - percentOfVariableSize;
    bubbleNode.alpha = randRange(MMLBubbleMinAlpha, MMLBubbleMaxAlpha);
    bubbleNode.zPosition = (CGFloat)self.bubbleTopics.count - topicIndex;
    bubbleNode.topic = topic;
    
    CGFloat radius = size.width * 0.45f;
    
    if (MMLBubbleShowDebugOutlines) {
        SKShapeNode *physicsBodyShape = [SKShapeNode node];
        physicsBodyShape.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-radius, -radius, size.width, size.width)].CGPath;
        physicsBodyShape.strokeColor = [UIColor yellowColor];
        physicsBodyShape.lineWidth = 1.0f;
        [bubbleNode addChild:physicsBodyShape];
    }
    
    bubbleNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:radius];
    bubbleNode.physicsBody.dynamic = YES;
    bubbleNode.physicsBody.allowsRotation = NO;
    bubbleNode.physicsBody.density = 0.5f + (1.0f - percentOfVariableSize);
    
    bubbleNode.physicsBody.categoryBitMask = MMLBubblesSceneColliderTypeBubble;
    bubbleNode.physicsBody.collisionBitMask = MMLBubblesSceneColliderTypeWall | MMLBubblesSceneColliderTypeBubble;
    
    bubbleNode.physicsBody.restitution = MMLBubblePhysicsBodyRestitution;
    bubbleNode.physicsBody.friction = MMLBubblePhysicsBodyFriction;
    bubbleNode.physicsBody.linearDamping = MMLBubblePhysicsBodyLinearDamping;
    
    CGFloat halfViewWidthMinusBubbleWidth = (CGRectGetWidth(self.view.frame) - size.width) * 0.5f;
    CGFloat xp = CGRectGetMidX(self.view.frame) + (randRange(-halfViewWidthMinusBubbleWidth, halfViewWidthMinusBubbleWidth));
    CGFloat yp = -height * 0.5f - (MMLBubbleMinSize + MMLBubbleVariableSize) * topicIndex;
    bubbleNode.position = CGPointMake(xp, yp);
    
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
	return ((CGFloat)arc4random() / (CGFloat)0x100000000 * (high - low)) + low;
}


@end
