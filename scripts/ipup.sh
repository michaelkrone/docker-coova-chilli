#!/bin/sh
# Allow IP masquerading through this box
/usr/sbin/iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE