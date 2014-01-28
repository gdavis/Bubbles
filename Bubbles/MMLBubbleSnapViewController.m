//
//  MMLBubbleSnapViewController.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import "MMLBubbleSnapViewController.h"
#import "APLPositionToBoundsMapping.h"
#import "MMLAppDelegate.h"
#import "MMLHotTopic.h"
#import "MMLHotTopicButton.h"

#define ARC4RANDOM_MAX      0x100000000

static const CGFloat MMLBubbleSizes[] = {
                                         150.f,
                                         100.f,
                                         75.f,
                                         50.f
                                        };

static const CGFloat MMLBubbleSizeMax = 200.f;
static const CGFloat MMLBubbleSizeMin = 50.f;


@interface MMLBubbleSnapViewController ()

@property (nonatomic, strong) NSArray *bubbleLocations;
@property (nonatomic, strong) NSArray *bubbleStartLocations;
@property (nonatomic, strong) NSArray *bubbleSizes;
@property (nonatomic, strong) NSArray *hotTopics;
@property (nonatomic, strong) NSMutableArray *topicButtons;

@property (nonatomic, strong) UIDynamicAnimator *animator;

@end


@implementation MMLBubbleSnapViewController


- (void)viewDidLoad
{
    [super viewDidLoad];

    self.topicButtons = [NSMutableArray array];
    
    self.bubbleLocations = @[
                             [NSValue valueWithCGPoint:CGPointMake(0.25f, 0.25f)],
                             [NSValue valueWithCGPoint:CGPointMake(0.75f, 0.25f)],
                             [NSValue valueWithCGPoint:CGPointMake(0.5f, 0.5f)],
                             [NSValue valueWithCGPoint:CGPointMake(0.75f, 0.75f)]
                             ];
    
    self.bubbleStartLocations = @[[NSValue valueWithCGPoint:CGPointMake(0.5f, 0.5f)],
                                  [NSValue valueWithCGPoint:CGPointMake(0.25f, 0.25f)],
                                  [NSValue valueWithCGPoint:CGPointMake(0.75f, 0.25f)],
                                  [NSValue valueWithCGPoint:CGPointMake(0.75f, 0.75f)]];
    
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    
    
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self reloadData];
//    [self.bubbleLocations enumerateObjectsUsingBlock:^(NSValue *value, NSUInteger idx, BOOL *stop) {
//        
//        double delayInSeconds = 0.25 * idx;
//        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            
//            CGFloat size = MMLBubbleSizes[idx];
//            
//            CGPoint buttonPosition = [value CGPointValue];
//            CGPoint buttonCenter = CGPointMake(CGRectGetWidth(self.view.frame) * buttonPosition.x, CGRectGetHeight(self.view.frame) * buttonPosition.y);
//            MMLHotTopicButton *button = [[MMLHotTopicButton alloc] initWithFrame:CGRectMake(0.f, 0.f, size, size)];
//            
////            [button setImage:[UIImage imageNamed:@"bubble"] forState:UIControlStateNormal];
//            
//            button.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:1.f alpha:.25f];
//            button.center = CGPointMake((arc4random() / (CGFloat)ARC4RANDOM_MAX) * CGRectGetWidth(self.view.frame),
//                                        CGRectGetHeight(self.view.frame));
//            [self.view addSubview:button];
//            
//            CGFloat damping = 0.4f;
//            CGFloat frequency = 1.0f;
//            
//            UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:button attachedToAnchor:buttonCenter];
//            attachmentBehavior.frequency = frequency;
//            attachmentBehavior.damping = damping;
//            attachmentBehavior.length = 0.f;
//            [self.animator addBehavior:attachmentBehavior];
//            
//            UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[button]];
//            itemBehavior.allowsRotation = NO;
//            [self.animator addBehavior:itemBehavior];
//            
//            APLPositionToBoundsMapping *buttonBoundsDynamicItem = [[APLPositionToBoundsMapping alloc] initWithTarget:(id <ResizableDynamicItem>)button];
//            
//            // Create an attachment between the buttonBoundsDynamicItem and the initial
//            // value of the button's bounds.
//            attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:buttonBoundsDynamicItem attachedToAnchor:buttonBoundsDynamicItem.center];
//            attachmentBehavior.frequency = frequency;
//            attachmentBehavior.damping = damping;
//            [self.animator addBehavior:attachmentBehavior];
//            
//            UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[buttonBoundsDynamicItem] mode:UIPushBehaviorModeInstantaneous];
//            pushBehavior.angle = M_PI_4;
//            pushBehavior.magnitude = 3.0f;
//            [self.animator addBehavior:pushBehavior];
//            
//            [pushBehavior setActive:TRUE];
//        });
//        
//    }];
}


#pragma mark - Private


- (void)reloadData
{
    
    NSArray *oldTopicHashtags = [self.hotTopics valueForKey:@"hashtag"];
    
    NSArray *unsortedTopics = [(MMLAppDelegate *)[[UIApplication sharedApplication] delegate] hotTopicsOne];
    
    self.hotTopics = [unsortedTopics sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO],
                                                                   [NSSortDescriptor sortDescriptorWithKey:@"hashtag" ascending:YES]]];
    
    NSArray *newTopicHashtags = [self.hotTopics valueForKey:@"hashtag"];
    
    NSMutableArray *buttonsToRemove = [NSMutableArray array];
    
    for (NSUInteger index = 0; index < [oldTopicHashtags count]; index++) {
        NSString *hashtag = oldTopicHashtags[index];
        NSUInteger newIndex = [newTopicHashtags indexOfObject:hashtag];
        
        if (newIndex == NSNotFound) {
            [self.topicButtons enumerateObjectsUsingBlock:^(MMLHotTopicButton *button, NSUInteger idx, BOOL *stop) {
                if ([button.topic.hashtag isEqualToString:hashtag]) {
                    [buttonsToRemove addObject:button];
                }
            }];
        }
    }
    
    [buttonsToRemove enumerateObjectsUsingBlock:^(MMLHotTopicButton *button, NSUInteger idx, BOOL *stop) {
        [button removeFromSuperview];
    }];
    
    for (NSUInteger index = 0; index < [newTopicHashtags count]; index++) {
        
        NSString *hashtag = newTopicHashtags[index];
        NSUInteger oldIndex = [oldTopicHashtags indexOfObject:hashtag];
        
        if (oldTopicHashtags != nil && oldIndex != NSNotFound) {
            // TODO: Update existing button
        }
        else {
            // TODO: Add button
            [self addButtonWithHotTopic:[self.hotTopics objectAtIndex:[newTopicHashtags indexOfObject:hashtag]]];
        }
    }
    
//    [self positionButtons];
    [self addButtonBehaviors];
}


- (void)addButtonWithHotTopic:(MMLHotTopic *)topic
{
    CGFloat size = 75.f;
    
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat viewHeight = CGRectGetHeight(self.view.frame);
    
    CGPoint buttonPosition = CGPointMake([self randomValue], [self randomValue]);
    CGPoint buttonCenter = CGPointMake(viewWidth * buttonPosition.x, viewHeight * buttonPosition.y);
    
    MMLHotTopicButton *button = [[MMLHotTopicButton alloc] initWithFrame:CGRectMake(0.f, 0.f, size, size)];
    [self.topicButtons addObject:button];
    button.targetCenter = buttonCenter;
    
    [button setTitle:topic.hashtag forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"bubble"] forState:UIControlStateNormal];
    
    button.backgroundColor = [UIColor colorWithRed:1.f green:0.f blue:1.f alpha:.25f];
    button.center = CGPointMake([self randomValue] * viewWidth,
                                viewHeight);
    
    [self.view addSubview:button];
}


//- (void)positionButtons
//{
//    NSArray *hashtagCounts = [self.hotTopics valueForKey:@"count"];
//    
//    __block NSUInteger total = 0;
//    [hashtagCounts enumerateObjectsUsingBlock:^(NSNumber *obj, NSUInteger idx, BOOL *stop) {
//        total += [obj integerValue];
//    }];
//    
//    NSUInteger largestValue = [[[self.hotTopics firstObject] valueForKey:@"count"] integerValue];
//    
//    [self.topicButtons enumerateObjectsUsingBlock:^(MMLHotTopicButton *button, NSUInteger idx, BOOL *stop) {
//        MMLHotTopic *topic = button.topic;
//        
//        CGFloat size = (MMLBubbleSizeMax - MMLBubbleSizeMin) * (topic.count / largestValue) + MMLBubbleSizeMin;
//        button.frame = CGRectMake(button.frame.origin.x, button.frame.origin.y, size, size);
//        
//    }];
//}


- (void)addButtonBehaviors
{
    [self.topicButtons enumerateObjectsUsingBlock:^(MMLHotTopicButton *button, NSUInteger idx, BOOL *stop) {
        
        CGFloat damping = 0.4f;
        CGFloat frequency = 1.0f;
        
        UIAttachmentBehavior *attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:button attachedToAnchor:button.targetCenter];
        attachmentBehavior.frequency = frequency;
        attachmentBehavior.damping = damping;
        attachmentBehavior.length = 0.f;
        [self.animator addBehavior:attachmentBehavior];
        
        UIDynamicItemBehavior *itemBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[button]];
        itemBehavior.allowsRotation = NO;
        [self.animator addBehavior:itemBehavior];
        
        APLPositionToBoundsMapping *buttonBoundsDynamicItem = [[APLPositionToBoundsMapping alloc] initWithTarget:(id <ResizableDynamicItem>)button];
        
        // Create an attachment between the buttonBoundsDynamicItem and the initial
        // value of the button's bounds.
        attachmentBehavior = [[UIAttachmentBehavior alloc] initWithItem:buttonBoundsDynamicItem attachedToAnchor:buttonBoundsDynamicItem.center];
        attachmentBehavior.frequency = frequency;
        attachmentBehavior.damping = damping;
        [self.animator addBehavior:attachmentBehavior];
        
        UIPushBehavior *pushBehavior = [[UIPushBehavior alloc] initWithItems:@[buttonBoundsDynamicItem] mode:UIPushBehaviorModeInstantaneous];
        pushBehavior.angle = M_PI_4;
        pushBehavior.magnitude = 3.0f;
        [self.animator addBehavior:pushBehavior];
        
        [pushBehavior setActive:TRUE];
    }];
}


- (CGFloat)randomValue
{
    return (arc4random() / (CGFloat)ARC4RANDOM_MAX);
}


#pragma mark - Accessors



@end
