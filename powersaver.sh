#!/bin/bash

# fast log monitoring
# lnav /tmp/powersaver.log or tail -f /tmp/powersaver.log

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

num_cores=$(nproc --all)

function log_and_print {
    local color_code=$1
    shift
    echo -e "\e[${color_code}m$*\e[0m"
    echo -e "\e[${color_code}m$*\e[0m" >> /tmp/powersaver.log
}

function prWhite {
    log_and_print 97 "$@"
}

function prGreen {
    log_and_print 32 "$@"
}

function prRed {
    log_and_print 31 "$@"
}

function prBlue {
    log_and_print 34 "$@"
}

function prYellow {
    log_and_print 33 "$@"
}

function prCyan {
    log_and_print 36 "$@"
}

prWhite "[$(date +'%Y-%m-%d %H:%M:%S')] PowerSaver Started $*" >> /tmp/powersaver.log

function run_cpupower {
    if ! sudo cpupower "$@"; then
        prRed "Error calling cpupower with parameters: $*"
        exit 1
    fi
}

function run_cpupower_no_output {
    if ! sudo cpupower "$@" >/dev/null; then
        prRed "Error calling cpupower with parameters: $*"
        exit 1
    fi
}

function convert_to_mhz {
    freq=$1
    unit=$2
    if [ "$unit" == "GHz" ]; then
        freq=$(echo "$freq * 1000" | bc -l)
    fi
    LC_NUMERIC=C printf "%.0f\n" "$freq"
}

function get_cpu_info {
    prRed "Detected CPU\t: $(awk -F ': ' '/model name/ {print $2; exit}' /proc/cpuinfo)"
}

function get_cpu_limits {
    local hwLimitsPattern="hardware limits:"
    for ((i = 0; i < num_cores; i++)); do
        cpu_info=$(run_cpupower -c $i frequency-info)
        min_freqs[i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $3}')
        min_freq_units[i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $4}')
        max_freqs[i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $6}')
        max_freq_units[i]=$(echo "$cpu_info" | grep "$hwLimitsPattern" | awk '{print $7}')
    done
    prGreen "Factory limits\t: Total Cores ${num_cores} - min: ${min_freqs[0]} ${min_freq_units[0]} - max: ${max_freqs[0]} ${max_freq_units[0]}"
}

function get_cpu_policy {
    local policyPattern="policy"
    for ((i = 0; i < num_cores; i++)); do
        cpu_info_policy=$(run_cpupower -c $i frequency-info)
        min_freqs_policy[i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $7}')
        min_freq_units_policy[i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $8}')
        max_freqs_policy[i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $10}')
        max_freq_units_policy[i]=$(echo "$cpu_info_policy" | grep "$policyPattern" | awk '{print $11}')
    done
    prBlue "Current limits\t: Total Cores ${num_cores} - min: ${min_freqs_policy[0]} ${min_freq_units_policy[0]} - max: ${max_freqs_policy[0]} ${max_freq_units_policy[0]} Governor: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
}

function print_notify {
    icon=$SCRIPT_DIR/cpu.png
    if [ -z "$SUDO_USER" ]; then
        notify-send -u low -i "$icon" "$1" "$2"
    else
        sudo -u "$SUDO_USER" DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/"$(id -u "$SUDO_USER")"/bus notify-send -u low -i "$icon" "$1" "$2"
    fi
}

function setMinMaxFreq {
    for ((i = 0; i < num_cores; i++)); do
        min_freqs[i]=$(convert_to_mhz "${min_freqs[$i]}" "${min_freq_units[$i]}")
        max_freqs[i]=$(convert_to_mhz "${max_freqs[$i]}" "${max_freq_units[$i]}")
        if [ -z "${min_freqs[$i]}" ] || [ -z "${max_freqs[$i]}" ]; then
            prRed "Frequency is not correctly set for core $i"
            exit 1
        fi
        cmd=("-c" "$i" "frequency-set" "-d" "${min_freqs[$i]}""Mhz" "-u" "${max_freqs[$i]}""Mhz")
        run_cpupower_no_output "${cmd[@]}"
    done
    #prYellow "Command: run_cpupower ${cmd[*]}"
}

function setCustomFreq {
      if ! [[ "$1" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        prRed "Neplatná frekvence: $1"
        exit 1
    fi
    if ! [[ "$2" =~ ^(MHz|GHz)$ ]]; then
        prRed "Neplatná jednotka: $2"
        exit 1
    fi
    for ((i = 0; i < num_cores; i++)); do
        min_freqs[i]=$(convert_to_mhz "${min_freqs[$i]}" "${min_freq_units[$i]}")
        max_freqs[i]=$(convert_to_mhz "$1" "$2")
        if [ -z "${min_freqs[$i]}" ] || [ -z "${max_freqs[$i]}" ] || [ "${min_freqs[$i]}" -eq 0 ] || [ "${max_freqs[$i]}" -eq 0 ]; then
            prRed "Frequency is not correctly set for core $i"
            exit 1
        fi
        cmd=("-c" "$i" "frequency-set" "-d" "${min_freqs[$i]}""Mhz" "-u" "${max_freqs[$i]}""Mhz")
        run_cpupower_no_output "${cmd[@]}"
    done
    #prYellow "Command: run_cpupower ${cmd[*]}"
}

function setGovernor {
    for ((i = 0; i < num_cores; i++)); do
        cmd=("-c" "$i" "frequency-set" "-g" "$1")
        run_cpupower_no_output "${cmd[@]}"
    done
    #prYellow "Command: run_cpupower ${cmd[*]}"
}

# -------------------------------------------------------------------------------------
# Helper function to set profile from --user-profile
# -------------------------------------------------------------------------------------
function apply_user_profile {
    case "$1" in
        fire)
            get_cpu_policy        
            setMinMaxFreq
            setGovernor performance
            get_cpu_policy
            notify_message="Profile: Fire performance"
            ;;
        work)
            get_cpu_policy
            setCustomFreq "3.8" "GHz"
            setGovernor performance
            get_cpu_policy
            notify_message="Profile: Work 3.8 GHz performance"
            ;;
        relax)
            get_cpu_policy
            setCustomFreq "3.0" "GHz"
            setGovernor powersave
            get_cpu_policy
            notify_message="Profile: Relax 3.0 GHz powersave"
            ;;
        ooo)
            get_cpu_policy
            setCustomFreq "1.8" "GHz"
            setGovernor powersave
            get_cpu_policy
            notify_message="Profile: Out of Office 1.8 GHz powersave"
            ;;
        timeisgold)
            get_cpu_policy
            setCustomFreq "0.8" "GHz"
            setGovernor powersave
            get_cpu_policy
            notify_message="Profile: Time is Gold 0.8 GHz powersave"
            ;;
    esac
}

# -------------------------------------------------------------------------------------
# Entry point
# -------------------------------------------------------------------------------------

# print current user running this script
prGreen "Current user: $USER"

# Check cpupower installation
if ! dpkg -l | grep cpupower >/dev/null; then
    prRed "cpupower package is not installed. Please install it first."
    prRed "Run: sudo apt install cpupower"
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

usage="powersaver.sh [options] 
    --profile  | -p [ fire | work | relax | ooo | timeisgold ]\n\
    --governor | -g [ powersave   | performance ]"

if [ "$#" -eq 0 ] || [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    echo -e "$usage"
    prYellow "Please provide at least one argument."
    get_cpu_info
    get_cpu_limits
    get_cpu_policy
    exit 1
fi

notify_message=""

# Argument processing
while [[ $# -gt 0 ]]; do
    case "$1" in
        --profile|-p)
            if [ -z "$2" ]; then
                prRed "Argument --profile | -p requires a value."
                prRed "Please provide a valid profile: fire, work, relax, ooo, timeisgold"
                exit 1
            fi
            user_profile="$2"
            shift 2
            ;;
        --governor|-g)
            if [[ "$2" != "powersave" && "$2" != "performance" ]]; then
                prRed "Invalid governor value. Please provide either 'powersave' or 'performance'."
                exit 1
            fi
            selected_governor="$2"
            shift 2
            ;;
        *)
            prRed "Unknown parameter: $1"
            shift
            ;;
    esac
done

# Load CPU information
get_cpu_info
get_cpu_limits

# If user_profile is defined, apply it
if [[ -n "$user_profile" ]]; then
  apply_user_profile "$user_profile"
fi

# And if the governor is defined, set it
if [[ -n "$selected_governor" ]]; then
  setGovernor "$selected_governor"
fi

print_notify "PowerSaver" "$notify_message"