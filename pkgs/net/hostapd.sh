#!/bin/sh

# metadata
pkgname="hostapd"
pkgver="2.11"
pkgdesc="ip routing utilities"
pkgurl="https://w1.fi/hostapd/"
pkglic="BSD"

# build information
pkgdeps=(
    "linux-headers-6.17"
    "musl-1.2.5"
    "libnl-3.11.0"
    "openssl-3.6.0"
    "libcxx-21.1.2"
)
pkgsrcs=(
    "https://w1.fi/releases/$pkgname-$pkgver.tar.gz"
)

# build scripts
HCONF=$(cat <<'EOF'
CONFIG_DRIVER_HOSTAP=y
CONFIG_DRIVER_WIRED=y
CONFIG_DRIVER_NL80211=y
CONFIG_LIBNL32=y
CONFIG_RSN_PREAUTH=y
CONFIG_OCV=y
CONFIG_EAP=y
CONFIG_ERP=y
CONFIG_EAP_MD5=y
CONFIG_EAP_TLS=y
CONFIG_EAP_MSCHAPV2=y
CONFIG_EAP_PEAP=y
CONFIG_EAP_GTC=y
CONFIG_EAP_TTLS=y
CONFIG_EAP_SIM=y
CONFIG_EAP_AKA=y
CONFIG_EAP_PAX=y
CONFIG_EAP_PSK=y
CONFIG_EAP_SAKE=y
CONFIG_EAP_GPSK=y
CONFIG_EAP_GPSK_SHA256=y
CONFIG_WPS=y
CONFIG_WPS_UPNP=y
CONFIG_WPS_NFC=y
CONFIG_PKCS12=y
CONFIG_RADIUS_SERVER=y
CONFIG_IPV6=y
CONFIG_RADIUS_TLS=y
CONFIG_IEEE80211R=y
CONFIG_IEEE80211AC=y
CONFIG_IEEE80211AX=y
CONFIG_IEEE80211BE=y
CONFIG_SAE=y
CONFIG_SAE_PK=y
CONFIG_VLAN_NETLINK=y
CONFIG_GETRANDOM=y
CONFIG_ELOOP_EPOLL=y
CONFIG_TLS=openssl
CONFIG_TLSV11=y
CONFIG_TLSV12=y
CONFIG_INTERNAL_LIBTOMMATH=y
CONFIG_INTERNAL_LIBTOMMATH_FAST=y
CONFIG_HS20=y
CONFIG_FST=y
CONFIG_ACS=y
CONFIG_MBO=y
CONFIG_FILS=y
CONFIG_FILS_SK_PFS=y
CONFIG_WPA_CLI_EDIT=y
CONFIG_OWE=y
CONFIG_AIRTIME_POLICY=y
CONFIG_DPP=y
CONFIG_DPP2=y
CONFIG_NAN_USD=y
EOF
)

pkgprepare() {
    cd $pkgname-$pkgver/hostapd

    echo "$HCONF" > .config
}

pkgbuild() {
    make \
        CC=clang \
        CFLAGS_EXTRA="-O3" LDFLAGS="-flto"
}

pkginstall() {
    mkdir -p \
        "$pkgroot/etc/hostapd" \
        "$pkgroot/usr/bin"

    llvm-strip --strip-unneeded \
        hostapd \
        hostapd_cli

    cp -rv \
        hostapd \
        hostapd_cli \
        "$pkgroot/usr/bin/"

    cp -rv \
        hostapd.accept \
        hostapd.conf \
        hostapd.deny \
        hostapd.eap_user \
        hostapd.radius_clients \
        hostapd.vlan \
        hostapd.wpa_psk \
        "$pkgroot/etc/hostapd/"
}
