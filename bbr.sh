#!/bin/bash
# BBR Blast Pro - Debian 12/13 全面暴力优化版
# 突发性能最优 🚀

set -e

# 检查系统版本
if ! grep -q "Debian GNU/Linux 1[23]" /etc/os-release; then
  echo "❌ 本脚本仅支持 Debian 12/13"
  exit 1
fi

echo "==> 检查内核版本 (建议 5.9+ 支持 BBR2)"
uname -r

echo "==> 启用 BBR/BBR2 模块"
modprobe tcp_bbr 2>/dev/null || true
echo "tcp_bbr" > /etc/modules-load.d/bbr.conf

# 判断内核是否支持 bbr2
if sysctl net.ipv4.tcp_available_congestion_control | grep -q "bbr2"; then
  CONG="bbr2"
else
  CONG="bbr"
fi

echo "==> 写入暴力优化参数 (永久)"
cat >> /etc/sysctl.conf <<SYSCTL

# === BBR Blast Pro (极限模式) ===
net.core.default_qdisc=fq_codel
net.ipv4.tcp_congestion_control=$CONG

# 超大缓冲区
net.core.rmem_max=268435456
net.core.wmem_max=268435456
net.ipv4.tcp_rmem=4096 87380 268435456
net.ipv4.tcp_wmem=4096 65536 268435456

# Fast Open / 短连接优化
net.ipv4.tcp_fastopen=3
net.ipv4.tcp_fin_timeout=8
net.ipv4.tcp_tw_reuse=1

# TCP 核心优化
net.ipv4.tcp_window_scaling=1
net.ipv4.tcp_timestamps=1
net.ipv4.tcp_sack=1

# 降低延迟
net.ipv4.tcp_no_metrics_save=1
net.ipv4.tcp_mtu_probing=1
net.ipv4.tcp_low_latency=1
SYSCTL

echo "==> 系统资源限制优化 (ulimit)"
cat >> /etc/security/limits.conf <<LIMITS
* soft nofile 1048576
* hard nofile 1048576
root soft nofile 1048576
root hard nofile 1048576
LIMITS

echo "==> 应用参数"
sysctl -p

echo "✅ Debian 已进入 BBR Blast Pro 暴力模式 ($CONG)"
echo "   ⚡ 带宽突发利用率已最大化"
