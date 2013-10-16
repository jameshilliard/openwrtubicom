#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/RouterGateway
  NAME:=RouterGateway
  PACKAGES:=pptp portmap luci-app-samba
endef

define Profile/RouterGateway/Description
	Ubicom RouterGateway Profile
endef
$(eval $(call Profile,RouterGateway))

