FROM openwrt/rootfs:x86_64-23.05.3

LABEL maintainer="koswu"

# Define environment variables for network configuration
ENV UU_LAN_IPADDR=
ENV UU_LAN_GATEWAY=
ENV UU_LAN_NETMASK="255.255.255.0"
ENV UU_LAN_DNS="119.29.29.29"
# Ensure /usr/sbin and /usr/local/sbin are in PATH
ENV PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

USER root

# Create lock directory and update package list
RUN mkdir -p /var/lock && opkg update

# Install dependencies
RUN opkg install libustream-mbedtls ca-certificates kmod-tun iptables-nft

# Setup uu_prepare script
ADD uu_prepare /etc/init.d/uu_prepare
RUN sed -i 's/\r$//' /etc/init.d/uu_prepare && \
    chmod +x /etc/init.d/uu_prepare && \
    /etc/init.d/uu_prepare enable

# Fetch and install the latest UU Plugin from the API
RUN opkg install curl jq && \
    url=$(curl -s "https://router.uu.163.com/api/plugin?type=openwrt-x86_64" | jq -r '.url') && \
    echo "Downloading UU Plugin from $url" && \
    wget -q "$url" -O /tmp/uu.tar.gz && \
    tar -xzf /tmp/uu.tar.gz -C /tmp && \
    mv /tmp/uu.conf /etc/uu.conf && \
    mkdir -p /usr/local/sbin && \
    mv /tmp/uuplugin /usr/local/sbin/uuplugin && \
    mv /tmp/xtables-nft-multi /usr/local/sbin/xtables-nft-multi && \
    chmod +x /usr/local/sbin/uuplugin /usr/local/sbin/xtables-nft-multi && \
    rm /tmp/uu.tar.gz && \
    opkg remove jq

# Configure firewall defaults to ACCEPT
RUN uci set firewall.@defaults[0].input='ACCEPT' \
    && uci set firewall.@defaults[0].output='ACCEPT' \
    && uci set firewall.@defaults[0].forward='ACCEPT' \
    && uci commit firewall

# Disable unnecessary services to keep the container light
RUN /etc/init.d/odhcpd disable \
    && /etc/init.d/uhttpd disable \
    && /etc/init.d/dropbear disable \
    && /etc/init.d/firewall disable

# The init process
CMD ["/sbin/init"]
