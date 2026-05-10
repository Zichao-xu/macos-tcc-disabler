# macos-tcc-disabler

在 macOS 实验机上永久禁用 TCC（Transparency, Consent, and Control）守护进程，使所有权限请求（完全磁盘访问、屏幕录制、摄像头等）自动通过。

## ⚠️ 警告

- **仅用于实验机、开发机、CI 机器**
- 禁用 TCC 后，任意应用可无提示访问所有文件、摄像头、麦克风、通讯录
- **切勿在生产机器或日常使用的 Mac 上运行**

## 原理

用 `/usr/bin/true`（空操作二进制）替换 `/System/Library/PrivateFrameworks/TCC.framework/Support/tccd`，使 TCC 守护进程启动时立即退出，macOS 权限检查失效。

## 使用方法

### 一键执行（推荐）

在 **macOS Recovery 模式** 终端中执行：

```bash
# Apple Silicon：重启按住电源键；Intel：重启按住 Command+R
# 进入 Recovery 后，打开 实用工具 → 终端，执行：

curl -fsSL https://raw.githubusercontent.com/Zichao-xu/macos-tcc-disabler/main/disable_tccd.sh | bash
```

### 手动执行

1. 进入 **Recovery 模式**
   - Apple Silicon：重启，长按电源键至"正在载入启动选项"出现
   - Intel Mac：重启，立即按住 `Command+R`

2. 打开顶部菜单 → **实用工具** → **终端**

3. 执行脚本：
   ```bash
   /Volumes/Macintosh\ HD/Users/$(ls /Volumes/Macintosh\ HD/Users/ | head -1)/Desktop/disable_tccd.sh
   ```
   （路径根据实际系统盘名称调整，用 `ls /Volumes/` 查看）

4. 重启

## 验证

重启后执行：
```bash
ps aux | grep tccd | grep -v grep
# 无输出 = tccd 已被禁用（正常）
```

## 恢复（还原 tccd）

1. 进入 Recovery 模式
2. 打开终端，执行：
   ```bash
   mount -uw /Volumes/Data
   mv /Volumes/Data/System/Library/PrivateFrameworks/TCC.framework/Support/tccd.bak \
      /Volumes/Data/System/Library/PrivateFrameworks/TCC.framework/Support/tccd
   reboot
   ```
3. 重启后 TCC 恢复正常

## 适用版本

- macOS Ventura (13) 及以上
- 已在 macOS Tahoe 26 验证
- Apple Silicon / Intel 均适用

## 文件说明

| 文件 | 说明 |
|------|------|
| `disable_tccd.sh` | Recovery 模式执行的禁用脚本 |
| `disable_tccd.sh.sig` | 脚本签名（如有） |

## License

MIT — 仅供实验用途，作者不对任何后果负责。
