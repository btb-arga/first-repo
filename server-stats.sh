#!/bin/bash
#
# server-stats.sh - Analyse basic server performance stats
#

echo "==========================================="
echo "      SERVER PERFORMANCE STATISTICS"
echo "==========================================="

# OS version
echo -e "\n[OS Version]"
lsb_release -d 2>/dev/null || cat /etc/*release | head -n 1

# Uptime & Load average
echo -e "\n[Uptime & Load Average]"
uptime

# Logged in users
echo -e "\n[Logged in Users]"
who

# CPU usage
echo -e "\n[Total CPU Usage]"
mpstat 1 1 | awk '/Average/ && $2 ~ /all/ {print 100 - $NF"% used ("$NF"% idle)"}' 2>/dev/null \
    || top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"% used ("$8"% idle)"}'

# Memory usage
echo -e "\n[Memory Usage]"
free -h | awk 'NR==2{printf "Used: %s / Total: %s (%.2f%%)\n", $3,$2,$3*100/$2 }'

# Disk usage
echo -e "\n[Disk Usage]"
df -h --total | grep total | awk '{printf "Used: %s / Total: %s (%s used)\n",$3,$2,$5}'

# Top 5 processes by CPU
echo -e "\n[Top 5 Processes by CPU Usage]"
ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6

# Top 5 processes by Memory
echo -e "\n[Top 5 Processes by Memory Usage]"
ps -eo pid,comm,%cpu,%mem --sort=-%mem | head -n 6

# Failed login attempts (optional)
if [ -f /var/log/auth.log ]; then
    echo -e "\n[Failed SSH Login Attempts]"
    grep "Failed password" /var/log/auth.log | wc -l
fi

echo -e "\n==========================================="
echo "             END OF REPORT"
echo "==========================================="
