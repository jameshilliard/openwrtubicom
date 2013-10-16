#
# Copyright (C) 2006 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

define Profile/VPNGateway
  NAME:=VPNGateway
  PACKAGES:=openswan openvpn portmap
endef

define Profile/VPNGateway/Description
	Ubicom VPNGateway Profile
endef
$(eval $(call Profile,VPNGateway))

