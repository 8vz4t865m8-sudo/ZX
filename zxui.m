#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <UIKit/UIFontDescriptor.h>

// ============================================================
// 颜色宏
// ============================================================
#define RGB(r,g,b)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(b)/255.0 alpha:(a)]

// ZX文件替换配置
static NSString * const kBundleID  = @"com.tencent.tmgp.dfm";
static NSString * const kTarget1   = @"Documents/DeltaForce/Saved/Config/IOS/OpenWorldSettings.ini";
static NSString * const kTarget2   = @"Documents/DeltaForce/Saved/Config/IOS/GPSystemSetting.ini";
static const NSInteger   kCountdown = 25;

static NSString* _fileContent1() {
    return @"[/Script/OpenWorldStreaming.OpenWorldStreamingSettings]\n"
            "OverrideSceneGM=InGame_MSAANumSample,1,1\n"
            "OverrideSceneGM=InMPGame_MSAANumSample,1,1\n"
            "OverrideSceneGM=InRaidGame_MSAANumSample,1,1\n"
            "OverrideSceneGM=InGame_AutoPowerOpt,0,0\n"
            "OverrideSceneGM=InMPGame_AutoPowerOpt,0,0\n"
            "OverrideSceneGM=InRaidGame_AutoPowerOpt,0,0\n"
            "OverrideSceneGM=InGame_DOF,1,1\n"
            "OverrideSceneGM=InRaidGame_DOF,1,1\n"
            "OverrideSceneGM=r.AllowStaticLighting,0,0\n"
            "OverrideSceneGM=r.AllowPointLightCubemapShadows,1,1\n"
            "OverrideSceneGM=r.MinRoughnessOverride,1,1\n"
            "OverrideSceneGM=r.PostProcessAAQuality,0,0\n"
            "OverrideSceneGM=r.DefaultFeature.AntiAliasing,0,0\n"
            "OverrideSceneGM=r.Streaming.MaxEffectiveScreenSize,12,12\n"
            "OverrideSceneGM=r.Shadow.CSM.TransitionScale,0,0\n"
            "OverrideSceneGM=r.PostProcessing.DisableMaterials,0,0\n"
            "OverrideSceneGM=r.IndirectLightingCache,0,0\n"
            "OverrideSceneGM=r.SkylightIntensityMultiplier,3,3\n"
            "OverrideSceneGM=r.EyeAdaptationQuality,1,1\n"
            "OverrideSceneGM=r.Color.Mid=0.22,0.22\n"
            "OverrideSceneGM=r.UsePreExposure,0,0\n"
            "OverrideSceneGM=r.AllowPointLightCubemapShadows,0,0\n"
            "OverrideSceneGM=weapon.DataMainAttributeCurvingType,0,0\n"
            "OverrideSceneGM=weapon.AimShakeScale,0,0";
}

static NSString* _fileContent2() {
    return @"[/Script/GPGlobalDefines.ClientGameSetting]\nbUnderFPPMode=False";
}

// ============================================================
// ZX 功能控制器（悬浮在主界面上）
// ============================================================
@interface ZXPanel : UIView
@property (strong, nonatomic) UIButton *optionA;
@property (strong, nonatomic) UIButton *optionB;
@property (strong, nonatomic) UIButton *startBtn;
@property (strong, nonatomic) UILabel  *logLabel;
@property (strong, nonatomic) UILabel  *timerLabel;
@property (strong, nonatomic) UIView   *progressFill;
@property (assign, nonatomic) BOOL     selectedThirdPerson;
@property (strong, nonatomic) NSString *destPath;
@property (strong, nonatomic) NSString *destPath2;
@property (strong, nonatomic) NSTimer  *countdownTimer;
@property (assign, nonatomic) NSInteger countdown;
@property (assign, nonatomic) NSTimeInterval deleteStartTime;
@property (assign, nonatomic) BOOL isFileDeleted;
@property (assign, nonatomic) BOOL isCountdownActive;
@end

@implementation ZXPanel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self buildUI];
        [[NSNotificationCenter defaultCenter] addObserver:self
            selector:@selector(appDidBecomeActive)
            name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)buildUI {
    CGFloat W = self.bounds.size.width;

    self.backgroundColor = RGBA(10,10,15,0.98);
    self.layer.cornerRadius = 20;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [RGBA(255,140,0,0.15) CGColor];

    // 顶部装饰线
    UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(W*0.3, 0, W*0.4, 2)];
    CAGradientLayer *tg = [CAGradientLayer layer];
    tg.frame = topLine.bounds;
    tg.colors = @[(id)[[UIColor clearColor] CGColor], (id)[RGBA(255,140,0,0.6) CGColor], (id)[[UIColor clearColor] CGColor]];
    tg.startPoint = CGPointMake(0,0.5); tg.endPoint = CGPointMake(1,0.5);
    [topLine.layer addSublayer:tg];
    [self addSubview:topLine];

    // 标题
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, W-100, 20)];
    title.text = @"ZX 定制功能";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:14];
    [self addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(16, 34, W-100, 14)];
    sub.text = @"DELTA FORCE · CONFIG";
    sub.textColor = RGBA(255,140,0,0.4);
    sub.font = [UIFont systemFontOfSize:10];
    [self addSubview:sub];

    // 模式选择标签
    UILabel *modeLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 58, W-32, 14)];
    modeLabel.text = @"选择模式";
    modeLabel.textColor = RGBA(255,255,255,0.3);
    modeLabel.font = [UIFont systemFontOfSize:11];
    [self addSubview:modeLabel];

    // 选项按钮
    CGFloat optW = (W - 44) / 2;
    self.optionA = [UIButton buttonWithType:UIButtonTypeCustom];
    self.optionA.frame = CGRectMake(16, 76, optW, 44);
    [self setupOptionBtn:self.optionA title:@"不加第三人称" selected:YES];
    [self.optionA addTarget:self action:@selector(selectA) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.optionA];

    self.optionB = [UIButton buttonWithType:UIButtonTypeCustom];
    self.optionB.frame = CGRectMake(16+optW+12, 76, optW, 44);
    [self setupOptionBtn:self.optionB title:@"加第三人称" selected:NO];
    [self.optionB addTarget:self action:@selector(selectB) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.optionB];

    self.selectedThirdPerson = NO;

    // 开启按钮
    self.startBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.startBtn.frame = CGRectMake(16, 132, W-32, 50);
    self.startBtn.layer.cornerRadius = 14;
    self.startBtn.layer.masksToBounds = YES;
    CAGradientLayer *bg = [CAGradientLayer layer];
    bg.frame = CGRectMake(0,0,W-32,50);
    bg.colors = @[(id)[RGB(255,140,0) CGColor], (id)[RGB(255,69,0) CGColor]];
    bg.startPoint = CGPointMake(0,0.5); bg.endPoint = CGPointMake(1,0.5);
    [self.startBtn.layer insertSublayer:bg atIndex:0];
    CAGradientLayer *shine = [CAGradientLayer layer];
    shine.frame = CGRectMake(0,0,W-32,25);
    shine.colors = @[(id)[RGBA(255,255,255,0.1) CGColor], (id)[[UIColor clearColor] CGColor]];
    shine.startPoint = CGPointMake(0.5,0); shine.endPoint = CGPointMake(0.5,1);
    [self.startBtn.layer addSublayer:shine];
    [self.startBtn setTitle:@"开 启" forState:UIControlStateNormal];
    [self.startBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.startBtn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    self.startBtn.layer.shadowColor = [RGB(255,100,0) CGColor];
    self.startBtn.layer.shadowOpacity = 0.35;
    self.startBtn.layer.shadowRadius = 8;
    self.startBtn.layer.shadowOffset = CGSizeMake(0,4);
    [self.startBtn addTarget:self action:@selector(startReplace) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.startBtn];

    // 进度条背景
    UIView *progBg = [[UIView alloc] initWithFrame:CGRectMake(16, 194, W-32, 4)];
    progBg.backgroundColor = RGBA(255,255,255,0.08);
    progBg.layer.cornerRadius = 2;
    [self addSubview:progBg];

    self.progressFill = [[UIView alloc] initWithFrame:CGRectMake(0,0,0,4)];
    self.progressFill.backgroundColor = RGB(255,140,0);
    self.progressFill.layer.cornerRadius = 2;
    [progBg addSubview:self.progressFill];

    // 倒计时标签
    self.timerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 204, W-32, 16)];
    self.timerLabel.text = @"";
    self.timerLabel.textColor = RGBA(255,140,0,0.6);
    self.timerLabel.font = [UIFont fontWithName:@"Courier" size:11];
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.timerLabel];

    // 日志
    self.logLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 224, W-32, 36)];
    self.logLabel.text = @"// 系统就绪";
    self.logLabel.textColor = RGBA(255,255,255,0.3);
    self.logLabel.font = [UIFont fontWithName:@"Courier" size:11];
    self.logLabel.numberOfLines = 2;
    [self addSubview:self.logLabel];
}

- (void)setupOptionBtn:(UIButton *)btn title:(NSString *)title selected:(BOOL)sel {
    btn.layer.cornerRadius = 12;
    btn.layer.masksToBounds = YES;
    [self updateOption:btn selected:sel];
    [btn setTitle:title forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12 weight:0.23];
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
}

- (void)updateOption:(UIButton *)btn selected:(BOOL)sel {
    if (sel) {
        btn.backgroundColor = RGBA(255,140,0,0.15);
        btn.layer.borderWidth = 1.5;
        btn.layer.borderColor = [RGBA(255,140,0,0.4) CGColor];
        [btn setTitleColor:RGBA(255,180,50,0.95) forState:UIControlStateNormal];
    } else {
        btn.backgroundColor = RGBA(255,255,255,0.05);
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = [RGBA(255,255,255,0.1) CGColor];
        [btn setTitleColor:RGBA(255,255,255,0.3) forState:UIControlStateNormal];
    }
}

- (void)selectA {
    self.selectedThirdPerson = NO;
    [self updateOption:self.optionA selected:YES];
    [self updateOption:self.optionB selected:NO];
}

- (void)selectB {
    self.selectedThirdPerson = YES;
    [self updateOption:self.optionA selected:NO];
    [self updateOption:self.optionB selected:YES];
}

- (void)setLog:(NSString *)t {
    dispatch_async(dispatch_get_main_queue(), ^{ self.logLabel.text = t; });
}

- (void)startReplace {
    self.startBtn.enabled = NO;
    [self setLog:@"// 正在写入文件..."];

    BOOL addThird = self.selectedThirdPerson;
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSString *appDir = @"/var/mobile/Containers/Data/Application";
        NSArray *uuids = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appDir error:nil];
        NSString *appPath = nil;
        for (NSString *uuid in uuids) {
            NSString *meta = [NSString stringWithFormat:@"%@/%@/.com.apple.mobile_container_manager.metadata.plist", appDir, uuid];
            NSDictionary *info = [NSDictionary dictionaryWithContentsOfFile:meta];
            if ([info[@"MCMMetadataIdentifier"] isEqualToString:kBundleID]) {
                appPath = [NSString stringWithFormat:@"%@/%@", appDir, uuid];
                break;
            }
        }

        if (!appPath) {
            [self setLog:@"// ✗ 找不到游戏\n// 请确认已安装三角洲"];
            dispatch_async(dispatch_get_main_queue(), ^{ self.startBtn.enabled = YES; });
            return;
        }

        NSString *d1 = [appPath stringByAppendingPathComponent:kTarget1];
        [[NSFileManager defaultManager] createDirectoryAtPath:[d1 stringByDeletingLastPathComponent]
            withIntermediateDirectories:YES attributes:nil error:nil];
        BOOL ok1 = [[_fileContent1() dataUsingEncoding:NSUTF8StringEncoding] writeToFile:d1 atomically:YES];

        BOOL ok2 = YES;
        NSString *d2 = nil;
        if (addThird) {
            d2 = [appPath stringByAppendingPathComponent:kTarget2];
            [[NSFileManager defaultManager] createDirectoryAtPath:[d2 stringByDeletingLastPathComponent]
                withIntermediateDirectories:YES attributes:nil error:nil];
            ok2 = [[_fileContent2() dataUsingEncoding:NSUTF8StringEncoding] writeToFile:d2 atomically:YES];
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            if (ok1 && ok2) {
                self.destPath = d1;
                self.destPath2 = d2;
                self.deleteStartTime = [[NSDate date] timeIntervalSince1970];
                self.isCountdownActive = YES;
                self.isFileDeleted = NO;
                self.countdown = kCountdown;

                NSString *mode = addThird ? @"加第三人称" : @"不加第三人称";
                [self setLog:[NSString stringWithFormat:@"// ✓ 开启成功！[%@]\n// 请在 %ld 秒内打开游戏", mode, (long)self.countdown]];

                self.progressFill.frame = CGRectMake(0,0,self.progressFill.superview.bounds.size.width,4);
                self.timerLabel.text = [NSString stringWithFormat:@"%ld 秒后自动防封", (long)self.countdown];

                if (self.countdownTimer) [self.countdownTimer invalidate];
                self.countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self
                    selector:@selector(tick) userInfo:nil repeats:YES];

                [self scheduleCheck:kCountdown];
                [self scheduleCheck:kCountdown+15];
            } else {
                [self setLog:@"// ✗ 文件写入失败\n// 请检查游戏是否已安装"];
                self.startBtn.enabled = YES;
            }
        });
    });
}

- (void)tick {
    if (!self.isCountdownActive) return;
    self.countdown--;
    CGFloat W = self.progressFill.superview.bounds.size.width;
    CGFloat ratio = MAX(0, (CGFloat)self.countdown / kCountdown);
    [UIView animateWithDuration:0.9 animations:^{
        self.progressFill.frame = CGRectMake(0,0,W*ratio,4);
    }];
    if (self.countdown > 0) {
        self.timerLabel.text = [NSString stringWithFormat:@"%ld 秒后自动防封", (long)self.countdown];
    } else {
        [self.countdownTimer invalidate];
        self.countdownTimer = nil;
        self.timerLabel.text = @"";
        [self doDelete];
    }
}

- (void)scheduleCheck:(NSTimeInterval)delay {
    if (self.isFileDeleted) return;
    __unsafe_unretained typeof(self) ws = self;  // 修改此处，避免 weak 引用问题
    UIBackgroundTaskIdentifier task = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [ws checkExpired];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(delay*NSEC_PER_SEC)),
        dispatch_get_global_queue(0,0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [ws checkExpired];
            [[UIApplication sharedApplication] endBackgroundTask:task];
        });
    });
}

- (void)checkExpired {
    if (self.isFileDeleted || !self.destPath) return;
    if ([[NSDate date] timeIntervalSince1970] - self.deleteStartTime >= kCountdown) [self doDelete];
}

- (void)appDidBecomeActive { [self checkExpired]; }

- (void)doDelete {
    if (self.isFileDeleted) return;
    self.isFileDeleted = YES;
    self.isCountdownActive = NO;
    [self.countdownTimer invalidate]; self.countdownTimer = nil;
    if (self.destPath) [[NSFileManager defaultManager] removeItemAtPath:self.destPath error:nil];
    if (self.destPath2) [[NSFileManager defaultManager] removeItemAtPath:self.destPath2 error:nil];
    [self setLog:@"// ✓ 防封已开启\n// 可重新点击开启"];
    self.timerLabel.text = @"";
    self.progressFill.frame = CGRectMake(0,0,0,4);
    self.startBtn.enabled = YES;
}

- (void)dealloc {
    [self.countdownTimer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

// ============================================================
// Hook ViewController - buildAuthView（替换验证页UI）
// ============================================================
typedef void (*buildAuthView_t)(id, SEL);
static buildAuthView_t orig_buildAuthView = NULL;

static void hook_buildAuthView(id self, SEL _cmd) {
    // 先调用原始方法建好逻辑
    orig_buildAuthView(self, _cmd);

    UIView *authView = [self valueForKey:@"authView"];
    if (!authView) return;

    CGFloat W = authView.bounds.size.width;
    CGFloat H = authView.bounds.size.height;

    // 完全覆盖原来的背景
    UIView *newBg = [[UIView alloc] initWithFrame:authView.bounds];
    newBg.backgroundColor = RGB(10,10,15);
    [authView addSubview:newBg];

    // 背景光晕
    UIView *glow1 = [[UIView alloc] initWithFrame:CGRectMake(-60,-120,W+120,380)];
    CAGradientLayer *g1 = [CAGradientLayer layer];
    g1.frame = glow1.bounds; g1.type = kCAGradientLayerRadial;
    g1.colors = @[(id)[RGBA(255,140,0,0.18) CGColor],(id)[RGBA(255,80,0,0.06) CGColor],(id)[[UIColor clearColor] CGColor]];
    g1.locations = @[@0,@0.45,@1];
    g1.startPoint = CGPointMake(0.5,0.5); g1.endPoint = CGPointMake(1,1);
    [glow1.layer addSublayer:g1]; [newBg addSubview:glow1];

    UIView *glow2 = [[UIView alloc] initWithFrame:CGRectMake(W-120,H-200,240,240)];
    CAGradientLayer *g2 = [CAGradientLayer layer];
    g2.frame = glow2.bounds; g2.type = kCAGradientLayerRadial;
    g2.colors = @[(id)[RGBA(120,60,255,0.08) CGColor],(id)[[UIColor clearColor] CGColor]];
    g2.locations = @[@0,@1];
    g2.startPoint = CGPointMake(0.5,0.5); g2.endPoint = CGPointMake(1,1);
    [glow2.layer addSublayer:g2]; [newBg addSubview:glow2];

    // 品牌图标
    UIView *brandMark = [[UIView alloc] initWithFrame:CGRectMake(28, 60, 36, 36)];
    brandMark.backgroundColor = RGB(255,140,0);
    brandMark.layer.cornerRadius = 10;
    brandMark.layer.shadowColor = [RGB(255,140,0) CGColor];
    brandMark.layer.shadowOpacity = 0.5;
    brandMark.layer.shadowRadius = 8;
    UILabel *markIcon = [[UILabel alloc] initWithFrame:brandMark.bounds];
    markIcon.text = @"⚡"; markIcon.textAlignment = NSTextAlignmentCenter; markIcon.font = [UIFont systemFontOfSize:18];
    [brandMark addSubview:markIcon]; [newBg addSubview:brandMark];

    UILabel *brandTxt = [[UILabel alloc] initWithFrame:CGRectMake(72, 68, 120, 20)];
    brandTxt.text = @"ZX 全系统";
    brandTxt.textColor = RGBA(255,255,255,0.5);
    brandTxt.font = [UIFont boldSystemFontOfSize:13];
    [newBg addSubview:brandTxt];

    UILabel *verLabel = [[UILabel alloc] initWithFrame:CGRectMake(W-80, 68, 60, 20)];
    verLabel.text = @"3.0";
    verLabel.textColor = RGBA(255,255,255,0.2);
    verLabel.font = [UIFont systemFontOfSize:11];
    verLabel.textAlignment = NSTextAlignmentRight;
    verLabel.backgroundColor = RGBA(255,255,255,0.05);
    verLabel.layer.cornerRadius = 6;
    verLabel.layer.masksToBounds = YES;
    [newBg addSubview:verLabel];

    // 标签
    UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(28, 120, 130, 26)];
    tagView.backgroundColor = RGBA(255,140,0,0.1);
    tagView.layer.cornerRadius = 13;
    tagView.layer.borderWidth = 1;
    tagView.layer.borderColor = [RGBA(255,140,0,0.2) CGColor];
    UIView *tagDot = [[UIView alloc] initWithFrame:CGRectMake(10,10,6,6)];
    tagDot.backgroundColor = RGB(255,140,0); tagDot.layer.cornerRadius = 3;
    tagDot.layer.shadowColor = [RGB(255,140,0) CGColor]; tagDot.layer.shadowOpacity = 1; tagDot.layer.shadowRadius = 3;
    [tagView addSubview:tagDot];
    UILabel *tagTxt = [[UILabel alloc] initWithFrame:CGRectMake(22,5,100,16)];
    tagTxt.text = @"AUTHORIZATION";
    tagTxt.textColor = RGBA(255,140,0,0.8); tagTxt.font = [UIFont systemFontOfSize:10 weight:0.23];
    [tagView addSubview:tagTxt]; [newBg addSubview:tagView];

    // 主标题
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(28, 158, W-56, 50)];
    titleL.text = @"访问需要授权";
    titleL.textColor = [UIColor whiteColor];
    titleL.font = [UIFont boldSystemFontOfSize:36];
    [newBg addSubview:titleL];

    UILabel *subL = [[UILabel alloc] initWithFrame:CGRectMake(28, 212, W-56, 18)];
    subL.text = @"输入您的专属卡密以激活全部功能";
    subL.textColor = RGBA(255,255,255,0.35);
    subL.font = [UIFont systemFontOfSize:13];
    [newBg addSubview:subL];

    // DEVICE ID 卡片
    UIView *devCard = [[UIView alloc] initWithFrame:CGRectMake(20, 248, W-40, 64)];
    devCard.backgroundColor = RGBA(255,255,255,0.04);
    devCard.layer.cornerRadius = 16;
    devCard.layer.borderWidth = 1;
    devCard.layer.borderColor = [RGBA(255,255,255,0.08) CGColor];
    UIView *cardTopLine = [[UIView alloc] initWithFrame:CGRectMake(devCard.bounds.size.width*0.25,0,devCard.bounds.size.width*0.5,1)];
    CAGradientLayer *ctg = [CAGradientLayer layer]; ctg.frame = cardTopLine.bounds;
    ctg.colors = @[(id)[[UIColor clearColor] CGColor],(id)[RGBA(255,140,0,0.35) CGColor],(id)[[UIColor clearColor] CGColor]];
    ctg.startPoint = CGPointMake(0,0.5); ctg.endPoint = CGPointMake(1,0.5);
    [cardTopLine.layer addSublayer:ctg]; [devCard addSubview:cardTopLine];
    UILabel *devLabel = [[UILabel alloc] initWithFrame:CGRectMake(16,10,80,14)];
    devLabel.text = @"DEVICE ID"; devLabel.textColor = RGBA(255,255,255,0.25); devLabel.font = [UIFont systemFontOfSize:10];
    [devCard addSubview:devLabel];
    UILabel *udidL = [authView valueForKey:@"udidL"];
    if (!udidL) {
        // 找原有显示UDID的label
        for (UIView *v in authView.subviews) {
            if ([v isKindOfClass:[UILabel class]]) {
                UILabel *l = (UILabel *)v;
                if (l.text.length > 20 && [l.text rangeOfString:@"-"].location == NSNotFound) {
                    UILabel *devVal = [[UILabel alloc] initWithFrame:CGRectMake(16,28,devCard.bounds.size.width-32,20)];
                    devVal.text = l.text;
                    devVal.textColor = RGBA(255,255,255,0.5);
                    devVal.font = [UIFont fontWithName:@"Courier" size:11];
                    devVal.adjustsFontSizeToFitWidth = YES;
                    [devCard addSubview:devVal];
                    break;
                }
            }
        }
    }
    [newBg addSubview:devCard];

    // 输入框标签
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 328, 100, 16)];
    inputLabel.text = @"LICENSE KEY";
    inputLabel.textColor = RGBA(255,255,255,0.3);
    inputLabel.font = [UIFont systemFontOfSize:11];
    [newBg addSubview:inputLabel];

    // 找原有输入框并美化
    for (UIView *v in authView.subviews) {
        if ([v isKindOfClass:[UITextField class]]) {
            UITextField *tf = (UITextField *)v;
            tf.frame = CGRectMake(20, 348, W-40, 52);
            tf.backgroundColor = RGBA(255,255,255,0.05);
            tf.layer.cornerRadius = 14;
            tf.layer.borderWidth = 1;
            tf.layer.borderColor = [RGBA(255,255,255,0.1) CGColor];
            tf.textColor = RGBA(255,255,255,0.85);
            tf.font = [UIFont fontWithName:@"Courier" size:14];
            tf.leftView = [[UIView alloc] initWithFrame:CGRectMake(0,0,16,0)];
            tf.leftViewMode = UITextFieldViewModeAlways;
            NSAttributedString *ph = [[NSAttributedString alloc] initWithString:@"XXXX-XXXX-XXXX-XXXX"
                attributes:@{NSForegroundColorAttributeName: RGBA(255,255,255,0.15)}];
            tf.attributedPlaceholder = ph;
            [newBg addSubview:tf];
            break;
        }
    }

    // 找原有VERIFY按钮并美化
    for (UIView *v in authView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            btn.frame = CGRectMake(20, H-80, W-40, 54);
            btn.layer.cornerRadius = 16;
            btn.layer.masksToBounds = YES;
            [btn.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
            CAGradientLayer *btnG = [CAGradientLayer layer];
            btnG.frame = CGRectMake(0,0,W-40,54);
            btnG.colors = @[(id)[RGB(255,140,0) CGColor],(id)[RGB(255,69,0) CGColor]];
            btnG.startPoint = CGPointMake(0,0.5); btnG.endPoint = CGPointMake(1,0.5);
            [btn.layer insertSublayer:btnG atIndex:0];
            CAGradientLayer *btnS = [CAGradientLayer layer];
            btnS.frame = CGRectMake(0,0,W-40,27);
            btnS.colors = @[(id)[RGBA(255,255,255,0.1) CGColor],(id)[[UIColor clearColor] CGColor]];
            btnS.startPoint = CGPointMake(0.5,0); btnS.endPoint = CGPointMake(0.5,1);
            [btn.layer addSublayer:btnS];
            [btn setTitle:@"ACTIVATE" forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
            btn.layer.shadowColor = [RGB(255,100,0) CGColor];
            btn.layer.shadowOpacity = 0.4;
            btn.layer.shadowRadius = 12;
            btn.layer.shadowOffset = CGSizeMake(0,6);
            [newBg addSubview:btn];
            break;
        }
    }

    // 底部提示
    UILabel *hintL = [[UILabel alloc] initWithFrame:CGRectMake(20, H-18, W-40, 14)];
    hintL.text = @"每张卡密绑定一台设备 · 不可转移";
    hintL.textColor = RGBA(255,255,255,0.15);
    hintL.font = [UIFont systemFontOfSize:10];
    hintL.textAlignment = NSTextAlignmentCenter;
    [newBg addSubview:hintL];

    [authView bringSubviewToFront:newBg];
}

// ============================================================
// Hook ViewController - buildMainView（替换主界面UI）
// ============================================================
typedef void (*buildMainView_t)(id, SEL);
static buildMainView_t orig_buildMainView = NULL;

static void hook_buildMainView(id self, SEL _cmd) {
    orig_buildMainView(self, _cmd);

    UIView *mainView = [self valueForKey:@"mainView"];
    if (!mainView) return;

    CGFloat W = mainView.bounds.size.width;
    CGFloat H = mainView.bounds.size.height;

    // 新背景
    UIView *newBg = [[UIView alloc] initWithFrame:mainView.bounds];
    newBg.backgroundColor = RGB(10,10,15);

    // 网格
    CAShapeLayer *grid = [CAShapeLayer layer];
    grid.frame = newBg.bounds;
    UIBezierPath *gPath = [UIBezierPath bezierPath];
    for (CGFloat x = 0; x < W; x += 40) {
        [gPath moveToPoint:CGPointMake(x,0)];
        [gPath addLineToPoint:CGPointMake(x,H)];
    }
    for (CGFloat y = 0; y < H; y += 40) {
        [gPath moveToPoint:CGPointMake(0,y)];
        [gPath addLineToPoint:CGPointMake(W,y)];
    }
    grid.path = gPath.CGPath;
    grid.strokeColor = [RGBA(255,255,255,0.02) CGColor];
    grid.lineWidth = 0.5;
    [newBg.layer addSublayer:grid];

    // 光晕
    UIView *topGlow = [[UIView alloc] initWithFrame:CGRectMake(-60,-120,W+120,380)];
    CAGradientLayer *tg = [CAGradientLayer layer];
    tg.frame = topGlow.bounds; tg.type = kCAGradientLayerRadial;
    tg.colors = @[(id)[RGBA(255,140,0,0.12) CGColor],(id)[RGBA(255,80,0,0.04) CGColor],(id)[[UIColor clearColor] CGColor]];
    tg.locations = @[@0,@0.45,@1];
    tg.startPoint = CGPointMake(0.5,0.5); tg.endPoint = CGPointMake(1,1);
    [topGlow.layer addSublayer:tg]; [newBg addSubview:topGlow];

    // 顶栏
    UIView *brandMark = [[UIView alloc] initWithFrame:CGRectMake(20, 56, 32, 32)];
    brandMark.backgroundColor = RGB(255,140,0);
    brandMark.layer.cornerRadius = 9;
    brandMark.layer.shadowColor = [RGB(255,140,0) CGColor];
    brandMark.layer.shadowOpacity = 0.5; brandMark.layer.shadowRadius = 6;
    UILabel *bIcon = [[UILabel alloc] initWithFrame:brandMark.bounds];
    bIcon.text = @"⚡"; bIcon.textAlignment = NSTextAlignmentCenter; bIcon.font = [UIFont systemFontOfSize:16];
    [brandMark addSubview:bIcon]; [newBg addSubview:brandMark];

    UILabel *brandTxt = [[UILabel alloc] initWithFrame:CGRectMake(60,60,100,22)];
    brandTxt.text = @"ZX 全系统";
    brandTxt.textColor = RGBA(255,255,255,0.5);
    brandTxt.font = [UIFont boldSystemFontOfSize:13];
    [newBg addSubview:brandTxt];

    // 在线状态
    UIView *onlineBadge = [[UIView alloc] initWithFrame:CGRectMake(W-90,58,70,26)];
    onlineBadge.backgroundColor = RGBA(74,222,128,0.1);
    onlineBadge.layer.cornerRadius = 13;
    onlineBadge.layer.borderWidth = 1;
    onlineBadge.layer.borderColor = [RGBA(74,222,128,0.2) CGColor];
    UIView *onDot = [[UIView alloc] initWithFrame:CGRectMake(10,10,6,6)];
    onDot.backgroundColor = RGB(74,222,128); onDot.layer.cornerRadius = 3;
    onDot.layer.shadowColor = [RGB(74,222,128) CGColor]; onDot.layer.shadowOpacity = 1; onDot.layer.shadowRadius = 3;
    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"opacity"];
    pulse.fromValue = @1; pulse.toValue = @0.3; pulse.duration = 1.5;
    pulse.autoreverses = YES; pulse.repeatCount = HUGE_VALF;
    [onDot.layer addAnimation:pulse forKey:@"p"];
    [onlineBadge addSubview:onDot];
    UILabel *onTxt = [[UILabel alloc] initWithFrame:CGRectMake(22,5,40,16)];
    onTxt.text = @"在线"; onTxt.textColor = RGBA(74,222,128,0.8); onTxt.font = [UIFont systemFontOfSize:11 weight:0.23];
    [onlineBadge addSubview:onTxt]; [newBg addSubview:onlineBadge];

    // Hero标题
    UILabel *eyebrow = [[UILabel alloc] initWithFrame:CGRectMake(20,100,W-40,16)];
    eyebrow.text = @"DELTA FORCE · RADAR SYSTEM";
    eyebrow.textColor = RGBA(255,140,0,0.5);
    eyebrow.font = [UIFont systemFontOfSize:11];
    [newBg addSubview:eyebrow];

    UILabel *heroTitle = [[UILabel alloc] initWithFrame:CGRectMake(20,120,W-40,44)];
    heroTitle.text = @"ZX 全系统【3.0】";
    heroTitle.textColor = [UIColor whiteColor];
    heroTitle.font = [UIFont boldSystemFontOfSize:32];
    [newBg addSubview:heroTitle];

    UILabel *heroSub = [[UILabel alloc] initWithFrame:CGRectMake(20,168,W-40,16)];
    heroSub.text = @"TECH  ·  RADAR  ·  CONFIG  ·  PRO";
    heroSub.textColor = RGBA(255,255,255,0.2);
    heroSub.font = [UIFont systemFontOfSize:11];
    [newBg addSubview:heroSub];

    // 到期时间条
    UIView *expireBar = [[UIView alloc] initWithFrame:CGRectMake(16,196,W-32,42)];
    expireBar.backgroundColor = RGBA(74,222,128,0.06);
    expireBar.layer.cornerRadius = 12;
    expireBar.layer.borderWidth = 1;
    expireBar.layer.borderColor = [RGBA(74,222,128,0.12) CGColor];
    UILabel *expLabel = [[UILabel alloc] initWithFrame:CGRectMake(14,0,100,42)];
    expLabel.text = @"LICENSE"; expLabel.textColor = RGBA(74,222,128,0.5); expLabel.font = [UIFont systemFontOfSize:11];
    [expireBar addSubview:expLabel];
    // 找原来的到期时间label
    UILabel *origExpire = [self valueForKey:@"expireTimeL"];
    UILabel *expVal = [[UILabel alloc] initWithFrame:CGRectMake(W-32-180,0,180,42)];
    expVal.text = origExpire ? origExpire.text : @"ACTIVE";
    expVal.textColor = RGBA(74,222,128,0.8); expVal.font = [UIFont fontWithName:@"Courier" size:12];
    expVal.textAlignment = NSTextAlignmentRight;
    [expireBar addSubview:expVal]; [newBg addSubview:expireBar];

    // 状态信息 4格
    CGFloat cardW = (W-44)/2;
    NSArray *cardTitles = @[@"KERNEL", @"PROCESS", @"RADAR", @"LICENSE"];

    UILabel *kernelStatusL  = [self valueForKey:@"kernelStatusL"];
    UILabel *radarStatusL   = [self valueForKey:@"radarStatusL"];

    NSArray *cardStatuses = @[
        kernelStatusL ? kernelStatusL.text : @"IDLE",
        @"WAITING",
        radarStatusL ? radarStatusL.text : @"IDLE",
        @"ACTIVE"
    ];

    NSArray *statusColors = @[
        RGBA(255,255,255,0.3),
        RGBA(245,158,11,0.8),
        RGBA(255,255,255,0.3),
        RGBA(74,222,128,0.8)
    ];

    for (int i = 0; i < 4; i++) {
        CGFloat cx = (i%2==0) ? 16 : 16+cardW+12;
        CGFloat cy = 250 + (i/2)*70;
        UIView *card = [[UIView alloc] initWithFrame:CGRectMake(cx,cy,cardW,58)];
        card.backgroundColor = RGBA(255,255,255,0.04);
        card.layer.cornerRadius = 14;
        card.layer.borderWidth = 1;
        card.layer.borderColor = [RGBA(255,255,255,0.07) CGColor];
        UIView *cTopLine = [[UIView alloc] initWithFrame:CGRectMake(card.bounds.size.width*0.2,0,card.bounds.size.width*0.6,1)];
        CAGradientLayer *ctgl = [CAGradientLayer layer]; ctgl.frame = cTopLine.bounds;
        ctgl.colors = @[(id)[[UIColor clearColor] CGColor],(id)[RGBA(255,140,0,0.2) CGColor],(id)[[UIColor clearColor] CGColor]];
        ctgl.startPoint = CGPointMake(0,0.5); ctgl.endPoint = CGPointMake(1,0.5);
        [cTopLine.layer addSublayer:ctgl]; [card addSubview:cTopLine];
        UILabel *cTitle = [[UILabel alloc] initWithFrame:CGRectMake(12,10,card.bounds.size.width-24,14)];
        cTitle.text = cardTitles[i]; cTitle.textColor = RGBA(255,255,255,0.25); cTitle.font = [UIFont systemFontOfSize:9];
        [card addSubview:cTitle];
        UILabel *cStatus = [[UILabel alloc] initWithFrame:CGRectMake(12,28,card.bounds.size.width-24,18)];
        cStatus.text = [NSString stringWithFormat:@"● %@", cardStatuses[i]];
        cStatus.textColor = statusColors[i]; cStatus.font = [UIFont boldSystemFontOfSize:12];
        [card addSubview:cStatus];
        [newBg addSubview:card];
    }

    // RADAR HTTP 信息
    UILabel *origHttp = [self valueForKey:@"http"];
    UIView *httpCard = [[UIView alloc] initWithFrame:CGRectMake(16,392,W-32,44)];
    httpCard.backgroundColor = RGBA(255,255,255,0.04);
    httpCard.layer.cornerRadius = 12;
    httpCard.layer.borderWidth = 1;
    httpCard.layer.borderColor = [RGBA(255,255,255,0.07) CGColor];
    UILabel *httpLabel = [[UILabel alloc] initWithFrame:CGRectMake(14,0,80,44)];
    httpLabel.text = @"RADAR HTTP"; httpLabel.textColor = RGBA(255,255,255,0.25); httpLabel.font = [UIFont systemFontOfSize:10];
    [httpCard addSubview:httpLabel];
    UILabel *httpVal = [[UILabel alloc] initWithFrame:CGRectMake(W-32-200,0,200,44)];
    httpVal.text = origHttp ? origHttp.text : @"--";
    httpVal.textColor = RGBA(255,255,255,0.5); httpVal.font = [UIFont fontWithName:@"Courier" size:12];
    httpVal.textAlignment = NSTextAlignmentRight;
    [httpCard addSubview:httpVal]; [newBg addSubview:httpCard];

    // 游戏切换（找原来的按钮移过来）
    UIView *gameSwitch = [[UIView alloc] initWithFrame:CGRectMake(16,448,W-32,52)];
    gameSwitch.backgroundColor = RGBA(255,255,255,0.03);
    gameSwitch.layer.cornerRadius = 14;
    gameSwitch.layer.borderWidth = 1;
    gameSwitch.layer.borderColor = [RGBA(255,255,255,0.07) CGColor];
    [newBg addSubview:gameSwitch];

    // 找原来游戏选择按钮
    NSMutableArray *gameBtns = [NSMutableArray array];
    for (UIView *v in mainView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            NSString *t = [btn titleForState:UIControlStateNormal];
            if ([t containsString:@"精英"] || [t containsString:@"三角洲"] || [t containsString:@"和平"]) {
                [gameBtns addObject:btn];
            }
        }
    }

    CGFloat gBtnW = (W-44)/2;
    for (int i = 0; i < gameBtns.count && i < 2; i++) {
        UIButton *btn = gameBtns[i];
        btn.frame = CGRectMake(6+i*(gBtnW+6), 6, gBtnW, 40);
        btn.layer.cornerRadius = 10;
        btn.layer.masksToBounds = YES;
        BOOL isSelected = (i==1); // 默认三角洲选中
        if (isSelected) {
            btn.backgroundColor = RGBA(255,140,0,0.2);
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [RGBA(255,140,0,0.3) CGColor];
            [btn setTitleColor:RGBA(255,160,50,0.95) forState:UIControlStateNormal];
        } else {
            btn.backgroundColor = [UIColor clearColor];
            btn.layer.borderWidth = 0;
            [btn setTitleColor:RGBA(255,255,255,0.3) forState:UIControlStateNormal];
        }
        btn.titleLabel.font = [UIFont systemFontOfSize:13 weight:0.23];
        [gameSwitch addSubview:btn];
    }

    // ZX 功能面板
    ZXPanel *zxPanel = [[ZXPanel alloc] initWithFrame:CGRectMake(16, 512, W-32, 272)];
    [newBg addSubview:zxPanel];

    // 底部按钮（找原来的重新样式化）
    CGFloat btnY = H - 130;
    NSMutableArray *mainBtns = [NSMutableArray array];
    for (UIView *v in mainView.subviews) {
        if ([v isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)v;
            NSString *t = [btn titleForState:UIControlStateNormal];
            if ([t containsString:@"初始化"] || [t containsString:@"内核"] || [t containsString:@"游戏"]) {
                [mainBtns addObject:btn];
            }
        }
    }

    for (int i = 0; i < mainBtns.count && i < 2; i++) {
        UIButton *btn = mainBtns[i];
        btn.frame = CGRectMake(16, btnY + i*60, W-32, 50);
        btn.layer.cornerRadius = 16;
        btn.layer.masksToBounds = YES;
        [btn.layer.sublayers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        if (i == 0) {
            // 主按钮（初始化内核）
            CAGradientLayer *bg = [CAGradientLayer layer];
            bg.frame = CGRectMake(0,0,W-32,50);
            bg.colors = @[(id)[RGB(255,140,0) CGColor],(id)[RGB(255,69,0) CGColor]];
            bg.startPoint = CGPointMake(0,0.5); bg.endPoint = CGPointMake(1,0.5);
            [btn.layer insertSublayer:bg atIndex:0];
            CAGradientLayer *sh = [CAGradientLayer layer];
            sh.frame = CGRectMake(0,0,W-32,25);
            sh.colors = @[(id)[RGBA(255,255,255,0.1) CGColor],(id)[[UIColor clearColor] CGColor]];
            sh.startPoint = CGPointMake(0.5,0); sh.endPoint = CGPointMake(0.5,1);
            [btn.layer addSublayer:sh];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            btn.layer.shadowColor = [RGB(255,100,0) CGColor];
            btn.layer.shadowOpacity = 0.3; btn.layer.shadowRadius = 8;
            btn.layer.shadowOffset = CGSizeMake(0,4);
        } else {
            // 次按钮（初始化游戏）
            btn.backgroundColor = RGBA(255,255,255,0.05);
            btn.layer.borderWidth = 1;
            btn.layer.borderColor = [RGBA(255,255,255,0.1) CGColor];
            [btn setTitleColor:RGBA(255,255,255,0.6) forState:UIControlStateNormal];
            btn.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        }
        [newBg addSubview:btn];
    }

    // 底部标识
    UIView *footLeft = [[UIView alloc] initWithFrame:CGRectMake(20,H-22,(W-80)/2,1)];
    footLeft.backgroundColor = RGBA(255,255,255,0.05); [newBg addSubview:footLeft];
    UILabel *footTxt = [[UILabel alloc] initWithFrame:CGRectMake((W-80)/2,H-28,80,14)];
    footTxt.text = @"ZX · 3.0"; footTxt.textColor = RGBA(255,255,255,0.1);
    footTxt.font = [UIFont systemFontOfSize:10]; footTxt.textAlignment = NSTextAlignmentCenter;
    [newBg addSubview:footTxt];
    UIView *footRight = [[UIView alloc] initWithFrame:CGRectMake((W+80)/2,H-22,(W-80)/2,1)];
    footRight.backgroundColor = RGBA(255,255,255,0.05); [newBg addSubview:footRight];

    [mainView addSubview:newBg];
}

// ============================================================
// 注入入口
// ============================================================
__attribute__((constructor))
static void _zxui_init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5*NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{

        Class vcClass = NSClassFromString(@"ViewController");
        if (!vcClass) return;

        // Hook buildAuthView
        SEL authSel = NSSelectorFromString(@"buildAuthView");
        Method authM = class_getInstanceMethod(vcClass, authSel);
        if (authM) {
            orig_buildAuthView = (buildAuthView_t)method_getImplementation(authM);
            method_setImplementation(authM, (IMP)hook_buildAuthView);
        }

        // Hook buildMainView
        SEL mainSel = NSSelectorFromString(@"buildMainView");
        Method mainM = class_getInstanceMethod(vcClass, mainSel);
        if (mainM) {
            orig_buildMainView = (buildMainView_t)method_getImplementation(mainM);
            method_setImplementation(mainM, (IMP)hook_buildMainView);
        }
    });
}
