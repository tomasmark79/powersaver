#!/bin/bash

echo "PowerMaster v0.1 - Tomas Mark 2024"
echo "usage:"
echo "powermaster.sh [high_performance|power_saver|ultra_power_saver|custom_power_saver] [max_freq] [Mhz|GHz]"

if [ $# -eq 0 ]; then
    echo -e "\e[31mNo param was given\e[0m"
    exit 1
fi

num_cores=$(nproc)
echo
echo -e "\e[35mCPU Cores: $num_cores Mode Requested: $1\e[0m"

declare -a min_freqs
declare -a min_freq_units
declare -a max_freqs
declare -a max_freq_units

declare -a min_freqs_policy
declare -a min_freq_units_policy
declare -a max_freqs_policy
declare -a max_freq_units_policy

function convert_to_mhz {
    freq=$1
    unit=$2
    if [ "$unit" == "GHz" ]; then
        freq=$(echo "$freq" | awk -F. '{print $1}')
        freq=$(( freq * 1000 ))
    fi
    echo $freq
}

function high_performance_mode {
    echo
    echo "Setting High Performance Mode ..."
    echo "notice: maximal frequency will be set for all cores"

    for ((i=0; i<$num_cores; i++)); do
        echo "Setting high performance mode for core $i..."
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freqs[$i]}${max_freq_units[$i]}
    done
}

function power_saver_mode {
    echo
    echo "Setting Power Saver Mode ..."
    echo "notice: half of maximal frequency will be set for all cores"
   
    for ((i=0; i<$num_cores; i++)); do
        max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
        max_freq=$(( max_freq / 2 ))
        max_freq_units="MHz"
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
    done
}

function ultra_power_saver_mode {
    echo
    echo "Setting Ultra Power Saver Mode ..."
    echo "notice: minimal frequency will be set for all cores"

    for ((i=0; i<$num_cores; i++)); do
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - min: ${min_freqs[$i]}${min_freq_units[$i]}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${min_freqs[$i]}${min_freq_units[$i]}
    done
}

# params $1 - max frequency, $2 - unit
function custom_power_saver_mode {
    echo
    echo "Setting Custom Power Saver Mode ..."
    echo "notice: custom frequency will be set for all cores"

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "\e[31mMissing second or third param for max frequency and its unit.\e[0m"
        echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1.6 Ghz\e[0m - space requited between parameters!"
        echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1600 Mhz\e[0m - space requited between parameters!"
        echo -e "\e[31mSettings Aborted!\e[0m"
        return
    fi

    for ((i=0; i<$num_cores; i++)); do
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: $1$2\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u $1$2
    done
}

function get_cpu_limits {
    echo 
    echo "Gettting limits for all cores ..."

    for ((i=0; i<$num_cores; i++)); do
        cpu_info=$(sudo cpupower -c $i frequency-info)
        min_freqs[$i]=$(echo "$cpu_info" | grep "hardware limits:" | awk '{print $3}')
        min_freq_units[$i]=$(echo "$cpu_info" | grep "hardware limits:" | awk '{print $4}')
        max_freqs[$i]=$(echo "$cpu_info" | grep "hardware limits:" | awk '{print $6}')
        max_freq_units[$i]=$(echo "$cpu_info" | grep "hardware limits:" | awk '{print $7}')
        echo -e "\e[32mCore $i - min: ${min_freqs[$i]} ${min_freq_units[$i]} - max: ${max_freqs[$i]} ${max_freq_units[$i]}\e[0m"
    done
    
}

function get_cpu_policy {
    echo
    echo "Gettting policy for all cores ..."

    for ((i=0; i<$num_cores; i++)); do
        cpu_info_policy=$(sudo cpupower -c $i frequency-info)
        min_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $7}')
        min_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $8}')
        max_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $10}')
        max_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $11}')
        echo -e "\e[34mCore $i - min: ${min_freqs_policy[$i]} ${min_freq_units_policy[$i]} - max: ${max_freqs_policy[$i]} ${max_freq_units_policy[$i]}\e[0m"
    done
}

if [ "$1" == "high_performance" ]; then
    get_cpu_limits
    high_performance_mode
    get_cpu_policy
elif [ "$1" == "power_saver" ]; then
    get_cpu_limits
    power_saver_mode
    get_cpu_policy
elif [ "$1" == "ultra_power_saver" ]; then
    get_cpu_limits
    ultra_power_saver_mode
    get_cpu_policy
elif [ "$1" == "custom_power_saver" ]; then
    get_cpu_limits
    custom_power_saver_mode $2 $3
    get_cpu_policy
else
    echo "No param was given"
    get_cpu_limits
    get_cpu_policy
fi

