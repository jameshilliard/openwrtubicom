#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=sipcalc
PKG_VERSION:=1.1.5
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=http://www.routemeister.net/projects/sipcalc/files \
		http://download.google.com/mirror
PKG_MD5SUM:=8d59e70d21d8f0568e310d342e3e2306

include $(INCLUDE_DIR)/package.mk

define Package/sipcalc
  SECTION:=ipv6
  CATEGORY:=IPv6
  TITLE:=IPv6 IPv4 Calculation Program
  URL:=http://www.routemeister.net/projects/sipcalc/
  DEPENDS:=+kmod-ipv6
endef

define Package/sipcalc/description
IPv6 IPv4 Calculation Program.
endef

define Build/Configure
	$(call Build/Configure/Default,\
		--with-pidfile=/var/run/sipcalc.pid \
	)
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		sipcalc_LDADD=""
endef

#define Package/sipcalc/conffiles
#/etc/config/sipcalc
#endef

define Package/sipcalc/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/sipcalc $(1)/sbin/	
endef

$(eval $(call BuildPackage,sipcalc))
