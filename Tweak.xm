#import "Common.h"

HBPreferences *preferences;

BOOL tweakEnabled = YES;
BOOL specificSize = NO;
NSUInteger prWidth = 0;
NSUInteger prHeight = 0;
NSInteger ratioIndex = 0;
static CGSize specificRatioSize = CGSizeZero;

BOOL overrideRes;
NSInteger overrideWidth;
NSInteger overrideHeight;

static CGFloat sizes[][2] = {
    { 4, 3 }, // 1.33
    { 16, 9 }, // 1.78
    { 16, 10 }, // 1.6
    { 7, 3 }, // 2.33
    { 3, 2 }, // 1.5 (3.5-inches)
    { 5, 3 }, // 1.67
    { 5, 4 }, // 1.25
    { 11, 8 }, // 1.375
    { 1.618, 1 },
    { 1.85, 1 },
    { 2.39, 1 },
    { 1.775, 1 }, // 4-inches
    { 1, 1 }
};

static void readAspectRatio(NSInteger index) {
    specificRatioSize.width = sizes[index - 1][0];
    specificRatioSize.height = sizes[index - 1][1];
}

%group iOS10

%hook AVCapturePhotoOutput

- (FigCaptureIrisStillImageSettings *)_figCaptureIrisStillImageSettingsForAVCapturePhotoSettings:(FigCaptureStillImageSettings *)s delegate:(id)delegate connections:(NSArray *)connections {
    if (!tweakEnabled) return %orig;
    BOOL square = [[self _sanitizedSettingsForSettings:s] isSquareCropEnabled];
    if (!square) {
        AVCaptureDeviceFormat *format = [(AVCaptureConnection *)connections[0] sourceDevice].activeFormat;
        CMVideoDimensions res = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        NSUInteger width = res.width;
        NSUInteger height = res.height;
        CGRect boundingOriginalRect = CGRectMake(0, 0, width, height);
        CGRect myRes = specificSize ? CGRectMake(0, 0, prWidth, prHeight) : boundingOriginalRect;
        if (ratioIndex != 0)
            myRes = AVMakeRectWithAspectRatioInsideRect(specificRatioSize, myRes);
        if (specificSize || ratioIndex != 0) {
            overrideRes = YES;
            overrideWidth = myRes.size.width;
            overrideHeight = myRes.size.height;
            FigCaptureIrisStillImageSettings *settings = %orig;
            overrideRes = NO;
            return settings;
        }
    }
    return %orig;
}

%end

%end

%group iOS9Up

%hook FigCaptureIrisStillImageSettings

- (void)setOutputWidth:(NSInteger)width {
    %orig(overrideRes ? overrideWidth : width);
}

- (void)setOutputHeight:(NSInteger)height {
    %orig(overrideRes ? overrideHeight : height);
}

%end

%hook CAMViewfinderViewController

%property(retain, nonatomic) UILongPressGestureRecognizer *prGesture;

- (void)_createFlipButtonIfNecessary {
    %orig;
    if (tweakEnabled && self.prGesture == nil) {
        self.prGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(pr_displayDialog:)];
        [[self valueForKey:@"__flipButton"] addGestureRecognizer:self.prGesture];
    }
}

%new
- (void)pr_displayDialog:(UILongPressGestureRecognizer *)gesture {
    if (tweakEnabled && gesture.state == UIGestureRecognizerStateEnded) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"PhotoRes+" message:@"Select ratio" preferredStyle:UIAlertControllerStyleAlert];
        for (NSInteger i = 0; i < 13; ++i) {
            if (ratioIndex == i + 1)
                continue;
            UIAlertAction *action = [UIAlertAction actionWithTitle:[NSString stringWithFormat:@"%g:%g", sizes[i][0], sizes[i][1]] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                readAspectRatio(ratioIndex = i + 1);
                [preferences setInteger:ratioIndex forKey:ratioIndexKey];
            }];
            [alert addAction:action];
        }
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
	    [alert addAction:defaultAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

%end

%hook AVCaptureIrisStillImageOutput

- (FigCaptureIrisStillImageSettings *)_figCaptureIrisStillImageSettingsForAVCaptureIrisStillImageSettings:(FigCaptureStillImageSettings *)s connections:(NSArray *)connections {
    if (!tweakEnabled) return %orig;
    BOOL square = [self _sanitizedSettingsForSettings:s].squareCropEnabled;
    if (!square) {
        AVCaptureDeviceFormat *format = [(AVCaptureConnection *) connections[0] sourceDevice].activeFormat;
        CMVideoDimensions res = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        NSUInteger width = res.width;
        NSUInteger height = res.height;
        CGRect boundingOriginalRect = CGRectMake(0, 0, width, height);
        CGRect myRes = specificSize ? CGRectMake(0, 0, prWidth, prHeight) : boundingOriginalRect;
        if (ratioIndex != 0)
            myRes = AVMakeRectWithAspectRatioInsideRect(specificRatioSize, myRes);
        if (specificSize || ratioIndex != 0) {
            overrideRes = YES;
            overrideWidth = myRes.size.width;
            overrideHeight = myRes.size.height;
            FigCaptureIrisStillImageSettings *settings = %orig;
            overrideRes = NO;
            return settings;
        }
    }
    return %orig;
}

%end

%end


%group iOS8

%hook AVCaptureStillImageOutput

- (FigCaptureStillImageSettings *)_figCaptureStillImageSettingsForConnection:(AVCaptureConnection *)connection {
    if (!tweakEnabled) return %orig;
    BOOL square = self.squareCropEnabled;
    if (!square) {
        AVCaptureDeviceFormat *format = [connection sourceDevice].activeFormat;
        CMVideoDimensions res = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        NSUInteger width = res.width;
        NSUInteger height = res.height;
        CGRect boundingOriginalRect = CGRectMake(0, 0, width, height);
        CGRect myRes = specificSize ? CGRectMake(0, 0, prWidth, prHeight) : boundingOriginalRect;
        if (ratioIndex != 0)
            myRes = AVMakeRectWithAspectRatioInsideRect(specificRatioSize, myRes);
        if (specificSize || ratioIndex != 0) {
            overrideRes = YES;
            overrideWidth = myRes.size.width;
            overrideHeight = myRes.size.height;
            FigCaptureStillImageSettings *settings = %orig;
            overrideRes = NO;
            return settings;
        }
    }
    return %orig;
}

%end

%hook FigCaptureStillImageSettings

- (void)setOutputWidth:(NSInteger)width {
    %orig(overrideRes ? overrideWidth : width);
}

- (void)setOutputHeight:(NSInteger)height {
    %orig(overrideRes ? overrideHeight : height);
}

%end

%end

BOOL overridePreviewSize;
CGSize prPreviewSize = CGSizeZero;

NSMutableDictionary *hookCaptureOptions(NSMutableDictionary *orig) {
    NSString *prefix = orig[@"OverridePrefixes"];
    if ([prefix isEqualToString:@"P:"]) {
        NSUInteger width = [[orig valueForKeyPath:@"LiveSourceOptions.Capture.Width"] integerValue];
        NSUInteger height = [[orig valueForKeyPath:@"LiveSourceOptions.Capture.Height"] integerValue];
        CGRect boundingOriginalRect = CGRectMake(0, 0, width, height);
        CGRect myRes = specificSize ? CGRectMake(0, 0, prWidth, prHeight) : boundingOriginalRect;
        if (ratioIndex != 0)
            myRes = AVMakeRectWithAspectRatioInsideRect(specificRatioSize, myRes);
        if (specificSize || ratioIndex != 0) {
            NSInteger newWidth = myRes.size.width;
            NSInteger newHeight = myRes.size.height;
            [orig setValue:@(newWidth) forKeyPath:@"LiveSourceOptions.Capture.Width"];
            [orig setValue:@(newHeight) forKeyPath:@"LiveSourceOptions.Capture.Height"];
            [orig setValue:@(newWidth) forKeyPath:@"LiveSourceOptions.Sensor.Width"];
            [orig setValue:@(newHeight) forKeyPath:@"LiveSourceOptions.Sensor.Height"];
        }
    }
    return orig;
}

%group iOS78

%hook AVCaptureSession

+ (NSMutableDictionary *)_createCaptureOptionsForPreset:(id)preset audioDevice:(id)audio videoDevice:(id)video errorStatus:(int *)error {
    return tweakEnabled ? hookCaptureOptions(%orig) : %orig;
}

%end

%end

%group preiOS8

%hook AVCaptureStillImageOutput

- (void)configureAndInitiateCopyStillImageForRequest:(AVCaptureStillImageRequest *)request {
    if (!tweakEnabled) { %orig; return; }
    if ([self respondsToSelector:@selector(squareCropEnabled)])
        overrideRes = !self.squareCropEnabled;
    else
        overrideRes = YES;
    if (overrideRes) {
        AVCaptureDevice *captureDevice = [[self firstActiveConnection] sourceDevice];
        AVCaptureDeviceFormat *format = captureDevice.activeFormat;
        CMVideoDimensions res = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        NSUInteger width = res.width;
        NSUInteger height = res.height;
        CGRect boundingOriginalRect = CGRectMake(0, 0, width, height);
        CGRect myRes = specificSize ? CGRectMake(0, 0, prWidth, prHeight) : boundingOriginalRect;
        if (ratioIndex != 0)
            myRes = AVMakeRectWithAspectRatioInsideRect(specificRatioSize, myRes);
        if (specificSize || ratioIndex != 0) {
            CGRect previewRes = CGRectMake(0, 0, self.previewImageSize.width, self.previewImageSize.height);
            CGRect cropPreviewRes = AVMakeRectWithAspectRatioInsideRect(specificRatioSize, previewRes);
            self.previewImageSize = cropPreviewRes.size;
            prPreviewSize = cropPreviewRes.size;
            %orig;
            overrideRes = NO;
            return;
        }
    }
    %orig;
    overrideRes = NO;
}

%end

%end

%group iOS7Up

%hook PLAssetFormats

+ (CGSize)scaledSizeForSize:(CGSize)size format:(NSInteger)format capLength:(BOOL)capLength {
    if (tweakEnabled && overridePreviewSize && !CGSizeEqualToSize(prPreviewSize, CGSizeZero))
        size = prPreviewSize;
    return %orig(size, format, capLength);
}

%end

%end

%group preiOS7

%hook AVCaptureSession

- (NSMutableDictionary *)_createCaptureOptionsForPreset:(id)preset audioDevice:(id)audio videoDevice:(id)video errorStatus:(int *)error {
    return tweakEnabled ? hookCaptureOptions(%orig) : %orig;
}

%end

%hook PLAssetFormats

+ (CGSize)sizeForFormat:(NSInteger)format {
    if (tweakEnabled && overridePreviewSize && !CGSizeEqualToSize(prPreviewSize, CGSizeZero)) {
        // kill a check from /System/Library/Lockdown/Checkpoint.xml !
        CGSize correctPreviewSize = CGSizeMake(0.5 * prPreviewSize.width, 0.5 * prPreviewSize.height);
        return correctPreviewSize;
    }
    return %orig;
}

%end

%hook PLCameraView

- (void)_preparePreviewWellImage:(UIImage *)image isVideo:(BOOL)isVideo {
    overridePreviewSize = tweakEnabled && !isVideo;
    %orig;
    overridePreviewSize = NO;
}

%end

%end

%group iOS71

%hook PLCameraController

- (void)_processCapturedPhotoWithDictionary:(id)dictionary error:(id)error HDRUsed:(BOOL)hdr {
    overridePreviewSize = tweakEnabled;
    %orig;
    overridePreviewSize = NO;
}

%end

%end

%group preiOS71

%hook PLCameraController

- (void)_processCapturedPhotoWithDictionary:(id)dictionary error:(id)error {
    overridePreviewSize = tweakEnabled;
    %orig;
    overridePreviewSize = NO;
}

%end

%end

%ctor {
    if (IN_SPRINGBOARD && isiOS7Up)
        return;
    preferences = [[HBPreferences alloc] initWithIdentifier:tweakIdentifier];
    [preferences registerBool:&tweakEnabled default:YES forKey:tweakKey];
    [preferences registerBool:&specificSize default:NO forKey:specificSizeKey];
    [preferences registerUnsignedInteger:&prWidth default:0 forKey:widthKey];
    [preferences registerUnsignedInteger:&prHeight default:0 forKey:heightKey];
    [preferences registerInteger:&ratioIndex default:0 forKey:ratioIndexKey];
    [preferences registerPreferenceChangeBlock:^void (NSString *key, id value) {
        readAspectRatio([value integerValue]);
    } forKey:ratioIndexKey];
    readAspectRatio(ratioIndex);
    if (isiOS8Up) {
        if (isiOS9Up) {
            if (isiOS10Up) {
                %init(iOS10);
            }
            %init(iOS9Up);
        } else {
            %init(iOS8);
        }
    } else {
        %init(preiOS8);
        if (isiOS7Up) {
            %init(iOS7Up);
            if (isiOS71Up) {
                %init(iOS71);
            } else {
                %init(preiOS71);
            }
        } else {
            %init(preiOS7);
        }
    }
    if (isiOS78) {
        %init(iOS78);
    }
}

%dtor {
    [preferences release];
}