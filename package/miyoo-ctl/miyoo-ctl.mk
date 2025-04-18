MIYOO_CTL_VERSION = ac6993e8cde2f03640aaff648c50d6c7c4626357
MIYOO_CTL_SITE_METHOD = git
MIYOO_CTL_SITE = https://github.com/MiyooCFW/miyooctl.git

define MIYOO_CTL_BUILD_CMDS
    "$(TARGET_CC)" $(@D)/main.c -o $(@D)/miyooctl
endef

define MIYOO_CTL_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/miyooctl $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
