#import <UIKit/UIKit.h>
#import <objc/runtime.h>

// ============================================================
// 颜色宏
// ============================================================
#define RGB(r,g,b)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

// ============================================================
// Hook ViewController - buildAuthView（替换验证页UI）
// ============================================================
typedef void (*buildAuthView_t)(id, SEL);
static buildAuthView_t orig_buildAuthView = NULL;

static void hook_buildAuthView(id self, SEL _cmd) {
    // 调用原始方法
    if (orig_buildAuthView) orig_buildAuthView(self, _cmd);

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
    tagTxt.textColor = RGBA(255,140,0,0.8); tagTxt.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
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
    // 找原有UDID label
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
    [newBg addSubview:devCard];

    // 输入框标签
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 328, 100, 16)];
    inputLabel.text = @"LICENSE KEY";
    inputLabel.textColor = RGBA(255,255,255,0.3);
    inputLabel.font = [UIFont systemFontOfSize:11];
    [newBg addSubview:inputLabel];

    // 美化输入框
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

    // 美化验证按钮
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
    if (orig_buildMainView) orig_buildMainView(self, _cmd);

    UIView *mainView = [self valueForKey:@"mainView"];
    if (!mainView) return;

    CGFloat W = mainView.bounds.size.width;
    CGFloat H = mainView.bounds.size.height;

    UIView *newBg = [[UIView alloc] initWithFrame:mainView.bounds];
    newBg.backgroundColor = RGB(10,10,15);

    // 简单网格装饰
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

    // 顶部光晕
    UIView *topGlow = [[UIView alloc] initWithFrame:CGRectMake(-60,-120,W+120,380)];
    CAGradientLayer *tg = [CAGradientLayer layer];
    tg.frame = topGlow.bounds; tg.type = kCAGradientLayerRadial;
    tg.colors = @[(id)[RGBA(255,140,0,0.12) CGColor],(id)[RGBA(255,80,0,0.04) CGColor],(id)[[UIColor clearColor] CGColor]];
    tg.locations = @[@0,@0.45,@1];
    tg.startPoint = CGPointMake(0.5,0.5); tg.endPoint = CGPointMake(1,1);
    [topGlow.layer addSublayer:tg]; [newBg addSubview:topGlow];

    // 品牌标题
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, W-40, 60)];
    title.text = @"ZX 全系统 3.0";
    title.textColor = [UIColor whiteColor];
    title.font = [UIFont boldSystemFontOfSize:36];
    title.textAlignment = NSTextAlignmentCenter;
    [newBg addSubview:title];

    UILabel *sub = [[UILabel alloc] initWithFrame:CGRectMake(20, 150, W-40, 20)];
    sub.text = @"DELTA FORCE · RADAR SYSTEM";
    sub.textColor = RGBA(255,140,0,0.5);
    sub.font = [UIFont systemFontOfSize:12];
    sub.textAlignment = NSTextAlignmentCenter;
    [newBg addSubview:sub];

    // 状态卡片（仅示例，无功能）
    UIView *card1 = [[UIView alloc] initWithFrame:CGRectMake(20, 200, W-40, 60)];
    card1.backgroundColor = RGBA(255,255,255,0.05);
    card1.layer.cornerRadius = 12;
    card1.layer.borderWidth = 1;
    card1.layer.borderColor = [RGBA(255,255,255,0.08) CGColor];
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, W-72, 20)];
    label1.text = @"RADAR HTTP";
    label1.textColor = RGBA(255,255,255,0.3);
    label1.font = [UIFont systemFontOfSize:11];
    [card1 addSubview:label1];
    UILabel *val1 = [[UILabel alloc] initWithFrame:CGRectMake(16, 32, W-72, 20)];
    val1.text = @"http://zx.example.com";
    val1.textColor = RGBA(255,255,255,0.6);
    val1.font = [UIFont fontWithName:@"Courier" size:13];
    [card1 addSubview:val1];
    [newBg addSubview:card1];

    // 底部按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(20, H-100, W-40, 50);
    btn.layer.cornerRadius = 16;
    btn.layer.masksToBounds = YES;
    CAGradientLayer *grd = [CAGradientLayer layer];
    grd.frame = btn.bounds;
    grd.colors = @[(id)[RGB(255,140,0) CGColor], (id)[RGB(255,69,0) CGColor]];
    grd.startPoint = CGPointMake(0,0.5); grd.endPoint = CGPointMake(1,0.5);
    [btn.layer insertSublayer:grd atIndex:0];
    [btn setTitle:@"ACTIVATE RADAR" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    btn.layer.shadowColor = [RGB(255,100,0) CGColor];
    btn.layer.shadowOpacity = 0.3;
    btn.layer.shadowRadius = 8;
    btn.layer.shadowOffset = CGSizeMake(0,4);
    [newBg addSubview:btn];

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

        SEL authSel = NSSelectorFromString(@"buildAuthView");
        Method authM = class_getInstanceMethod(vcClass, authSel);
        if (authM) {
            orig_buildAuthView = (buildAuthView_t)method_getImplementation(authM);
            method_setImplementation(authM, (IMP)hook_buildAuthView);
        }

        SEL mainSel = NSSelectorFromString(@"buildMainView");
        Method mainM = class_getInstanceMethod(vcClass, mainSel);
        if (mainM) {
            orig_buildMainView = (buildMainView_t)method_getImplementation(mainM);
            method_setImplementation(mainM, (IMP)hook_buildMainView);
        }
    });
}
