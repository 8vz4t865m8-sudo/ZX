#import <UIKit/UIKit.h>
#import <objc/runtime.h>

typedef BOOL (*initRsa_t)(id, SEL, NSString*, NSString*, NSString*, NSString*, NSString*, NSString*, NSError**);
static initRsa_t orig_initRsa = NULL;

static BOOL hook_initRsa(id self, SEL _cmd,
                         NSString *loginCode,
                         NSString *noticeCode,
                         NSString *versionCode,
                         NSString *heartbeatCode,
                         NSString *appkey,
                         NSString *rsaPublicKey,
                         NSError **error) {
    return orig_initRsa(self, _cmd,
        @"B9F97729EC64A6C9",
        @"9E37BB60E3AFFCEE",
        @"2A78BD88E7376215",
        @"168AA83248396F84",
        @"15cab0658474ff4a93ebd8ab8337dab0",
        @"-----BEGIN PUBLIC KEY-----\n"
         "MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCxj7u3l9DKEyaluMG11BVdfg5z\n"
         "/6ieD1iwGzl6txP5G6nAEPxU3BzdEvI4Z20AOAJoGdmflpDq947lgp+tG61G8DeK\n"
         "ZLsZWb9t18+L/ThZCCv1xWxb5Llr4mt9yUh5IPHwl5Zy8nxWL64onFJaRIrif+JR\n"
         "U0sEt6p3P7lCc3JkPwIDAQAB\n"
         "-----END PUBLIC KEY-----",
        error);
}

__attribute__((constructor))
static void _zx_init() {
    Class t3Class = NSClassFromString(@"T3Verify");
    if (!t3Class) return;
    SEL sel = @selector(initRsaWithLoginCode:noticeCode:versionCode:heartbeatCode:appkey:rsaPublicKey:error:);
    Method m = class_getInstanceMethod(t3Class, sel);
