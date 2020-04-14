ARCHS = arm64 arm64e

INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Ibiza

$(TWEAK_NAME)_FILES = Tweak.x
$(TWEAK_NAME)_CFLAGS = -fobjc-arc

$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = BackBoardServices

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += Prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

internal-stage::
	mkdir -p "$(THEOS_STAGING_DIR)/Library/Application Support/Ibiza.bundle"
	cp -R Resources/* "$(THEOS_STAGING_DIR)/Library/Application Support/Ibiza.bundle/"

after-install::
	install.exec "killall -9 SpringBoard"
