# UU 加速器插件 Docker 镜像

本项目基于 OpenWrt (x86_64) 构建网易 UU 加速器插件的 Docker 镜像。构建过程中会自动从 [ttc0419/uuplugin](https://github.com/ttc0419/uuplugin) 获取最新的插件包。

## 特性

- **基础镜像**: OpenWrt (x86_64)
- **开箱即用**: 镜像定期构建并发布，无需手动编译。
- **易于配置**: 通过环境变量设置网络参数。

## 快速开始

### 1. 创建配置文件

新建一个 `docker-compose.yml` 文件，填入以下内容：

```yaml
services:
  uuplugin:
    image: koswu/uuplugin:latest
    container_name: uuplugin
    restart: always
    network_mode: "host"
    privileged: true
    cap_add:
      - NET_ADMIN
    environment:
      - UU_LAN_IPADDR=192.168.1.100 # 请修改为分配给插件的 IP (需与主路由同网段)
      - UU_LAN_GATEWAY=192.168.1.1  # 请修改为你的主路由 IP
```

> **注意**: 默认网络模式为 `host`，这是最简单的配置方式。如果你需要更复杂的网络拓扑（如 macvlan），请自行调整。

### 2. 启动

在文件所在目录下运行：

```bash
docker-compose up -d
```

Docker 会自动拉取最新的 `koswu/uuplugin:latest` 镜像并启动。

### 3. 验证

启动后，打开手机或电脑端的 UU 主机加速 App，此时应该能检测到局域网内的插件并进行绑定。

## 致谢

- [dianqk/uuplugin](https://github.com/dianqk/uuplugin): 提供原始 Docker 封装思路。
- [ttc0419/uuplugin](https://github.com/ttc0419/uuplugin): 提供适配最新 OpenWrt 的插件包。
