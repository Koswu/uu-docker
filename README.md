# UU 加速器插件 Docker 镜像

本项目基于 OpenWrt (x86_64) 构建网易 UU 加速器插件的 Docker 镜像。构建过程中会自动从 [ttc0419/uuplugin](https://github.com/ttc0419/uuplugin) 获取最新的插件包。

## 特性

- **基础镜像**: OpenWrt (x86_64)
- **开箱即用**: 镜像定期构建并发布，无需手动编译。
- **易于配置**: 通过环境变量设置网络参数。

## 快速开始

### 1. 创建配置文件

直接下载或复制项目中的 [docker-compose.yml](docker-compose.yml) 文件。

> **注意**:
> 1. 请务必根据你的实际网络环境修改 `parent` (物理网卡名称), `subnet` (子网), `gateway` (网关) 和 `ipv4_address` (IP地址)。
> 2. `UU_LAN_IPADDR` 环境变量应与 `ipv4_address` 保持一致。
> 3. Macvlan 模式下，宿主机通常无法直接 ping 通容器 IP，这是正常现象。
> 4. 查询网卡名称命令: `ip addr` 或 `ifconfig`。

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
