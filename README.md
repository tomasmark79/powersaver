# PowerSaver CPU Profile Manager

`PowerSaver` is a Bash script that manages CPU frequency and performance profiles for Linux systems using `cpupower`. It allows users to dynamically set CPU frequency limits and governors based on predefined user and CPU profiles, optimizing for performance or power savings.

## Features

![image](https://github.com/user-attachments/assets/be425867-655b-4c6d-9447-17bfb89f874a)

<img width="471" alt="image" src="https://github.com/user-attachments/assets/3c6e832c-c825-466a-a4bc-59d3dba35b6d">

- **View CPU Info:** Displays the CPU model, core count, and current frequency limits.
- **Predefined Profiles:**
  - **User Profiles:** Fire, Work, Relax, Out of Office (OOO), Time Is Gold.
  - **CPU Profiles:** Max, Minus One GHz, Half, Min, Custom (frequency and unit).
- **Governors:** Automatically sets `powersave` or `performance` governors for each profile.
- **Custom Limits:** Supports custom frequency settings in MHz or GHz.

## Requirements

- **cpupower:** Ensure that `cpupower` is installed:
  ```bash
  sudo apt install cpupower
  ```

## Usage

```bash
./powersaver.sh [options]
```

### Options:

- `--user-profile [ fire | work | relax | ooo | timeisgold ]`
  - **Fire:** Max performance with high frequency and performance governor.
  - **Work:** High performance with moderate frequency and performance governor.
  - **Relax:** Moderate performance with lower power consumption.
  - **OOO:** Energy-saving profile with low frequency and powersave governor.
  - **Time Is Gold:** Minimal performance, powersave governor, and lowest frequency.

- `--cpu-profile [ max | minusgiga | half | min | custom [max_freq] [Mhz|GHz] ]`
  - **max:** Set CPU to its maximum frequency.
  - **minusgiga:** Set CPU to one GHz below the maximum.
  - **half:** Set CPU to half of its maximum frequency.
  - **min:** Set CPU to its minimum frequency.
  - **custom [max_freq] [Mhz|GHz]:** Set a custom maximum frequency.

- `--governor [ powersave | performance ]`
  - **powersave:** Set the CPU to energy-saving mode.
  - **performance:** Set the CPU to high-performance mode.

### Example Usage:

```bash
# Set the user profile to 'work'
./powersaver.sh --user-profile work

# Set custom CPU profile with max frequency of 2.5 GHz and powersave governor
./powersaver.sh --cpu-profile custom 2.5 GHz --governor powersave
```

### Display CPU Info and Limits

If no arguments are provided, the script will display the current CPU model, frequency limits, current frequency policy, and active governors:

```bash
./powersaver.sh
```

## Notifications

The script supports desktop notifications (using `notify-send`) to indicate profile changes. Ensure your desktop environment supports notifications.

## License

The Unlicence.
