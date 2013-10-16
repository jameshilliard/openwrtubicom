#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

#Add target specific (nommu) flags
TARGET_CFLAGS+= -DNO_FORK

ARCH:=ubicom32
BOARD:=ubicom32
BOARDNAME:=Ubicom IPxx
FEATURES:=initramfs
SUBTARGETS=IP7160RGW

LINUX_VERSION:=2.6.30.10

include $(INCLUDE_DIR)/target.mk

DEFAULT_PACKAGES += hostapd-mini wireless-tools ntpclient genl ip tc iproute2 kmod-switch kmod-diag \
		    luci-admin-full luci-admin-mini luci-app-ntpc luci-app-firewall 

KERNEL_MAKEOPTS += LDFLAGS_BUILD_ID=""

define Target/Description
	Build firmware images for Ubicom based routers and media devices.
endef

# Select initramfs file
ifeq ($(CONFIG_TARGET_ubicom32_IP7160RGW_RouterGateway),y)
INITRAMFS_EXTRA_FILES:=$(TOPDIR)/target/linux/$(ARCH)/image/RouterGateway_initramfs_list
else
INITRAMFS_EXTRA_FILES:=$(TOPDIR)/target/linux/$(ARCH)/image/VPNGateway_initramfs_list
endif

define Kernel/Prepare
# Select kernel config file related with the selected profile
ifeq ($(CONFIG_TARGET_ubicom32_IP7160RGW_RouterGateway),y)
	ln -sf IP7160RGW/config-2.6.30.RouterGateway config-2.6.30
else 
	ln -sf IP7160RGW/config-2.6.30.VPNGateway config-2.6.30
endif
	$(call Kernel/Prepare/Default)
endef

# patches for applications residing in feeds/
# the following define will probably be needed when we are in OpenWRT trunk
# currently, we just copy apps from feeds to package directory
# current moved apps: dhcpcd, ntpclient, luci, openvpn
# define Kernel/Configure
# 	-rm $(TOPDIR)/feeds/luci/luci/patches 
# 	ln -s $(TOPDIR)/target/linux/$(ARCH)/feeds/luci/patches/ $(TOPDIR)/feeds/luci/luci/patches
# 	$(call Kernel/Configure/Default)
# endef

$(eval $(call BuildTarget))
