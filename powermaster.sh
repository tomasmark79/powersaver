#!/bin/bash

echo "PowerMaster 2024.0821 Tomas Mark, usage:"
echo -e "powermaster.sh [ \e[31mmax\e[0m | \e[33mmg\e[0m | \e[32mhalf\e[0m | \e[34multra\e[0m | \e[35mcustom [max_freq] [Mhz|GHz]\e[0m ]"



# Check cpu power package
if ! dpkg -l | grep cpupower > /dev/null; then
    echo -e "\e[31mcpupower package is not installed. Please install it first.\e[0m"
    echo -e "\e[31mRun: sudo apt install cpupower\e[0m"
    exit 1
fi

num_cores=$(nproc)
echo
echo -e "\e[35m$num_cores cpu cores detected $1\e[0m"

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

function max_mode {
    echo
    echo "Setting Max Mode ..."
    echo "notice: maximal frequency will be set for all cores"

    for ((i=0; i<$num_cores; i++)); do
        echo "Setting high performance mode for core $i..."
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freqs[$i]}${max_freq_units[$i]}
    done
}

function half_mode {
    echo
    echo "Setting Half Mode ..."
    echo "notice: one half of maximal frequency will be set for all cores"
   
    for ((i=0; i<$num_cores; i++)); do
        max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
        max_freq=$(( max_freq / 2 ))
        max_freq_units="MHz"
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
    done
}

function mg_mode {
    echo
    echo "Setting Minus Giga Mode ..."
    echo "notice: maximal frequency MINUS 1Ghz will be set for all cores"
   
    for ((i=0; i<$num_cores; i++)); do
        max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
        max_freq=$(( max_freq - 1000 ))
        max_freq_units="MHz"
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
    done
}

function ultra_mode {
    echo
    echo "Setting Ultra Power Saver Mode ..."
    echo "notice: minimal frequency will be set for all cores"

    for ((i=0; i<$num_cores; i++)); do
        echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - min: ${min_freqs[$i]}${min_freq_units[$i]}\e[0m "
        sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${min_freqs[$i]}${min_freq_units[$i]}
    done
}

# params $1 - max frequency, $2 - unit
function custom_mode {
    echo
    echo "Setting Custom Power Saver Mode ..."
    echo "notice: custom frequency will be set for all cores"

    if [ -z "$1" ] || [ -z "$2" ]; then
        echo -e "\e[31mMissing second or third param for max frequency and its unit.\e[0m"
        echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1.6 Ghz\e[0m - space char required between freq number and unit!"
        echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1600 Mhz\e[0m - space char required between freq number and unit!"
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
    echo "Getting limits for all cores ..."

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
    echo "Getting policy for all cores ..."

    for ((i=0; i<$num_cores; i++)); do
        cpu_info_policy=$(sudo cpupower -c $i frequency-info)
        min_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $7}')
        min_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $8}')
        max_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $10}')
        max_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "policy" | awk '{print $11}')
        echo -e "\e[34mCore $i - min: ${min_freqs_policy[$i]} ${min_freq_units_policy[$i]} - max: ${max_freqs_policy[$i]} ${max_freq_units_policy[$i]}\e[0m"
    done
}

if [ "$1" == "max" ]; then
    get_cpu_limits
    max_mode
    get_cpu_policy
elif [ "$1" == "half" ]; then
    get_cpu_limits
    half_mode
    get_cpu_policy
elif [ "$1" == "ultra" ]; then
    get_cpu_limits
    ultra_mode
    get_cpu_policy
elif [ "$1" == "custom" ]; then
    get_cpu_limits
    custom_mode $2 $3
    get_cpu_policy
elif [ "$1" == "mg" ]; then
    get_cpu_limits
    mg_mode
    get_cpu_policy
else
    echo "No param was given, getting limits and policy for all cores ..."
    get_cpu_limits
    get_cpu_policy
fi

