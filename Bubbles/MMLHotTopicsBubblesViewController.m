//
//  MMLHopTopicsBubblesViewController.m
//  MarchMadnessLive
//
//  Created by Grant Davis on 1/24/14.
//  Copyright (c) 2014 Turner Sports. All rights reserved.
//

#import "MMLHotTopicsBubblesViewController.h"
#import "MMLHotTopicBubbleBehavior.h"

#define ARC4RANDOM_MAX      0x100000000

static const CGVector MMLHopTopicsBubbleGravityDirection = { 0.0f, -0.05f };
static const NSUInteger MMLHopTopicsBubbleMax = 20;

@interface MMLHotTopicsBubblesViewController () <UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *boundaryCollisionBehavior;
@property (nonatomic, strong) UICollisionBehavior *bubbleCollisionBehavior;

@property (nonatomic, strong) NSMutableArray *bubbles;
@property (nonatomic, strong) NSTimer *bubbleTimer;

@end


@implementation MMLHotTopicsBubblesViewController


#pragma mark - Setup & Teardown


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    [self.animator addBehavior:self.gravityBehavior];
    [self.animator addBehavior:self.boundaryCollisionBehavior];
    [self.animator addBehavior:self.bubbleCollisionBehavior];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self createTopBoundaries];
    [self createBubbles];
}


#pragma mark - Private


- (void)createTopBoundaries
{
    BOOL shouldContinue = YES;
    
    CGFloat dx = 0.f;
    UIView *previousView;
    
    while (shouldContinue) {
        
        CGPoint anchor = CGPointMake(dx, 64.f);
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(anchor.x, anchor.y, 25.f, 25.f)];
        view.backgroundColor = [UIColor greenColor];
        [self.view addSubview:view];
        
        UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[view]];
        itemBehavior.allowsRotation = NO;
        [self.animator addBehavior:itemBehavior];
        
        UIAttachmentBehavior *attachment;
        if (previousView != nil) {
            attachment = [[UIAttachmentBehavior alloc] initWithItem:view attachedToItem:previousView];
        }
        else {
            attachment = [[UIAttachmentBehavior alloc] initWithItem:view attachedToAnchor:anchor];
        }
        
        attachment.damping = 0.95f;
        attachment.frequency = 4.f;
        attachment.length = 0.f;
        [self.animator addBehavior:attachment];
        
        [self.bubbleCollisionBehavior addItem:view];
        dx += CGRectGetWidth(view.frame);
        
        if (dx >= CGRectGetWidth(self.view.frame)) {
            shouldContinue = NO;
            continue;
        }
    }
}


- (void)createBubbles
{
    self.bubbles = [@[] mutableCopy];
    
    self.bubbleTimer = [NSTimer scheduledTimerWithTimeInterval:1.f
                                                        target:self
                                                      selector:@selector(addBubble)
                                                      userInfo:nil
                                                       repeats:YES];
}



- (void)addBubble
{
    CGFloat size = 50.f + ((arc4random() / (CGFloat)ARC4RANDOM_MAX) * 50.f);
    CGFloat dx = (arc4random() / (CGFloat)ARC4RANDOM_MAX) * (CGRectGetWidth(self.view.frame) - size);
    CGFloat dy = CGRectGetHeight(self.view.frame) + size;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, size, size)];
    button.center = CGPointMake(dx, dy);
    [button setImage:[UIImage imageNamed:@"bubble"] forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:1.f alpha:0.5f];
    [button addTarget:self action:@selector(handleButtonTouch) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    MMLHotTopicBubbleBehavior *buttonBehavior = [[MMLHotTopicBubbleBehavior alloc] initWithItems:@[button]];
    [self.animator addBehavior:buttonBehavior];
    
    [self.gravityBehavior addItem:button];
    [self.boundaryCollisionBehavior addItem:button];
    [self.bubbleCollisionBehavior addItem:button];
    
    [self.bubbles addObject:button];
    
    if (self.bubbles.count >= MMLHopTopicsBubbleMax) {
        [self.bubbleTimer invalidate];
        self.bubbleTimer = nil;
    }
}


#pragma mark - Actions


- (void)handleButtonTouch
{
    
}


#pragma mark - Accessors


- (UIGravityBehavior *)gravityBehavior
{
    if (_gravityBehavior == nil) {
        _gravityBehavior = [[UIGravityBehavior alloc] init];
        [_gravityBehavior setGravityDirection:MMLHopTopicsBubbleGravityDirection];
    }
    return _gravityBehavior;
}


- (UICollisionBehavior *)boundaryCollisionBehavior
{
    if (_boundaryCollisionBehavior == nil) {
        _boundaryCollisionBehavior = [[UICollisionBehavior alloc] init];
        [_boundaryCollisionBehavior addBoundaryWithIdentifier:@"top"
                                                    fromPoint:CGPointZero
                                                      toPoint:CGPointMake(CGRectGetWidth(self.view.frame), 0.f)];
        [_boundaryCollisionBehavior addBoundaryWithIdentifier:@"left"
                                                    fromPoint:CGPointZero
                                                      toPoint:CGPointMake(0.f, CGRectGetHeight(self.view.frame))];
        [_boundaryCollisionBehavior addBoundaryWithIdentifier:@"right"
                                                    fromPoint:CGPointMake(CGRectGetWidth(self.view.frame), 0.f)
                                                      toPoint:CGPointMake(CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [_boundaryCollisionBehavior setCollisionMode:UICollisionBehaviorModeBoundaries];
    }
    return _boundaryCollisionBehavior;
}


- (UICollisionBehavior *)bubbleCollisionBehavior
{
    if (_bubbleCollisionBehavior == nil) {
        _bubbleCollisionBehavior = [[UICollisionBehavior alloc] init];
        _bubbleCollisionBehavior.collisionDelegate = self;
        _bubbleCollisionBehavior.collisionMode = UICollisionBehaviorModeItems;
    }
    return _bubbleCollisionBehavior;
}


#pragma mark - UICollisionBehaviorDelegate


- (void)collisionBehavior:(UICollisionBehavior*)behavior beganContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2 atPoint:(CGPoint)p
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
    
    
}


- (void)collisionBehavior:(UICollisionBehavior*)behavior endedContactForItem:(id <UIDynamicItem>)item1 withItem:(id <UIDynamicItem>)item2
{
//    NSLog(@"%s", __PRETTY_FUNCTION__);
}


@end
