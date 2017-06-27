//
//  Profile.m
//  LoayaltyProgram
//
//  Created by Bogdan Chaikovsky on 10.04.17.
//  Copyright © 2017 Bogdan Chaikovsky. All rights reserved.
//

#import "ProfileController.h"
#import "Firebase.h"
#import "User.h"
#import "GuestCardController.h"
#import "EditProfileController.h"
#import "UIViewController+Alerts.h"
#import <QuartzCore/QuartzCore.h>
#import <SpriteKit/SpriteKit.h>

#define SCREEN_SCALE [[UIScreen mainScreen] scale]
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface ProfileController ()

@property (strong, nonatomic) FIRDatabaseReference *reference;
@property (strong, nonatomic) UIImageView *topImage;
@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UIView *topView;
@property (strong, nonatomic) User *user;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet UIButton *guestCardButton;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userPointsButton;

@end

@implementation ProfileController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.reference = [[FIRDatabase database] reference];
    self.user = [[User alloc] init];
    [self.userPointsButton setTitle:[NSString stringWithFormat:@" ★0 "] forState:UIControlStateNormal];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self checkIfUserIsLoggedIn];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self setupImageView];
    [self setupGuestCardButton];
    [self setupPointsButton];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self removeObserves];
}

- (void)removeObserves {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    if (userID != nil) {
        [[[self.reference child:@"users"] child:userID] removeAllObservers];
    }
}

- (void)checkIfUserIsLoggedIn {
    if ([[FIRAuth auth] currentUser].uid == nil){
        [self handleSignout:nil];
    } else{
        [self getUser];
    }
}

- (void)setupImageView{
    self.userImageView.layer.cornerRadius = self.userImageView.layer.frame.size.width/2;
    self.userImageView.layer.masksToBounds = YES;
}

- (void)setupGuestCardButton {
    self.guestCardButton.layer.cornerRadius = 4;
    self.guestCardButton.layer.masksToBounds =YES;
}

- (void)setupPointsButton {
    self.userPointsButton.backgroundColor = [UIColor colorWithRed:219.0/255 green:16.0/255 blue:32.0/255 alpha:1.0];
    self.userPointsButton.layer.cornerRadius = 22.0;
    self.userPointsButton.tintColor = [UIColor whiteColor];
    
    self.userPointsButton.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.userPointsButton.layer.shadowRadius = 4.0;
    self.userPointsButton.layer.shadowOpacity = 0.8;
    self.userPointsButton.layer.shadowOffset = CGSizeMake(0.0, 0.0);
    
    [self.userPointsButton setNeedsLayout];
    [self.userPointsButton layoutIfNeeded];
    
    [self.userPointsButton addTarget:self action:@selector(shootOffSpriteKitStarFromView:) forControlEvents:UIControlEventTouchUpInside];
}


// Sprite Kit https://github.com/ryang1428/ShootingStars
- (void)shootOffSpriteKitStarFromView:(UIView *)view {
    CGPoint viewOrigin;
    
    viewOrigin.y = 0;
    viewOrigin.x = (view.frame.origin.x + (view.frame.size.width / 2)) / SCREEN_SCALE;
    
    UIView *containerView = [[UIView alloc] initWithFrame:self.view.bounds];
    containerView.userInteractionEnabled = NO;
    
    SKView *skView = [[SKView alloc] initWithFrame:containerView.frame];
    skView.allowsTransparency = YES;
    [containerView addSubview:skView];
    
    SKScene *skScene = [SKScene sceneWithSize:skView.frame.size];
    skScene.scaleMode = SKSceneScaleModeFill;
    skScene.backgroundColor = [UIColor clearColor];
    
    SKSpriteNode *starSprite = [SKSpriteNode spriteNodeWithImageNamed:@"filled_star"];
    [starSprite setScale:0.35];
    
    starSprite.position = viewOrigin;
    [skScene addChild:starSprite];
    
    SKEmitterNode *emitter =  [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"StarParticle" ofType:@"sks"]];
    
    [emitter setParticlePosition:CGPointMake(0, -starSprite.size.height)];
    
    emitter.targetNode = skScene;
    
    [starSprite addChild:emitter];
    
    [skView presentScene:skScene];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, viewOrigin.x, viewOrigin.y);
    
    // CGPoint endPoint = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height + 100);
    CGPoint endPoint = CGPointMake(self.view.frame.size.width / 2 - 90, self.view.frame.size.height - 108);
    
    UIBezierPath *bp = [UIBezierPath new];
    [bp moveToPoint:viewOrigin];
    
    // curvy path
    // control points "pull" the curve to that point on the screen. You should be smarter then just using magic numbers like below.
    [bp addCurveToPoint:endPoint controlPoint1:CGPointMake(viewOrigin.x + 320, viewOrigin.y + 275) controlPoint2:CGPointMake(+20, skView.frame.size.height - 250)];
    
    __weak typeof(containerView) weakView = containerView;
    SKAction *followline = [SKAction followPath:bp.CGPath asOffset:YES orientToPath:YES duration:1.2];
    SKAction *fadeOut = [SKAction fadeOutWithDuration:0.4];
    
    SKAction *done = [SKAction runBlock:^{
        // lets delay until all particles are removed
        int64_t delayInSeconds = 0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            
            [self.userPointsButton setTitle:[NSString stringWithFormat:@" ★%d ",self.user.points] forState:UIControlStateNormal];
            [self.userPointsButton setNeedsLayout];
            [self.userPointsButton layoutIfNeeded];
            [UIView animateWithDuration:0.5f animations:^{
                [weakView setAlpha:0.0f];
            } completion:^(BOOL finished) {
                [weakView removeFromSuperview];
            }];
            
        });
    }];
    
    [starSprite runAction:[SKAction sequence:@[followline, fadeOut, done]]];
    
    [self.view addSubview:containerView];
}

- (void)getUser {
    NSString *userID = [FIRAuth auth].currentUser.uid;
    [[[self.reference child:@"users"] child:userID] observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        if (!snapshot.hasChildren) {
            [self handleSignout:nil];
            return;
        }
        self.user.name = snapshot.value[@"username"];
        self.user.gender = snapshot.value[@"gender"];
        self.user.birthday = snapshot.value[@"birtday"];
        self.user.phoneNumber = snapshot.value[@"phoneNumber"];
        self.user.email = snapshot.value[@"email"];
        self.user.profileImageURL = snapshot.value[@"profileImageURL"];
        self.user.points = [snapshot.value[@"points"] intValue];
        self.user.uid = userID;
        
        //        self.navigationItem.title = self.user.name;
        self.userNameLabel.text = self.user.name;
        //        self.userPointsButton.titleLabel.text = [NSString stringWithFormat:@" ★%d ",self.user.points];
        //
        
        if (![self.userPointsButton.titleLabel.text isEqualToString:[NSString stringWithFormat:@" ★%d ",self.user.points]] && ![self.userPointsButton.titleLabel.text isEqualToString:@" ★0 "]) {
            [self shootOffSpriteKitStarFromView: self.userPointsButton];
        } else if ([self.userPointsButton.titleLabel.text isEqualToString:@" ★0 "]) {
            [self.userPointsButton setTitle:[NSString stringWithFormat:@" ★%d ",self.user.points] forState:UIControlStateNormal];
            [self.userPointsButton setNeedsLayout];
            [self.userPointsButton layoutIfNeeded];
        }
  
        NSURL *url = [NSURL URLWithString:self.user.profileImageURL];
        [[[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (error){
                [self showMessagePrompt: error.localizedDescription];
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                self.userImageView.image = [UIImage imageWithData:data];
                
                //                //Add Image and Text to Navigation Title
                //                UIView *myView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, 300, 30)];
                //                UILabel *title = [[UILabel alloc] initWithFrame: CGRectMake(40, 0, 300, 30)];
                //
                //                title.text = NSLocalizedString(self.user.name, nil);
                //                [title setTextColor:[UIColor blackColor]];
                //                [title setFont:[UIFont boldSystemFontOfSize:20.0]];
                //
                //                [title setBackgroundColor:[UIColor clearColor]];
                //                UIImage *image = [UIImage imageWithData:data];
                //                UIImageView *myImageView = [[UIImageView alloc] initWithImage:image];
                //
                //                myImageView.frame = CGRectMake(0, 0, 30, 30);
                //                myImageView.layer.cornerRadius = 15.0;
                //                myImageView.layer.masksToBounds = YES;
                //                myImageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
                //                myImageView.layer.borderWidth = 0.1;
                //
                //                [myView addSubview:title];
                //                [myView setBackgroundColor:[UIColor  clearColor]];
                //                [myView addSubview:myImageView];
                //                self.navigationItem.titleView = myView;
                
            });
            if (self.user.profileImageData != data) {
                self.user.profileImageData = data;
            }
        }] resume];
        
    } withCancelBlock:^(NSError * _Nonnull error) {
        if (error){
            [self showMessagePrompt: error.localizedDescription];
            return;
        }
    }];
}

- (IBAction)handleSignout:(id)sender {
    NSError *signOutError;
    BOOL status = [[FIRAuth auth] signOut:&signOutError];
    if (!status) {
        if (signOutError){
            [self showMessagePrompt: signOutError.localizedDescription];
            return;
        }
        return;
    }
    [self performSegueWithIdentifier:@"profileToLogin" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"profileToGuestcard"]) {
        GuestCardController *upcoming = segue.destinationViewController;
        upcoming.user = self.user;
    }else if ([[segue identifier] isEqualToString:@"profileToEdit"]) {
        UINavigationController *nav = [segue destinationViewController];
        EditProfileController *editProfileController = (EditProfileController *)nav.topViewController;
        editProfileController.user = self.user;
    }
}

@end
