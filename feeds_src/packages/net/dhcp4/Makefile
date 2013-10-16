#
# Copyright (C) 2006-2008 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
# $Id: Makefile 12175 2008-08-05 22:04:10Z florian $

include $(TOPDIR)/rules.mk

PKG_NAME:=dhcp
#PKG_VERSION:=4.1.0
PKG_VERSION:=4.1.1
PKG_RELEASE:=2

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=ftp://ftp.isc.org/isc/dhcp/dhcp-4.1-history
#PKG_MD5SUM:=32dfd15f03f616936466a7e32332c1c4
PKG_MD5SUM:=38a74c89d8913b9b5f33737047623c18

include $(INCLUDE_DIR)/package.mk

CONFIGURE_ARGS += ac_cv_file__dev_random=yes
ifeq ($(CONFIG_PACKAGE_dhcpv6),y)
  CONFIGURE_ARGS += --enable-dhcpv6
else
  CONFIGURE_ARGS += --disable-dhcpv6
endif

define Package/dhcp4/Default
  SECTION:=net
  CATEGORY:=Network
  TITLE:=ISC's DHCP
  SUBMENU:=isc-dhcp
  URL:=http://www.isc.org/
endef

define Package/dhcpv6
  $(call Package/dhcp4/Default)
  TITLE:=IPv6 support
  DEPENDS:=+kmod-ipv6
endef

define Package/dhcpv6/description
	This enables DHCPv6 support in all configured DHCP apps.
endef

define Package/dhcp4-relay
  $(call Package/dhcp4/Default)
  TITLE+= relay agent
endef

define Package/dhcp4-server
  $(call Package/dhcp4/Default)
  TITLE+= server
endef

define Package/dhcp4-client
  $(call Package/dhcp4/Default)
  TITLE+= client
endef


define Build/Compile	
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install-exec
endef


define Package/dhcp4-relay/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dhcrelay $(1)/usr/sbin/
endef

define Package/dhcp4-server/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dhcpd $(1)/usr/sbin/
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/omshell $(1)/usr/bin/
	$(INSTALL_DATA) $(PKG_INSTALL_DIR)/usr/lib/*.a $(1)/usr/lib
	$(INSTALL_BIN) ./files/dhcpd.init $(1)/etc/init.d/dhcpd
	$(INSTALL_BIN) ./files/dhcpd.conf $(1)/etc
ifeq ($(CONFIG_PACKAGE_dhcpv6),y)
	$(INSTALL_BIN) ./files/dhcpd6.init $(1)/etc/init.d/dhcpd6
	$(INSTALL_BIN) ./files/dhcpd6.conf $(1)/etc
endif
endef

define Package/dhcp4-client/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/sbin/dhclient $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dhclient-script $(1)/usr/sbin/
	$(INSTALL_BIN) ./files/dhclient.init $(1)/etc/init.d/dhclient
ifeq ($(CONFIG_PACKAGE_dhcpv6),y)
	$(INSTALL_BIN) ./files/dhclient6.init $(1)/etc/init.d/dhclient6
endif
endef


$(eval $(call BuildPackage,dhcpv6))
$(eval $(call BuildPackage,dhcp4-relay))
$(eval $(call BuildPackage,dhcp4-server))
$(eval $(call BuildPackage,dhcp4-client))
