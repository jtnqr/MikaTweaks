#!/bin/sh

# Check if the Android system has fully booted
resetprop -w sys.boot_completed 0

# AVC Denial Fix: Adjust security policies to allow certain apps to access /proc/tcp and execute permissions
magiskpolicy --live 'allow untrusted_app proc_net_tcp_udp file {read write open getattr}'
magiskpolicy --live 'allow untrusted_app app_data_file file {read write open getattr execute execute_no_trans}'

# Unity Big.Little CPU Frequency Trick:
# Prevent specific CPU cores from reporting their maximum frequency and capacity to avoid throttling
# This helps optimize performance for Unity-based games, like miHoYo and Activision games.
i=0
while [ $i -lt 8 ]; do
    chmod 000 /sys/devices/system/cpu/cpu$i/cpufreq/cpuinfo_max_freq   # Hide max frequency for CPU core $i
    chmod 000 /sys/devices/system/cpu/cpu$i/cpu_capacity               # Hide CPU capacity for core $i
    chmod 000 /sys/devices/system/cpu/cpu$i/topology/physical_package_id # Hide physical package ID for core $i
    i=$((i + 1))
done

# Disable core control for CPU core 0
# This prevents the system from limiting the usage of core 0, improving multi-core performance
echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/enable

# Report fake max frequency settings to specific applications (Unity and related games)
# This forces the scheduler to prioritize performance for games and Unity apps by tricking it
echo "com.miHoYo., com.activision., libfb.so, UnityMain, libunity.so" > /proc/sys/kernel/sched_lib_name
echo "255" > /proc/sys/kernel/sched_lib_mask_force   # Mask to enforce priority for the listed apps
