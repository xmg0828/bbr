#!/bin/bash
# BBR Blast Smooth - Debian 12/13 暴力平滑版
# 兼顾突发性能与稳定性 🚀

set -e

# 检查系统版本
if ! grep -q "Debian GNU/Linux 1[23]" /etc/os-release; then
  echo "❌ 本脚本仅支持 Debian 12/13"
  exit 1
fi

echo "==> 启用 BBR v1 (更稳定)"
modprobe tcp_bbr 2>/dev/null || true
echo "tcp_bbr" > /etc/modules-load.d/bbr.conf

echo "==> 写入 BBR 暴力平滑参数 (永久)"
cat >> /etc/sysctl.conf <<SYSCTL

# === BBR Blast Smooth (平滑暴力版) ===
net.core.default_qdisc=fq
net.ipv4.tcp_congestion_control=bbr

# 大缓冲区 (64MB) - 足够跑满 1G，不至于丢包卡顿
net.core.rmem_max=67108864
net.core.wmem_max=67108864
net.ipv4.tcp_rmem=4096 87380 67108864
net.ipv4.tcp_wmem=4096 65536 67108864

# 短连接 & 延迟优化
net.ipv4.tcp_fin_timeout=8
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1

# 避免保存历史 RTT，保持突发灵活
net.ipv4.tcp_no_metrics_save=1
SYSCTL

echo "==> 应用参数"
sysctl -p

echo "✅ 系统已进入 BBR Blast Smooth 模式 (平滑暴力版)"
