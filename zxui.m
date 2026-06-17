#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define RGB(r,g,b)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(b)/255.0 alpha:(a)]

// ============================================================
// 查找当前顶层 ViewController（不依赖类名）
// ============================================================
static UIViewController *findTopViewController() {
    UIViewController *top = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (top.presentedViewController) {
        top = top.presentedViewController;
    }
    if ([top isKindOfClass:[UINavigationController class]]) {
        top = [(UINavigationController *)top topViewController];
    }
    if ([top isKindOfClass:[UITabBarController class]]) {
        top = [(UITabBarController *)top selectedViewController];
    }
    return top;
}

// ============================================================
// 保存原始控件引用
// ============================================================
static UIButton *origVerifyBtn = nil;
static UIButton *origDfmBtn = nil;
static UIButton *origPubgBtn = nil;
static UIButton *origRadarBtn = nil;
static UIButton *origReinitBtn = nil;
static UILabel *origExpireTimeL = nil;
static UILabel *origKernelStatusL = nil;
static UILabel *origRadarStatusL = nil;
static UILabel *origProcStatusL = nil;
static UILabel *origRadarHttpL = nil;
static UILabel *origUDIDL = nil;

// ============================================================
// 新按钮事件（触发原始按钮事件）
// ============================================================
static void newVerifyAction() {
    if (origVerifyBtn) [origVerifyBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}
static void newDfmAction() {
    if (origDfmBtn) [origDfmBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}
static void newPubgAction() {
    if (origPubgBtn) [origPubgBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}
static void newRadarAction() {
    if (origRadarBtn) [origRadarBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}
static void newReinitAction() {
    if (origReinitBtn) [origReinitBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// ============================================================
// 创建键盘工具栏（含“完成”按钮）
// ============================================================
static UIToolbar *createKeyboardToolbar() {
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, UIScreen.mainScreen.bounds.size.width, 44)];
    toolbar.barStyle = UIBarStyleBlack;
    toolbar.tintColor = RGB(255, 140, 0);
    UIBarButtonItem *flex = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:nil action:@selector(dismissKeyboard)];
    toolbar.items = @[flex, done];
    return toolbar;
}

static void dismissKeyboard() {
    [[UIApplication sharedApplication].keyWindow endEditing:YES];
}

// ============================================================
// 强制替换 UI（核心）
// ============================================================
static void forceReplaceUI() {
    UIViewController *topVC = findTopViewController();
    if (!topVC) {
        NSLog(@"❌ 未找到 ViewController");
        return;
    }
    UIView *hostView = topVC.view;
    if (!hostView) {
        NSLog(@"❌ 未找到 hostView");
        return;
    }

    // ----- 1. 通过 KVC 获取原始控件 -----
    @try {
        origVerifyBtn = [topVC valueForKey:@"_authVerifyBtn"];
        origDfmBtn = [topVC valueForKey:@"_mainDfmBtn"];
        origPubgBtn = [topVC valueForKey:@"_mainPubgBtn"];
        origRadarBtn = [topVC valueForKey:@"_radarBtn"];
        origReinitBtn = [topVC valueForKey:@"_reinitBtn"];
        origExpireTimeL = [topVC valueForKey:@"_expireTimeL"];
        origKernelStatusL = [topVC valueForKey:@"_kernelStatusL"];
        origRadarStatusL = [topVC valueForKey:@"_radarStatusL"];
        origProcStatusL = [topVC valueForKey:@"_procStatusL"];
        origRadarHttpL = [topVC valueForKey:@"_radarHttpL"];
        origUDIDL = [topVC valueForKey:@"_authUDIDValL"];
    } @catch (NSException *e) {
        NSLog(@"⚠️ 获取控件失败：%@", e);
    }

    // ----- 2. 清除所有旧视图（彻底移除）-----
    for (UIView *sub in hostView.subviews) {
        [sub removeFromSuperview];
    }

    // ----- 3. 创建新 UI（完全采用你最初的设计）-----
    CGFloat W = hostView.bounds.size.width;
    CGFloat H = hostView.bounds.size.height;

    UIView *newUI = [[UIView alloc] initWithFrame:hostView.bounds];
    newUI.backgroundColor = RGB(10, 10, 15);
    newUI.tag = 9999;

    // ----- 背景光晕（来自你的原始代码）-----
    UIView *glow1 = [[UIView alloc] initWithFrame:CGRectMake(-60, -120, W+120, 380)];
    CAGradientLayer *g1 = [CAGradientLayer layer];
    g1.frame = glow1.bounds;
    g1.type = kCAGradientLayerRadial;
    g1.colors = @[(id)[RGBA(255, 140, 0, 0.18) CGColor], (id)[RGBA(255, 80, 0, 0.06) CGColor], (id)[[UIColor clearColor] CGColor]];
    g1.locations = @[@0, @0.45, @1];
    g1.startPoint = CGPointMake(0.5, 0.5);
    g1.endPoint = CGPointMake(1, 1);
    [glow1.layer addSublayer:g1];
    [newUI addSubview:glow1];

    UIView *glow2 = [[UIView alloc] initWithFrame:CGRectMake(W-120, H-200, 240, 240)];
    CAGradientLayer *g2 = [CAGradientLayer layer];
    g2.frame = glow2.bounds;
    g2.type = kCAGradientLayerRadial;
    g2.colors = @[(id)[RGBA(120, 60, 255, 0.08) CGColor], (id)[[UIColor clearColor] CGColor]];
    g2.locations = @[@0, @1];
    g2.startPoint = CGPointMake(0.5, 0.5);
    g2.endPoint = CGPointMake(1, 1);
    [glow2.layer addSublayer:g2];
    [newUI addSubview:glow2];

    // ----- 品牌图标 -----
    UIView *brandMark = [[UIView alloc] initWithFrame:CGRectMake(28, 60, 36, 36)];
    brandMark.backgroundColor = RGB(255, 140, 0);
    brandMark.layer.cornerRadius = 10;
    brandMark.layer.shadowColor = [RGB(255, 140, 0) CGColor];
    brandMark.layer.shadowOpacity = 0.5;
    brandMark.layer.shadowRadius = 8;
    UILabel *markIcon = [[UILabel alloc] initWithFrame:brandMark.bounds];
    markIcon.text = @"⚡";
    markIcon.textAlignment = NSTextAlignmentCenter;
    markIcon.font = [UIFont systemFontOfSize:18];
    [brandMark addSubview:markIcon];
    [newUI addSubview:brandMark];

    UILabel *brandTxt = [[UILabel alloc] initWithFrame:CGRectMake(72, 68, 120, 20)];
    brandTxt.text = @"ZX 全系统";
    brandTxt.textColor = RGBA(255, 255, 255, 0.5);
    brandTxt.font = [UIFont boldSystemFontOfSize:13];
    [newUI addSubview:brandTxt];

    UILabel *verLabel = [[UILabel alloc] initWithFrame:CGRectMake(W-80, 68, 60, 20)];
    verLabel.text = @"3.0";
    verLabel.textColor = RGBA(255, 255, 255, 0.2);
    verLabel.font = [UIFont systemFontOfSize:11];
    verLabel.textAlignment = NSTextAlignmentRight;
    verLabel.backgroundColor = RGBA(255, 255, 255, 0.05);
    verLabel.layer.cornerRadius = 6;
    verLabel.layer.masksToBounds = YES;
    [newUI addSubview:verLabel];

    // ----- 标签：AUTHORIZATION -----
    UIView *tagView = [[UIView alloc] initWithFrame:CGRectMake(28, 120, 130, 26)];
    tagView.backgroundColor = RGBA(255, 140, 0, 0.1);
    tagView.layer.cornerRadius = 13;
    tagView.layer.borderWidth = 1;
    tagView.layer.borderColor = [RGBA(255, 140, 0, 0.2) CGColor];
    UIView *tagDot = [[UIView alloc] initWithFrame:CGRectMake(10, 10, 6, 6)];
    tagDot.backgroundColor = RGB(255, 140, 0);
    tagDot.layer.cornerRadius = 3;
    tagDot.layer.shadowColor = [RGB(255, 140, 0) CGColor];
    tagDot.layer.shadowOpacity = 1;
    tagDot.layer.shadowRadius = 3;
    [tagView addSubview:tagDot];
    UILabel *tagTxt = [[UILabel alloc] initWithFrame:CGRectMake(22, 5, 100, 16)];
    tagTxt.text = @"AUTHORIZATION";
    tagTxt.textColor = RGBA(255, 140, 0, 0.8);
    tagTxt.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    [tagView addSubview:tagTxt];
    [newUI addSubview:tagView];

    // ----- 主标题 -----
    UILabel *titleL = [[UILabel alloc] initWithFrame:CGRectMake(28, 158, W-56, 50)];
    titleL.text = @"访问需要授权";
    titleL.textColor = [UIColor whiteColor];
    titleL.font = [UIFont boldSystemFontOfSize:36];
    [newUI addSubview:titleL];

    UILabel *subL = [[UILabel alloc] initWithFrame:CGRectMake(28, 212, W-56, 18)];
    subL.text = @"输入您的专属卡密以激活全部功能";
    subL.textColor = RGBA(255, 255, 255, 0.35);
    subL.font = [UIFont systemFontOfSize:13];
    [newUI addSubview:subL];

    // ----- DEVICE ID 卡片 -----
    UIView *devCard = [[UIView alloc] initWithFrame:CGRectMake(20, 248, W-40, 64)];
    devCard.backgroundColor = RGBA(255, 255, 255, 0.04);
    devCard.layer.cornerRadius = 16;
    devCard.layer.borderWidth = 1;
    devCard.layer.borderColor = [RGBA(255, 255, 255, 0.08) CGColor];
    UIView *cardTopLine = [[UIView alloc] initWithFrame:CGRectMake(devCard.bounds.size.width*0.25, 0, devCard.bounds.size.width*0.5, 1)];
    CAGradientLayer *ctg = [CAGradientLayer layer];
    ctg.frame = cardTopLine.bounds;
    ctg.colors = @[(id)[[UIColor clearColor] CGColor], (id)[RGBA(255, 140, 0, 0.35) CGColor], (id)[[UIColor clearColor] CGColor]];
    ctg.startPoint = CGPointMake(0, 0.5);
    ctg.endPoint = CGPointMake(1, 0.5);
    [cardTopLine.layer addSublayer:ctg];
    [devCard addSubview:cardTopLine];
    UILabel *devLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, 80, 14)];
    devLabel.text = @"DEVICE ID";
    devLabel.textColor = RGBA(255, 255, 255, 0.25);
    devLabel.font = [UIFont systemFontOfSize:10];
    [devCard addSubview:devLabel];
    UILabel *devVal = [[UILabel alloc] initWithFrame:CGRectMake(16, 28, devCard.bounds.size.width-32, 24)];
    devVal.text = origUDIDL ? origUDIDL.text : @"获取中...";
    devVal.textColor = RGBA(255, 255, 255, 0.5);
    devVal.font = [UIFont fontWithName:@"Courier" size:11];
    devVal.adjustsFontSizeToFitWidth = YES;
    [devCard addSubview:devVal];
    [newUI addSubview:devCard];

    // ----- 输入框标签 -----
    UILabel *inputLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 328, 100, 16)];
    inputLabel.text = @"LICENSE KEY";
    inputLabel.textColor = RGBA(255, 255, 255, 0.3);
    inputLabel.font = [UIFont systemFontOfSize:11];
    [newUI addSubview:inputLabel];

    // ----- 卡密输入框（带键盘工具栏）-----
    UITextField *cardInput = [[UITextField alloc] initWithFrame:CGRectMake(20, 348, W-40, 52)];
    cardInput.backgroundColor = RGBA(255, 255, 255, 0.05);
    cardInput.layer.cornerRadius = 14;
    cardInput.layer.borderWidth = 1;
    cardInput.layer.borderColor = [RGBA(255, 255, 255, 0.1) CGColor];
    cardInput.textColor = RGBA(255, 255, 255, 0.85);
    cardInput.font = [UIFont fontWithName:@"Courier" size:14];
    cardInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    cardInput.leftViewMode = UITextFieldViewModeAlways;
    cardInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"XXXX-XXXX-XXXX-XXXX"
        attributes:@{NSForegroundColorAttributeName: RGBA(255, 255, 255, 0.15)}];
    // 添加键盘工具栏
    cardInput.inputAccessoryView = createKeyboardToolbar();
    // 回车键收起键盘
    [cardInput addTarget:nil action:@selector(dismissKeyboard) forControlEvents:UIControlEventEditingDidEndOnExit];
    [newUI addSubview:cardInput];

    // ----- VERIFY 按钮（对接原始验证按钮）-----
    UIButton *newVerify = [UIButton buttonWithType:UIButtonTypeCustom];
    newVerify.frame = CGRectMake(20, H-80, W-40, 54);
    newVerify.layer.cornerRadius = 16;
    newVerify.layer.masksToBounds = YES;
    CAGradientLayer *btnG = [CAGradientLayer layer];
    btnG.frame = newVerify.bounds;
    btnG.colors = @[(id)[RGB(255, 140, 0) CGColor], (id)[RGB(255, 69, 0) CGColor]];
    btnG.startPoint = CGPointMake(0, 0.5);
    btnG.endPoint = CGPointMake(1, 0.5);
    [newVerify.layer insertSublayer:btnG atIndex:0];
    CAGradientLayer *btnS = [CAGradientLayer layer];
    btnS.frame = CGRectMake(0, 0, W-40, 27);
    btnS.colors = @[(id)[RGBA(255, 255, 255, 0.1) CGColor], (id)[[UIColor clearColor] CGColor]];
    btnS.startPoint = CGPointMake(0.5, 0);
    btnS.endPoint = CGPointMake(0.5, 1);
    [newVerify.layer addSublayer:btnS];
    [newVerify setTitle:@"ACTIVATE" forState:UIControlStateNormal];
    [newVerify setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newVerify.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    newVerify.layer.shadowColor = [RGB(255, 100, 0) CGColor];
    newVerify.layer.shadowOpacity = 0.4;
    newVerify.layer.shadowRadius = 12;
    newVerify.layer.shadowOffset = CGSizeMake(0, 6);
    [newVerify addTarget:nil action:@selector(newVerifyAction) forControlEvents:UIControlEventTouchUpInside];
    [newUI addSubview:newVerify];

    // ----- 底部提示 -----
    UILabel *hintL = [[UILabel alloc] initWithFrame:CGRectMake(20, H-18, W-40, 14)];
    hintL.text = @"每张卡密绑定一台设备 · 不可转移";
    hintL.textColor = RGBA(255, 255, 255, 0.15);
    hintL.font = [UIFont systemFontOfSize:10];
    hintL.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:hintL];

    // ----- 显示到期时间（如果有）-----
    if (origExpireTimeL && origExpireTimeL.text.length > 0) {
        UILabel *expireDisplay = [[UILabel alloc] initWithFrame:CGRectMake(20, 410, W-40, 16)];
        expireDisplay.text = [NSString stringWithFormat:@"到期：%@", origExpireTimeL.text];
        expireDisplay.textColor = RGBA(255, 255, 255, 0.3);
        expireDisplay.font = [UIFont systemFontOfSize:11];
        expireDisplay.textAlignment = NSTextAlignmentCenter;
        [newUI addSubview:expireDisplay];
    }

    // ----- 4. 添加到 hostView -----
    [hostView addSubview:newUI];
    NSLog(@"✅ UI 强制替换成功（含键盘优化）");
}

// ============================================================
// 注入入口（延迟 0.2 秒，几乎无感）
// ============================================================
__attribute__((constructor))
static void _zxui_init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        forceReplaceUI();
    });
}
