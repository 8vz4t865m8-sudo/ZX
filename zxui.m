#import <UIKit/UIKit.h>
#import <objc/runtime.h>

#define RGB(r,g,b)    [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1]
#define RGBA(r,g,b,a) [UIColor colorWithRed:(r)/255.0 green:(r)/255.0 blue:(b)/255.0 alpha:(a)]

// ============================================================
// 保存原始按钮（用于事件对接）
// ============================================================
static UIButton *origVerifyBtn = nil;     // 验证页的 VERIFY 按钮
static UIButton *origKernelBtn = nil;     // 主界面的 "初始化内核" 按钮
static UIButton *origGameBtn = nil;       // 主界面的 "初始化游戏" 按钮

// ============================================================
// 查找当前顶层视图控制器
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
// 新按钮事件（触发原始按钮）
// ============================================================
static void newVerifyAction() {
    if (origVerifyBtn) {
        [origVerifyBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
static void newKernelAction() {
    if (origKernelBtn) {
        [origKernelBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}
static void newGameAction() {
    if (origGameBtn) {
        [origGameBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

// ============================================================
// 强制覆盖主窗口 UI（模仿原始风格）
// ============================================================
static void forceReplaceUI() {
    UIViewController *topVC = findTopViewController();
    if (!topVC) return;
    UIView *hostView = topVC.view;
    if (!hostView) return;
    CGFloat W = hostView.bounds.size.width;
    CGFloat H = hostView.bounds.size.height;

    // ----- 1. 查找并保存原始按钮（按标题关键字） -----
    for (UIView *sub in hostView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) {
            UIButton *btn = (UIButton *)sub;
            NSString *title = [btn titleForState:UIControlStateNormal];
            if ([title containsString:@"VERIFY"] || [title containsString:@"验证"]) {
                origVerifyBtn = btn;
            } else if ([title containsString:@"初始化内核"] || [title containsString:@"KERNEL"]) {
                origKernelBtn = btn;
            } else if ([title containsString:@"初始化游戏"] || [title containsString:@"GAME"]) {
                origGameBtn = btn;
            }
        }
    }
    // 如果还没找到，按顺序补全
    NSMutableArray *allBtns = [NSMutableArray array];
    for (UIView *sub in hostView.subviews) {
        if ([sub isKindOfClass:[UIButton class]]) [allBtns addObject:sub];
    }
    if (!origVerifyBtn && allBtns.count > 0) origVerifyBtn = allBtns[0];
    if (!origKernelBtn && allBtns.count > 1) origKernelBtn = allBtns[1];
    if (!origGameBtn && allBtns.count > 2) origGameBtn = allBtns[2];

    // ----- 2. 隐藏所有现有子视图 -----
    for (UIView *sub in hostView.subviews) {
        sub.hidden = YES;
    }

    // ----- 3. 创建新背景 -----
    UIView *newUI = [[UIView alloc] initWithFrame:hostView.bounds];
    newUI.backgroundColor = RGB(10, 10, 15); // 深色背景
    newUI.tag = 9999;

    // ============================================================
    // 模仿验证页 UI（图2）
    // ============================================================
    // 标题 "WEBRADAR"
    UILabel *webRadar = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, W-40, 30)];
    webRadar.text = @"WEBRADAR";
    webRadar.textColor = RGBA(255, 140, 0, 0.8);
    webRadar.font = [UIFont boldSystemFontOfSize:18];
    webRadar.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:webRadar];

    // "请" 小字
    UILabel *please = [[UILabel alloc] initWithFrame:CGRectMake(20, 100, W-40, 20)];
    please.text = @"请";
    please.textColor = RGBA(255, 255, 255, 0.3);
    please.font = [UIFont systemFontOfSize:14];
    please.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:please];

    // 主标题 "验证授权"
    UILabel *authTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 130, W-40, 40)];
    authTitle.text = @"验证授权";
    authTitle.textColor = [UIColor whiteColor];
    authTitle.font = [UIFont boldSystemFontOfSize:28];
    authTitle.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:authTitle];

    // 副标题
    UILabel *subTitle = [[UILabel alloc] initWithFrame:CGRectMake(20, 175, W-40, 20)];
    subTitle.text = @"输入您的卡密以激活雷达功能";
    subTitle.textColor = RGBA(255, 255, 255, 0.4);
    subTitle.font = [UIFont systemFontOfSize:12];
    subTitle.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:subTitle];

    // ----- UDID 卡片 -----
    UIView *udidCard = [[UIView alloc] initWithFrame:CGRectMake(20, 210, W-40, 60)];
    udidCard.backgroundColor = RGBA(255, 255, 255, 0.05);
    udidCard.layer.cornerRadius = 12;
    udidCard.layer.borderWidth = 1;
    udidCard.layer.borderColor = [RGBA(255, 255, 255, 0.08) CGColor];
    UILabel *udidLabel = [[UILabel alloc] initWithFrame:CGRectMake(12, 8, 80, 16)];
    udidLabel.text = @"UDID";
    udidLabel.textColor = RGBA(255, 255, 255, 0.3);
    udidLabel.font = [UIFont systemFontOfSize:11];
    [udidCard addSubview:udidLabel];
    UILabel *udidValue = [[UILabel alloc] initWithFrame:CGRectMake(12, 28, udidCard.bounds.size.width-24, 24)];
    udidValue.text = @"E2835986D8EA7C516EA594E721D34079"; // 示例，可动态获取
    udidValue.textColor = RGBA(255, 255, 255, 0.6);
    udidValue.font = [UIFont fontWithName:@"Courier" size:12];
    udidValue.adjustsFontSizeToFitWidth = YES;
    [udidCard addSubview:udidValue];
    [newUI addSubview:udidCard];

    // ----- 卡密输入框 -----
    UILabel *cardLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 280, 80, 16)];
    cardLabel.text = @"CARD";
    cardLabel.textColor = RGBA(255, 255, 255, 0.3);
    cardLabel.font = [UIFont systemFontOfSize:11];
    [newUI addSubview:cardLabel];

    UITextField *cardInput = [[UITextField alloc] initWithFrame:CGRectMake(20, 300, W-40, 50)];
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

    // ----- 底部提示 -----
    UILabel *hint = [[UILabel alloc] initWithFrame:CGRectMake(20, H-60, W-40, 16)];
    hint.text = @"每张卡密绑定一台设备 · 不可转移";
    hint.textColor = RGBA(255, 255, 255, 0.15);
    hint.font = [UIFont systemFontOfSize:10];
    hint.textAlignment = NSTextAlignmentCenter;
    [newUI addSubview:hint];

    // ----- VERIFY 按钮（对接原始验证按钮） -----
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

    // ----- 我们也可以把主界面的 UI 也整合进来，但验证页和主界面通常是分开的，这里先只做验证页 -----
    // 如果你希望主界面也替换，可以在这里判断当前是哪个页面（通过按钮存在性），或者简单同时覆盖所有。
    // 为了简单，我这里只覆盖验证页风格，你可以在实际测试后决定是否合并。

    // ----- 显示新 UI -----
    [hostView addSubview:newUI];

    NSLog(@"✅ UI 强制覆盖成功（验证页风格），已对接 %lu 个按钮", (unsigned long)(origVerifyBtn?1:0)+(origKernelBtn?1:0)+(origGameBtn?1:0));
}

// ============================================================
// 注入入口
// ============================================================
__attribute__((constructor))
static void _zxui_init() {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        forceReplaceUI();
    });
}
