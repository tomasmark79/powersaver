# PowerSaver CPU Profile Manager

PowerSaver is a user script (`powersaver.sh`) that gives the user control to specify the power profile and manage performance strength and battery discharge rate using predefined profiles.

![image](https://github.com/user-attachments/assets/f1bd4bd2-2801-4e9b-91e9-f1972e69b551)

## Requirements

```bash
sudo apt install cpupower
```

## Installation

Clone the repository and navigate to the directory:

```bash
git clone https://github.com/yourusername/powersaver.git
cd powersaver
```

Make the script executable:

```bash
chmod +x powersaver.sh
```

## Usage

```bash
powersaver.sh [options] 
    --profile  | -p [ fire | work | relax | ooo | timeisgold ]
    --governor | -g [ powersave   | performance ]
```

### Options:

- `--profile [ fire | work | relax | ooo | timeisgold ]`
  - **Fire:** Max performance with high frequency and performance governor.
  - **Work:** High performance with moderate frequency and performance governor.
  - **Relax:** Moderate performance with lower power consumption.
  - **OOO:** Energy-saving profile with low frequency and powersave governor.
  - **Time Is Gold:** Minimal performance, powersave governor, and lowest frequency.

- `--governor [ powersave | performance ]`
  - **powersave:** Set the CPU to energy-saving mode.
  - **performance:** Set the CPU to high-performance mode.

## Examples

Set the profile to "fire":

```bash
./powersaver.sh --profile fire
```

Set the governor to "powersave":

```bash
./powersaver.sh --governor powersave
```

## Linux Desktop files

Fire profile:

```
[Desktop Entry]
Name=PowerSaver Fire
Exec=sh -c 'export LANG=C; export LC_ALL=C; /home/tomas/dev/bash/powersaver/powersaver.sh -p fire'
Icon=/home/tomas/dev/bash/powersaver/cpu.png
Type=Application
Terminal=false
```

Debug profile (keep open terminal)

```
[Desktop Entry]
Name=PowerSaver Fire
Exec=sh -c 'export LANG=C; export LC_ALL=C; /home/tomas/dev/bash/powersaver/powersaver.sh -p fire ; bash'
Icon=/home/tomas/dev/bash/powersaver/cpu.png
Type=Application
Terminal=true
```

## License

The Unlicence. You may download this script to your smart watch if neccessary ;-)
