#!/bin/sh
# Allow IP masquerading through this box
# iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -I POSTROUTING -t nat -o $HS_WANIF -j MASQUERADE