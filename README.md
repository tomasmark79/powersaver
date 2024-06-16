# PowerMaster v0.1 - Tomas Mark 2024

PowerMaster is a simple Bash script designed to manage CPU power settings on Linux systems. It allows users to switch between different power modes or set custom frequencies for CPU cores.

## Usage

```bash
powermaster.sh [high_performance|power_saver|ultra_power_saver|custom_power_saver] [max_freq] [Mhz|GHz]
```

## Modes

1. **high_performance**: Sets the CPU to its maximum frequency for all cores.
2. **power_saver**: Sets the CPU to half of its maximum frequency for all cores.
3. **ultra_power_saver**: Sets the CPU to its minimum frequency for all cores.
4. **custom_power_saver**: Allows you to set a custom frequency for all cores. Requires additional parameters for the maximum frequency and its unit (MHz or GHz).

## Examples

### High Performance Mode

```bash
./powermaster.sh high_performance
```

### Power Saver Mode

```bash
./powermaster.sh power_saver
```

### Ultra Power Saver Mode

```bash
./powermaster.sh ultra_power_saver
```

### Custom Power Saver Mode

```bash
./powermaster.sh custom_power_saver 1.6 GHz
# or
./powermaster.sh custom_power_saver 1600 MHz
```

## Script Explanation

The script begins by displaying its version and usage instructions. It then checks if any arguments were provided. If not, it exits with an error message.

The number of CPU cores is determined using `nproc`.

### Functions

- `convert_to_mhz`: Converts a frequency from GHz to MHz.
- `high_performance_mode`: Sets all cores to their maximum frequency.
- `power_saver_mode`: Sets all cores to **half** of their maximum frequency.
- `ultra_power_saver_mode`: Sets all cores to their minimum frequency.
- `custom_power_saver_mode`: Sets all cores to a user-defined frequency.
- `get_cpu_limits`: Retrieves the hardware limits (minimum and maximum frequencies) for each core.
- `get_cpu_policy`: Retrieves the current frequency policy (minimum and maximum frequencies) for each core.

### Main Logic

Depending on the mode specified by the user, the script calls `get_cpu_limits` to retrieve the current limits and then applies the appropriate power mode settings. Finally, it calls `get_cpu_policy` to display the updated frequency policy.

If no valid mode is provided, the script outputs the current CPU limits and policy.

## Requirements

- `cpupower`: The script relies on `cpupower` to manage CPU frequencies. Ensure it is installed and accessible with the necessary permissions.

## Notes

- Running this script requires `sudo` permissions to change CPU frequency settings.
- Ensure there is a space between parameters when specifying the custom power saver mode.

## License

PowerMaster is open-source software, released under the MIT License.

For more information, visit the [GitHub repository](https://github.com/tomasmark/powermaster).