# PowerSaver CPU Profile Manager

`PowerSaver` is a Bash script application that manages CPU frequency and performance profiles for Linux systems using `cpupower`.  

It allows users to dynamically set CPU frequency limits and governors based on **predefined profiles**, optimizing for performance or power savings.

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

## License

The Unlicence. You may download this script to your smart watch if neccessary ;-)