PACKAGE_VERSION = 1.4.2

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = PhotoRes
PhotoRes_FILES = Tweak.xm
PhotoRes_FRAMEWORKS = AVFoundation CoreMedia
PhotoRes_EXTRA_FRAMEWORKS = Cephei

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS = PhotoResPref

include $(THEOS_MAKE_PATH)/aggregate.mk
