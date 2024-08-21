# PowerMaster

PowerMaster is a simple Shell Bash Script designed to manage CPU power frequencies settings on Linux systems. 

## Use Case
Useful for automatic change CPU power mode regarding individual user scenarios.

## Usage

```bash
PowerMaster 2024.0821 Tomas Mark, usage:
powermaster.sh [ max | mg | half | ultra | custom [max_freq] [Mhz|GHz] ]
```

## Modes

1. **max**: Sets the CPU to its maximum frequency for all cores.
2. **mg**: Sets the CPU to its maximum frequency minus one Gigahertz for each core.
3. **half**: Sets the CPU to half of its maximum frequency for all cores.
4. **ultra**: Sets the CPU to its minimum frequency for all cores.
5. **custom**: Allows you to set a custom frequency for all cores. Requires additional parameters for the maximum frequency and its unit (MHz or GHz).

## Examples

### max mode

```bash
./powermaster.sh max
```

### mg mode

```bash
./powermaster.sh mg
```

### half mode

```bash
./powermaster.sh half
```

### ultra mode

```bash
./powermaster.sh ultra
```

### custom mode

```bash
./powermaster.sh custom 1.6 GHz
# or
./powermaster.sh custom 1800 MHz
```

## Script Explanation

The script begins by displaying its version and usage instructions. It then checks if any arguments were provided. If not, it exits with an error message.

The number of CPU cores is determined using `nproc`.

### Main Logic

Depending on the mode specified by the user, the script calls `get_cpu_limits` to retrieve the current limits and then applies the appropriate power mode settings. Finally, it calls `get_cpu_policy` to display the updated frequency policy.

If no valid mode is provided, the script outputs the current CPU limits and policy.

## Requirements

- `cpupower`: The script relies on `cpupower` to manage CPU frequencies. Ensure it is installed and accessible with the necessary permissions.

## Notes

- Running this script requires `sudo` permissions to change CPU frequency settings.
- Ensure there is a space between parameters when specifying the custom power saver mode.

## License

PowerMaster is open-source software, released under the unlicense.
Initial author is Tomáš Mark 2024.

For more information, visit the [GitHub repository](https://github.com/tomasmark79/powermaster).