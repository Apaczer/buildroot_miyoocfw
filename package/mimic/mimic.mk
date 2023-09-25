################################################################################
#
# mimic
#
################################################################################

MIMIC_VERSION = 1.3.0.1
MIMIC_SITE = $(call github,MycroftAI,mimic1,$(MIMIC_VERSION))
MIMIC_LICENSE = MIT
MIMIC_LICENSE_FILES = COPYING

+MIMIC_AUTORECONF = YES
+MIMIC_DEPENDENCIES = host-pkgconf host-automake host-autoconf host-libtool

ifeq ($(BR2_PACKAGE_MIMIC_AUDIO_BACKEND_ALSA),y)
MIMIC_AUDIO_BACKEND = alsa
MIMIC_DEPENDENCIES += alsa-lib
else ifeq ($(BR2_PACKAGE_MIMIC_AUDIO_BACKEND_PORTAUDIO),y)
MIMIC_AUDIO_BACKEND = portaudio
MIMIC_DEPENDENCIES += portaudio
else ifeq ($(BR2_PACKAGE_MIMIC_AUDIO_BACKEND_PULSEAUDIO),y)
MIMIC_AUDIO_BACKEND = pulseaudio
MIMIC_DEPENDENCIES += pulseaudio
else ifeq ($(BR2_PACKAGE_MIMIC_AUDIO_BACKEND_NONE),y)
MIMIC_AUDIO_BACKEND = none
endif

define MIMIC_RUN_AUTOGEN
        cd $(@D) && PATH=$(BR_PATH) ./autogen.sh
endef

MIMIC_PRE_CONFIGURE_HOOKS += MIMIC_RUN_AUTOGEN

MIMIC_CONF_OPTS += --disable-voices-all --enable-cmu_us_kal --with-audio=$(MIMIC_AUDIO_BACKEND)

$(eval $(autotools-package))
