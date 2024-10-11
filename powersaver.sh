#!/bin/bash

appName="PowerSaver"
version="2024.0821"
author="Tomas Mark"
email="tomas@digitalspace.name"

settingMode="CPU Frequency Mode to"
notifyIconPath="/home/tomas/Obrázky/Ikony/desktop-application.png"

# help
usage="powersaver.sh [ none | mg | half | ultra | custom [max_freq] [Mhz|GHz] ]"
usageColored="powersaver.sh [ \e[31mnone\e[0m | \e[33mmg\e[0m | \e[32mhalf\e[0m | \e[34multra\e[0m | \e[35mcustom [max_freq] [Mhz|GHz]\e[0m ]"

# dependencies
if ! dpkg -l | grep cpupower >/dev/null; then
    echo -e "\e[31mcpupower package is not installed. Please install it first.\e[0m"
    echo -e "\e[31mRun: sudo apt install cpupower\e[0m"
    exit 1
fi

# variables
declare -a min_freqs
declare -a min_freq_units
declare -a max_freqs
declare -a max_freq_units

declare -a min_freqs_policy
declare -a min_freq_units_policy
declare -a max_freqs_policy
declare -a max_freq_units_policy

required_mode=""

# functions
function convert_to_mhz {
    freq=$1
    unit=$2
    if [ "$unit" == "GHz" ]; then

        # Tento prevod prevadi na MHz bez desetinnych hodnot
        # freq=$(echo "$freq" | awk -F. '{print $1}')
        # freq=$(( freq * 1000 ))

        # Převod GHz na MHz s desetinnými hodnotami
        freq=$(echo "$freq * 1000" | bc -l)
    fi
    # Zaokrouhlení na celé číslo (pokud potřebujete desetinná místa, upravte printf)
    LC_NUMERIC=C printf "%.0f\n" "$freq"
    # echo $freq
}

function print_notify {
    notify-send -u low -i $notifyIconPath "$appName" "Mode: $1"
}

function none_mode {
    for ((i = 0; i < $num_cores; i++)); do
        echo -e -n "\e[33mForce to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freqs[$i]}${max_freq_units[$i]}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freqs[$i]}${max_freq_units[$i]}
    done
    echo
}
function half_mode {
    for ((i = 0; i < $num_cores; i++)); do
        max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
        max_freq=$((max_freq / 2))
        max_freq_units="MHz"
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
    done
    echo
}
function mg_mode {
    for ((i = 0; i < $num_cores; i++)); do
        max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
        max_freq=$((max_freq - 1000))
        max_freq_units="MHz"
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
    done
    echo
}
function ultra_mode {
    for ((i = 0; i < $num_cores; i++)); do
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - min: ${min_freqs[$i]}${min_freq_units[$i]}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${min_freqs[$i]}${min_freq_units[$i]}
    done
    echo
}
# params $1 - max frequency, $2 - unit
function custom_mode {
    if [[ -z "$1" || -z "$2" ]]; then
        echo -e "\e[31mMissing second or third param for max frequency and its unit.\e[0m"
        echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1.6 Ghz\e[0m - space char required between freq number and unit!"
        echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1600 Mhz\e[0m - space char required between freq number and unit!"
        echo -e "\e[31mSettings Aborted!\e[0m"
        return
    fi

    for ((i = 0; i < $num_cores; i++)); do
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: $1$2\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u $1$2
    done
    echo
}

function get_cpu_limits {
    hwLimitsPattern="hardware limits:"
    echo "Getting physical processor frequency limits ..."
    for ((i = 0; i < $num_cores; i++)); do
        cpu_info=$(sudo cpupower -c $i frequency-info)
        min_freqs[$i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $3}')
        min_freq_units[$i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $4}')
        max_freqs[$i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $6}')
        max_freq_units[$i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $7}')
        echo -e "\e[32mCore $i - min: ${min_freqs[$i]} ${min_freq_units[$i]} - max: ${max_freqs[$i]} ${max_freq_units[$i]}\e[0m"
    done
    echo

}

function get_cpu_policy {
    policyPattern="policy"
    echo "Getting physical processor frequency policies ..."
    for ((i = 0; i < $num_cores; i++)); do
        cpu_info_policy=$(sudo cpupower -c $i frequency-info)
        min_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $7}')
        min_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $8}')
        max_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $10}')
        max_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $11}')
        echo -e "\e[34mCore $i - min: ${min_freqs_policy[$i]} ${min_freq_units_policy[$i]} - max: ${max_freqs_policy[$i]} ${max_freq_units_policy[$i]}\e[0m"
    done
    echo
}

function getCpuInfo {
    echo "$appName $version $author"
    echo
    num_cores=$(nproc)
    echo -e "Requested mode \e[41m$required_mode\e[0m for $num_cores detected cpu cores"
    echo
    cat /proc/cpuinfo | grep 'name' | uniq
    echo
}

if [[ "$1" == "none" || "$1" == "n" || "$1" == "--none" || "$1" == "-n" ]]; then
    required_mode="None"
    getCpuInfo
    get_cpu_limits
    echo "$settingMode $required_mode"
    print_notify "$required_mode"
    none_mode
    get_cpu_policy
elif [[ "$1" == "mg" || "$1" == "m" || "$1" == "--mg" || "$1" == "-m" ]]; then
    required_mode="Mg"
    getCpuInfo
    get_cpu_limits
    echo "$settingMode $required_mode"
    print_notify "$required_mode"
    mg_mode
    get_cpu_policy
elif [[ "$1" == "half" || "$1" == "h" || "$1" == "--half" || "$1" == "-h" ]]; then
    required_mode="Half"
    getCpuInfo
    get_cpu_limits
    echo "$settingMode $required_mode"
    print_notify "$required_mode"
    half_mode
    get_cpu_policy
elif [[ "$1" == "ultra" || "$1" == "u" || "$1" == "--ultra" || "$1" == "-u" ]]; then
    required_mode="Ultra"
    getCpuInfo
    get_cpu_limits
    echo "$settingMode $required_mode"
    print_notify "$required_mode"
    ultra_mode
    get_cpu_policy
elif [[ "$1" == "custom" || "$1" == "c" || "$1" == "--custom" || "$1" == "-c" ]]; then
    required_mode="Custom"
    getCpuInfo
    get_cpu_limits
    echo "$settingMode $required_mode $2 $3"
    print_notify "$required_mode $2 $3"
    custom_mode $2 $3
    get_cpu_policy
else
    required_mode="Only Print Informations"
    echo -e $usageColored
    getCpuInfo
    get_cpu_limits
    get_cpu_policy
fi
