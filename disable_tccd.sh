#!/bin/bash
# ============================================================
#  TCC 永久禁用脚本（macOS Recovery 模式执行）
#  用途：用 /usr/bin/true 替换 tccd，使 TCC 权限检查失效
#  适用：实验机 / 开发机，请勿在生产机器使用
# ============================================================

set -e

# 自动检测系统盘路径（Recovery 里可能是 /Volumes/Macintosh HD 或其他名称）
SYS_VOL=""
for v in /Volumes/*; do
    if [ -d "$v/System/Library/PrivateFrameworks/TCC.framework/Support" ]; then
        SYS_VOL="$v"
        break
    fi
done

if [ -z "$SYS_VOL" ]; then
    echo "错误：找不到系统卷！当前 /Volumes/ 内容："
    ls /Volumes/
    exit 1
fi

echo "检测到系统卷：$SYS_VOL"
echo ""

TCC_D="${SYS_VOL}/System/Library/PrivateFrameworks/TCC.framework/Support/tccd"
BACKUP="${TCC_D}.bak"
TRUE_BIN="/usr/bin/true"

echo "===== Step 1: 关闭 SIP（如尚未关闭）====="
csrutil status
echo "如果上面显示 'enabled'，请先执行: csrutil disable，然后重启再进 Recovery"
echo ""

echo "===== Step 2: 重新挂载 Data 卷为可写 ====="
mount -uw "${SYS_VOL}"
echo "挂载完成"
echo ""

echo "===== Step 3: 验证 tccd 路径 ====="
if [ ! -f "${TCC_D}" ]; then
    echo "错误：找不到 tccd: ${TCC_D}"
    echo "请手动检查路径。"
    exit 1
fi
ls -l "${TCC_D}"
echo ""

echo "===== Step 4: 备份原始 tccd ====="
if [ ! -f "${BACKUP}" ]; then
    cp "${TCC_D}" "${BACKUP}"
    echo "已备份到: ${BACKUP}"
else
    echo "备份已存在，跳过"
fi
echo ""

echo "===== Step 5: 用 /usr/bin/true 替换 tccd ====="
cp "${TRUE_BIN}" "${TCC_D}"
chmod 755 "${TCC_D}"
echo "替换完成"
ls -l "${TCC_D}"
echo ""

echo "===== Step 6: 验证 ====="
echo "当前 tccd 内容（应为 Mach-O universal 可执行，但实际上是 true）："
file "${TCC_D}" 2>/dev/null || echo "(file 命令不可用，跳过)"
echo ""
echo "===== 完成！重启 Mac，TCC 将不再拦截任何权限请求 ====="
echo ""
echo "恢复方法（如需还原），在 Recovery 终端执行："
echo "  mount -uw \"${SYS_VOL}\""
echo "  mv \"${BACKUP}\" \"${TCC_D}\""
echo "  reboot"
