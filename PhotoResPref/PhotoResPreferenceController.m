#import <UIKit/UIKit.h>
#import <Preferences/PSSpecifier.h>
#import <CepheiPrefs/HBListController.h>
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <substrate.h>
#import "../Common.h"
#import "../../PSPrefs/PSPrefs.x"
#import <dlfcn.h>

@interface PhotoResPreferenceController : HBListController {
    HBPreferences *preferences;
}
@end

@implementation PhotoResPreferenceController

+ (NSString *)hb_specifierPlist {
    return @"PhotoRes";
}

- (instancetype)init {
    if (self == [super init]) {
        HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
        appearanceSettings.tintColor = UIColor.magentaColor;
        appearanceSettings.tableViewCellTextColor = UIColor.redColor;
        self.hb_appearanceSettings = appearanceSettings;
        preferences = [[HBPreferences alloc] initWithIdentifier:tweakIdentifier];
    }
    return self;
}

- (CGSize)resolutionFromAVCaptureDeviceFormat:(AVCaptureDeviceFormat *)format {
    CGSize res = CGSizeZero;
    if (isiOS8Up) {
        CMVideoDimensions dimension8 = format.highResolutionStillImageDimensions;
        res = (CGSize) {
            dimension8.width, dimension8.height
        };
    } else if (isiOS7) {
        CMVideoDimensions dimension7 = [format sensorDimensions];
        res = (CGSize) {
            dimension7.width, dimension7.height
        };
    } else {
        AVCaptureDeviceFormatInternal *internal6;
        object_getInstanceVariable(format, "_internal", (void **)&internal6);
        NSDictionary *resDict6;
        object_getInstanceVariable(internal6, "formatDictionary", (void **)&resDict6);
        res = (CGSize) {
            [resDict6[@"Width"] intValue], [resDict6[@"Height"] intValue]
        };
    }
    return res;
}

- (CGSize)bestPhotoResolution {
    NSUInteger pixels = 0;
    NSUInteger index = 0;
    NSArray *formats = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo].formats;
    for (AVCaptureDeviceFormat *format in formats) {
        CGSize dimension = [self resolutionFromAVCaptureDeviceFormat:format];
        NSUInteger eachPixels = dimension.width * dimension.height;
        if (eachPixels > pixels) {
            eachPixels = pixels;
            index = [formats indexOfObject:format];
        }
    }
    AVCaptureDeviceFormat *bestFormat = formats[index];
    return [self resolutionFromAVCaptureDeviceFormat:bestFormat];
}

- (void)setResValue:(id)value specifier:(PSSpecifier *)spec {
    NSUInteger val = [value intValue];
    NSString *key = spec.properties[@"key"];
    CGSize bestRes = [self bestPhotoResolution];
    NSUInteger bestWidth = (NSUInteger)bestRes.width;
    NSUInteger bestHeight = (NSUInteger)bestRes.height;
    if ([key isEqualToString:widthKey]) {
        if (val > bestWidth)
            val = bestWidth;
    } else if ([key isEqualToString:heightKey]) {
        if (val > bestHeight)
            val = bestHeight;
    }
    [preferences setInteger:val forKey:key];
    DoPostNotification();
    [self reloadSpecifier:spec animated:NO];
}

HaveBanner2(@"PhotoRes+", UIColor.magentaColor, @"Photos at any sizes", UIColor.redColor)

@end
