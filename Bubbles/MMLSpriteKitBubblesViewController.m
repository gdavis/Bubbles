//
//  MMLSpriteKitBubblesViewController.m
//  Bubbles
//
//  Created by Grant Davis on 1/27/14.
//
//

#import <SpriteKit/SpriteKit.h>

#import "MMLSpriteKitBubblesViewController.h"
#import "MMLBubblesScene.h"
#import "MMLAppDelegate.h"


@interface MMLSpriteKitBubblesViewController ()

@property (nonatomic, strong) MMLBubblesScene *scene;
@property (nonatomic, strong) NSTimer *refreshDataTimer;
@property (nonatomic) NSUInteger refreshCount;

@end


@implementation MMLSpriteKitBubblesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    SKView *spriteView = (SKView *) self.view;
    spriteView.showsDrawCount = YES;
    spriteView.showsNodeCount = YES;
    spriteView.showsFPS = YES;
    
    // Create and configure the scene.
    self.scene = [MMLBubblesScene sceneWithSize:spriteView.bounds.size];
    self.scene.scaleMode = SKSceneScaleModeAspectFill;
    
    // Present the scene.
    [spriteView presentScene:self.scene];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.refreshCount = 0;
    
    NSArray *hotTopics = [(MMLAppDelegate *)[[UIApplication sharedApplication] delegate] hotTopicsOne];
    [self.scene setTopics:hotTopics];
    
    [self startDataRefreshTimer];
}


- (void)startDataRefreshTimer
{
    self.refreshDataTimer = [NSTimer scheduledTimerWithTimeInterval:20.0f
                                                             target:self
                                                           selector:@selector(reloadData)
                                                           userInfo:nil
                                                            repeats:YES];
}


- (void)reloadData
{
    self.refreshCount++;
    
    NSArray *hotTopics;
    if (self.refreshCount % 2 == 0) {
        hotTopics = [(MMLAppDelegate *)[[UIApplication sharedApplication] delegate] hotTopicsOne];
    }
    else {
        hotTopics = [(MMLAppDelegate *)[[UIApplication sharedApplication] delegate] hotTopicsTwo];
    }
    
    [self.scene setTopics:hotTopics];
}


@end
