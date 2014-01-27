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
    
    NSArray *unsortedTopics = [(MMLAppDelegate *)[[UIApplication sharedApplication] delegate] hotTopics];
    
    NSArray *topics = [unsortedTopics sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"count" ascending:NO],
                                                                   [NSSortDescriptor sortDescriptorWithKey:@"hashtag" ascending:YES]]];
    
    [self.scene setTopics:topics];
}


@end
