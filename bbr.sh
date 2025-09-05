#!/bin/bash
# Smart BBR Blast Mode
# Debian 12 / 13 一键永久 BBR 暴力模式脚本
# 突发性能最优 ⚡

set -e

# 检查系统版本
if ! grep -q "Debian GNU/Linux 1[23]" /etc/os-release; then
  echo "❌ 本脚本仅支持 Debian 12/13"
  exit 1
fi

echo "==> 启用 BBR 模块"
modprobe tcp_bbr 2>/dev/null || true
echo "tcp_bbr" > /etc/modules-load.d/bbr.conf

echo "==> 写入 BBR 暴力模式参数 (永久)"
cat >> /etc/sysctl.conf <<SYSCTL

# === BBR 暴力模式 (Smart Blast) ===
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# 内存缓冲放大
net.core.rmem_max=134217728
net.core.wmem_max=134217728
net.ipv4.tcp_rmem=4096 87380 134217728
net.ipv4.tcp_wmem=4096 65536 134217728

# 快速回收连接
net.ipv4.tcp_fin_timeout=8
net.ipv4.tcp_tw_reuse=1

# 额外优化
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1
SYSCTL

echo "==> 立即应用参数"
sysctl -p

echo "✅ 系统已永久进入 BBR 暴力模式 (突发性能最优)"
