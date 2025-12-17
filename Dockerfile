FROM openwrt/rootfs:x86_64-23.05.3

LABEL maintainer="koswu"

# Define environment variables for network configuration
ENV UU_LAN_IPADDR=
ENV UU_LAN_GATEWAY=
ENV UU_LAN_NETMASK="255.255.255.0"
ENV UU_LAN_DNS="119.29.29.29"

USER root

# Create lock directory and update package list
RUN mkdir -p /var/lock && opkg update

# Install dependencies
RUN opkg install libustream-mbedtls ca-certificates kmod-tun

# Setup uu_prepare script
ADD uu_prepare /etc/init.d/uu_prepare
RUN sed -i 's/\r$//' /etc/init.d/uu_prepare && \
    chmod +x /etc/init.d/uu_prepare && \
    /etc/init.d/uu_prepare enable

# Download and install the latest UU Plugin IPK
# Note: We use the release API to find the URL or fixed URL structure if stable.
# Since the user wants to "fetching latest ipk", we can do this in the build step OR in the runtime script.
# However, doing it in the build step produces a fixed image. Doing it in runtime allows "latest" on restart.
# The user said "build a project that can get the latest ipk from the second repo's release and package docker image".
# This implies build-time fetching.
ARG UU_VERSION=latest

# We use wget to fetch the IPK. The latest release tag is 'latest'.
# URL pattern: https://github.com/ttc0419/uuplugin/releases/download/latest/uuplugin_latest-1_x86_64.ipk
# If we want to be dynamic to the 'latest' release, we can stick to this URL.
RUN wget https://github.com/ttc0419/uuplugin/releases/download/latest/uuplugin_latest-1_x86_64.ipk -O /tmp/uuplugin.ipk \
    && opkg install /tmp/uuplugin.ipk \
    && rm /tmp/uuplugin.ipk

# Configure firewall defaults to ACCEPT
RUN uci set firewall.@defaults[0].input='ACCEPT' \
    && uci set firewall.@defaults[0].output='ACCEPT' \
    && uci set firewall.@defaults[0].forward='ACCEPT' \
    && uci commit firewall

# Disable unnecessary services to keep the container light
RUN /etc/init.d/odhcpd disable \
    && /etc/init.d/uhttpd disable \
    && /etc/init.d/dropbear disable

# The init process
CMD ["/sbin/init"]
