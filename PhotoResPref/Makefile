TARGET = iphone:clang:11.2:6.0

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = PhotoResSettings
PhotoResSettings_FILES = PhotoResPreferenceController.m
PhotoResSettings_INSTALL_PATH = /Library/PreferenceBundles
PhotoResSettings_PRIVATE_FRAMEWORKS = Preferences
PhotoResSettings_EXTRA_FRAMEWORKS = Cephei CepheiPrefs
PhotoResSettings_FRAMEWORKS = AVFoundation

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/PhotoRes.plist$(ECHO_END)
	$(ECHO_NOTHING)find $(THEOS_STAGING_DIR) -name .DS_Store | xargs rm -rf$(ECHO_END)
