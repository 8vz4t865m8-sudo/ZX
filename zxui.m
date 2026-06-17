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
        // 即使获取失败，我们仍继续覆盖 UI，只是按钮可能无法工作
    }

    // ----- 2. 清除所有旧视图（彻底移除）-----
    for (UIView *sub in hostView.subviews) {
        [sub removeFromSuperview];
    }

    // ----- 3. 创建新 UI（完全自定义）-----
    CGFloat W = hostView.bounds.size.width;
    CGFloat H = hostView.bounds.size.height;

    UIView *newUI = [[UIView alloc] initWithFrame:hostView.bounds];
    newUI.backgroundColor = RGB(10, 10, 15); // 深色背景
    newUI.tag = 9999;

    // ----- 3.1 头部标题 -----
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, W-40, 30)];
    title.text = @"WEBRADAR";
    title.textColor = RGBA(255, 140, 0, 0.8);
    title.font = [UIFont boldSystemFontOfSize:20];
    title.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:title];

    // ----- 3.2 主标题 -----
    UILabel *mainTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 120, W-40, 36)];
    mainTitle.text = @"授权验证";
    mainTitle.textColor = [UIColor whiteColor];
    mainTitle.font = [UIFont boldSystemFontOfSize:28];
    mainTitle.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:mainTitle];

    // ----- 3.3 UDID 卡片 -----
    UIView *udidCard = [[UIView alloc] initWithFrame:CGRectMake(20, 180, W-40, 60)];
    udidCard.backgroundColor = RGBA(255, 255, 255, 0.05);
    udidCard.layer.cornerRadius = 12;
    udidCard.layer.borderWidth = 1;
    udidCard.layer.borderColor = [RGBA(255, 255, 255, 0.08) CGColor];
    UILabel *udidLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 6, 80, 16)];
    udidLabel.text = @"UDID";
    udidLabel.textColor = RGBA(255, 255, 255, 0.3);
    udidLabel.font = [UIFont systemFontOfSize:11];
    [udidCard addSubview:udidLabel];
    UILabel *udidValue = [[UILabel alloc] initWithFrame:CGRectMake(12, 26, udidCard.bounds.size.width-24, 24)];
    udidValue.text = origUDIDL ? origUDIDL.text : @"获取中...";
    udidValue.textColor = RGBA(255, 255, 255, 0.6);
    udidValue.font = [UIFont fontWithName:@"Courier" size:12];
    udidValue.adjustsFontSizeToFitWidth = YES;
    [udidCard addSubview:udidValue];
    [newUI addSubview:udidCard];

    // ----- 3.4 卡密输入框 -----
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 260, 80, 16)];
    cardLabel.text = @"CARD";
    cardLabel.textColor = RGBA(255, 255, 255, 0.3);
    cardLabel.font = [UIFont systemFontOfSize:11];
    [newUI addSubview:cardLabel];

    UITextField *cardInput = [[UITextField alloc] initWithFrame:CGRectMake(20, 280, W-40, 50)];
    cardInput.backgroundColor = RGBA(255, 255, 255, 0.05);
    cardInput.layer.cornerRadius = 14;
    cardInput.layer.borderWidth = 1;
    cardInput.layer.borderColor = [RGBA(255, 255, 255, 0.1) CGColor];
    cardInput.textColor = [UIColor whiteColor];
    cardInput.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"XXXX-XXXX-XXXX-XXXX"
        attributes:@{NSForegroundColorAttributeName: RGBA(255, 255, 255, 0.2)}];
    cardInput.font = [UIFont fontWithName:@"Courier" size:14];
    cardInput.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 16, 0)];
    cardInput.leftViewMode = UITextFieldViewModeAlways;
    [newUI addSubview:cardInput];

    // ----- 3.5 验证按钮 -----
    UIButton *newVerify = [UIButton buttonWithType:UIButtonTypeCustom];
    newVerify.frame = CGRectMake(20, H-100, W-40, 50);
    newVerify.layer.cornerRadius = 16;
    newVerify.layer.masksToBounds = YES;
    CAGradientLayer *g1 = [CAGradientLayer layer];
    g1.frame = newVerify.bounds;
    g1.colors = @[(id)[RGB(255, 140, 0) CGColor], (id)[RGB(255, 69, 0) CGColor]];
    g1.startPoint = CGPointMake(0, 0.5);
    g1.endPoint = CGPointMake(1, 0.5);
    [newVerify.layer insertSublayer:g1 atIndex:0];
    [newVerify setTitle:@"VERIFY" forState:UIControlStateNormal];
    [newVerify setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    newVerify.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [newVerify addTarget:nil action:@selector(newVerifyAction) forControlEvents:UIControlEventTouchUpInside];
    [newUI addSubview:newVerify];

    // ----- 3.6 底部提示 -----
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(20, H-50, W-40, 14)];
    hint.text = @"每张卡密绑定一台设备 · 不可转移";
    hint.textColor = RGBA(255, 255, 255, 0.15);
    hint.font = [UIFont systemFontOfSize:10];
    hint.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:hint];

    // ----- 3.7 显示到期时间（示例：从原始 Label 读取）-----
    if (origExpireTimeL) {
        UILabel *expireDisplay = [[UILabel alloc] initWithFrame:CGRectMake(20, 350, W-40, 16)];
        expireDisplay.text = [NSString stringWithFormat:@"到期：%@", origExpireTimeL.text ?: @"未知"];
        expireDisplay.textColor = RGBA(255, 255, 255, 0.3);
        expireDisplay.font = [UIFont systemFontOfSize:11];
        expireDisplay.textAlignment = NSTextAlignmentCenter;
        [newUI addSubview:expireDisplay];
    }

    // ----- 4. 添加到 hostView -----
    [hostView addSubview:newUI];
    NSLog(@"✅ UI 强制替换成功");
}

// ============================================================
// 注入入口（延迟执行）
// ============================================================
__attribute__((constructor))
static void _zxui_init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        forceReplaceUI();
    });
}
