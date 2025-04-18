MIYOO_DAEMON_VERSION = 21da957cbe9e43eeceb093f7825e57592ca094b1
MIYOO_DAEMON_SITE_METHOD = git
MIYOO_DAEMON_SITE = https://github.com/MiyooCFW/daemon.git

define MIYOO_DAEMON_BUILD_CMDS
    "$(TARGET_CC)" $(@D)/main.c -o $(@D)/daemon -ggdb -lc
endef

define MIYOO_DAEMON_INSTALL_TARGET_CMDS
        $(INSTALL) -D -m 0755 $(@D)/daemon $(TARGET_DIR)/usr/bin
endef

$(eval $(generic-package))
