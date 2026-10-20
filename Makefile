ARCHS = armv7
TARGET = iphone:clang:9.3:6.0
APPLICATION_NAME = OldRadio

OldRadio_FILES = $(wildcard *.m)
OldRadio_FRAMEWORKS = UIKit Foundation AVFoundation MediaPlayer QuartzCore AudioToolbox
OldRadio_RESOURCE_DIRS = Resources
OldRadio_CFLAGS = -fobjc-arc -Wno-deprecated-declarations
OldRadio_LDFLAGS = -Wl,-dead_strip

include $(THEOS)/makefiles/common.mk
include $(THEOS_MAKE_PATH)/application.mk

