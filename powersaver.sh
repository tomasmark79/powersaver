#!/bin/bash

#
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_URL="https://github.com/tomasmark79/powersaver"

# Get number of cpu cores
num_cores=$(nproc --all)

# -------------------------------------------------------------------------------------
# Functions pattern
# -------------------------------------------------------------------------------------

if [ "$1" = "--update" ]; then
    # Získání aktuálního časového razítka ve formátu YYYYMMDD_HHMMSS
    timestamp=$(date +"%Y%m%d_%H%M%S")
    if [ -d .git ]; then
        echo "Aktualizuji existující repozitář..."
        if git pull origin main; then
            echo "Aktualizace úspěšná."
        else
            echo "Aktualizace selhala. Pokusím se o nové klonování..."
            cd ..
            
            # toto je pripadne moc znicujici
            # rm -rf "$SCRIPT_DIR"
            # Vytvoření nové složky o úroveň výše s časovým razítkem jako názvem
            new_dir="$(dirname "$SCRIPT_DIR")/$timestamp"
            mkdir -p "$new_dir"
            # Přesunutí původní složky do nové složky
            mv "$SCRIPT_DIR" "$new_dir"
            git clone "$REPO_URL" "$SCRIPT_DIR"
        fi
    else
        echo "Git repozitář nenalezen. Klonuji nový..."
        cd ..
        rm -rf "$SCRIPT_DIR"
        git clone "$REPO_URL" "$SCRIPT_DIR"
    fi

    echo "Aktualizace dokončena."
    exit 0
fi

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

function get_cpu_info {
    echo
    echo "Getting cpu info ..."
    model_name=$(cat /proc/cpuinfo | grep 'model name' | uniq | awk -F ': ' '{print $2}')
    echo -e "$model_name" w "\e[31m$num_cores\e[0m cores"
}

function get_cpu_limits {
    echo
    echo "Getting factory cpu limits ..."
    hwLimitsPattern="hardware limits:"
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
    echo "Getting current cpu policy ..."
    for ((i = 0; i < $num_cores; i++)); do
        cpu_info_policy=$(sudo cpupower -c $i frequency-info)
        min_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $7}')
        min_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $8}')
        max_freqs_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $10}')
        max_freq_units_policy[$i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $11}')
        echo -e "\e[34mCore $i - min: ${min_freqs_policy[$i]} ${min_freq_units_policy[$i]} - max: ${max_freqs_policy[$i]} ${max_freq_units_policy[$i]}\e[0m"
    done
}

# function set_max_mode {
#     echo "Setting max cpu limits ..."
#     for ((i = 0; i < $num_cores; i++)); do
#         echo -e -n "\e[33mForce to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freqs[$i]}${max_freq_units[$i]}\e[0m "
#         sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freqs[$i]}${max_freq_units[$i]}
#     done
#     echo
# }

function print_notify {
    icon=$SCRIPT_DIR/cpu.png
    if [ -z "$SUDO_USER" ]; then
        notify-send -u low -i $icon "$1" "$2"
    else
        sudo -u $SUDO_USER DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u $SUDO_USER)/bus notify-send -u low -i $icon "$1" "$2"
    fi
}

function check_and_set_max_limits {
    if [[ "$1" == "max" ]]; then
        echo "Setting maximal cpu limits ..."
        for ((i = 0; i < $num_cores; i++)); do
            echo -e -n "\e[33mForce to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freqs[$i]}${max_freq_units[$i]}\e[0m "
            sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freqs[$i]}${max_freq_units[$i]}
        done
        echo
    fi

}

function check_and_set_minusgiga_limits {
    if [[ "$1" == "minusgiga" ]]; then
        echo "Setting minus one gigahertz cpu limits ..."
        for ((i = 0; i < $num_cores; i++)); do
            max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
            max_freq=$((max_freq - 1000))
            max_freq_units="MHz"
            echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
            sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
        done
        echo
    fi
}

function check_and_set_half_limits {
    if [[ "$1" == "half" ]]; then
        echo "Setting half of maximum cpu limits ..."
        for ((i = 0; i < $num_cores; i++)); do
            max_freq=$(convert_to_mhz ${max_freqs[$i]} ${max_freq_units[$i]})
            max_freq=$((max_freq / 2))
            max_freq_units="MHz"
            echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: ${max_freq}${max_freq_units}\e[0m "
            sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${max_freq}${max_freq_units}
        done
        echo
    fi
}

function check_and_set_min_limits {
    if [[ "$1" == "min" ]]; then
        echo "Setting minimal cpu limits ..."
        for ((i = 0; i < $num_cores; i++)); do
            echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - min: ${min_freqs[$i]}${min_freq_units[$i]}\e[0m "
            sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u ${min_freqs[$i]}${min_freq_units[$i]}
        done
        echo
    fi
}

function check_and_set_custom_limits {
    # # params $2 - max frequency, $3 - unit
    if [[ "$1" == "custom" ]]; then
        echo "Setting custom cpu limits ..."
        if [[ -z "$2" || -z "$3" ]]; then
            echo -e "\e[31mMissing second or third param for max frequency and its unit.\e[0m"
            echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1.6 Ghz\e[0m - space char required between freq number and unit!"
            echo -e "\e[31mExample: ./powermaster.sh custom_power_saver 1600 Mhz\e[0m - space char required between freq number and unit!"
            echo -e "\e[31mSettings Aborted!\e[0m"
            return
        fi

        for ((i = 0; i < $num_cores; i++)); do
            echo -e -n "\e[33mAttempt to set core $i - min: ${min_freqs[$i]}${min_freq_units[$i]} - max: $2$3\e[0m "
            sudo cpupower -c $i frequency-set -d ${min_freqs[$i]}${min_freq_units[$i]} -u $2$3
        done
        echo
    fi
}

function get_governor {
    echo
    echo "Getting current cpu governors ..."
    for ((i = 0; i < $num_cores; i++)); do
        echo -e "\e[36mCore $i $(cat /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor)\e[0m"
    done
    echo
}

function check_and_set_governor {
    #echo $1 $2 $3 $4 $5 $6
    for ((i = 0; i < $#; i++)); do
        if [[ "${!i}" == "--governor" ]]; then
            next_arg_index=$((i + 1))
            valid_governons=("powersave" "performance")
            for index_governor in "${valid_governons[@]}"; do
                if [[ "${!next_arg_index}" == "$index_governor" ]]; then
                    echo "Setting governors ..."
                    for ((i = 0; i < $num_cores; i++)); do
                        echo -n ${!next_arg_index} | sudo tee /sys/devices/system/cpu/cpu$i/cpufreq/scaling_governor >/dev/null
                        echo -e "\e[36mCore $i setting governor to ${!next_arg_index}\e[0m"
                    done
                fi
            done
        fi
    done
}

# -------------------------------------------------------------------------------------
# Main entry point
# -------------------------------------------------------------------------------------

# Check if cpupower package is installed
if ! dpkg -l | grep cpupower >/dev/null; then
    echo -e "\e[31mcpupower package is not installed. Please install it first.\e[0m"
    echo -e "\e[31mRun: sudo apt install cpupower\e[0m"
    exit 1
fi

declare -a min_freqs
declare -a min_freq_units
declare -a max_freqs
declare -a max_freq_units
declare -a min_freqs_policy
declare -a min_freq_units_policy
declare -a max_freqs_policy
declare -a max_freq_units_policy

usage="powersaver.sh [options]\n\
--user-profile [ fire | work | relax | ooo | timeisgold ]\n\
--cpu-profile [ max | minusgiga | half | min | custom [max_freq] [Mhz|GHz] ]\n\
--governor [ powersave | performance ]"

if [ "$#" -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo -e "$usage"
    echo
    echo -e "\e[31mNo arguments provided.\e[0m"
    get_cpu_info
    get_cpu_limits
    get_cpu_policy
    get_governor
    exit 1
fi

future_argument=""

# $1 - --user-profile
# $2 - fire | work | relax | ooo | timeisgold
if [[ "$1" == "--user-profile" || "$1" == "-up" ]]; then
    valid_user_profiles=("fire" "work" "relax" "ooo" "timeisgold")
    for index_user_profile in "${valid_user_profiles[@]}"; do
        if [[ "$2" == "$index_user_profile" ]]; then

            # echo -e "\e[33mSetting $1 $2\e[0m"

            # fire
            if [[ "$2" == "fire" ]]; then
                future_argument="--cpu-profile max --governor performance"

            # work
            elif [[ "$2" == "work" ]]; then
                future_argument="--cpu-profile custom 3.8 Ghz --governor performance"

            # relax
            elif [[ "$2" == "relax" ]]; then
                future_argument="--cpu-profile custom 3.8 Ghz --governor powersave"

            # out of office
            elif [[ "$2" == "ooo" ]]; then
                future_argument="--cpu-profile custom 1.8 Ghz --governor powersave"

            # time is gold
            elif [[ "$2" == "timeisgold" ]]; then
                future_argument="--cpu-profile min --governor powersave"

            fi
        fi
    done
fi

# ReRun script with new whole_argument if --user-profile is set
if [[ "$future_argument" != "" ]]; then
    bash $0 $future_argument
    exit 0
fi

# Second instance of script

get_cpu_info
get_cpu_limits

# $1 - --cpu-profile
# $2 - max | minusgiga | half | min | custom
# $3 - max_freq
# $4 - Mhz | GHz
if [[ "$1" == "--cpu-profile" ]]; then
    valid_cpu_profiles=("max" "minusgiga" "half" "min" "custom")
    for index_cpu_profile in "${valid_cpu_profiles[@]}"; do
        if [[ "$2" == "$index_cpu_profile" ]]; then
            check_and_set_max_limits $2
            check_and_set_minusgiga_limits $2
            check_and_set_half_limits $2
            check_and_set_min_limits $2
            check_and_set_custom_limits $2 $3 $4
            get_cpu_policy
        fi
    done
fi

get_governor
check_and_set_governor $@
