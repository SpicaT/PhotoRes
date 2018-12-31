#import <AVFoundation/AVFoundation.h>
#import <Cephei/HBPreferences.h>
#import "../PS.h"

NSString *const tweakKey = @"PREnabled";
NSString *const widthKey = @"PRWidth";
NSString *const heightKey = @"PRHeight";
NSString *const ratioIndexKey = @"PRRatioIndex";
NSString *const specificSizeKey = @"PRSpecificSize";

NSString *tweakIdentifier = @"com.PS.PhotoRes";

@interface FigCaptureStillImageSettings : NSObject
- (BOOL)isSquareCropEnabled;
- (BOOL)squareCropEnabled;
@end

@interface AVCaptureOutput (Addition)
- (FigCaptureStillImageSettings *)_sanitizedSettingsForSettings:(FigCaptureStillImageSettings *)settings;
@end

@interface AVCaptureDeviceFormat (Addition)
- (CMVideoDimensions)sensorDimensions;
@end

@interface CAMViewfinderViewController : UIViewController
@property(retain, nonatomic) UILongPressGestureRecognizer *prGesture;
@end