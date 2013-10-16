#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
# 

include $(TOPDIR)/rules.mk

PKG_NAME:=ipv6tunnel
PKG_VERSION:=1.3
PKG_RELEASE:=18

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk
ifeq ($(DUMP),)
  include $(PLATFORM_DIR)/patch_files.mk
endif

define Package/ipv6tunnel
  SECTION:=IPv6
  CATEGORY:=IPv6
  DEPENDS:=+libuci +libnl-tiny +radvd +uci +dnsmasq +dhcp4-client +dhcpv6 +ip +luci +ip6tables +ip6tables-utils +busybox +sipcalc
  TITLE:=Meta Package for IPIP6 Tunneling.
endef

TARGET_CPPFLAGS := \
	-D_GNU_SOURCE \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(LINUX_DIR)/include \
	-I$(LINUX_DIR)/arch/$(LINUX_KARCH)/include \
	-I$(PKG_BUILD_DIR) \
	$(TARGET_CPPFLAGS)

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	CFLAGS="$(TARGET_CPPFLAGS) $(TARGET_CFLAGS)" \
	$(MAKE) -C $(PKG_BUILD_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		LIBS="$(TARGET_LDFLAGS) -lnl-tiny -lm -luci -lgcc_s"
endef

define Package/ipv6tunnel/install
	$(INSTALL_DIR) $(1)/sbin 
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/i6rdcalc $(1)/sbin/i6rdcalc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/dhcpcalc $(1)/sbin/dhcpcalc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/_i6rdcalc $(1)/sbin/_i6rdcalc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/gethostbyname $(1)/sbin/resolvehostbyname
	cp -r ./files/etc $(1)/
	cp -r ./files/sbin $(1)/
	$(INSTALL_DIR) $(1)/etc/init.d/ 
	$(INSTALL_BIN) ./files/etc/init.d/tunnelscript $(1)/etc/init.d/tunnelscript
	$(INSTALL_BIN) ./files/etc/init.d/runonce $(1)/etc/init.d/runonce
endef

$(eval $(call BuildPackage,ipv6tunnel))

