# PowerSaver

PowerSaver is designed to manage CPU power frequencies settings on Linux systems.

## Why?

I use this very helpfull script for switching among laptop modes. This script is giving you the power to set CPU frequencies as you wish in CPU factory limits . For laptop and othe mobile devices may be very critical to battery safe or to CPU temperature control.

## Usecases
    -   During battery I am using Mode **Half** or **Custom 1.6 Ghz**
    -   During chargering or in dicking station I am using Mode **Mg**
    -   During OBS streaming I am using Mode **Mg** or **Half** due video encryption is very expensive
    -   When the laptop is almost out of power then Mode **Ultra** is very handy
  
Automaticaly switching is available in my Kubuntu via Kde Plasma Power Controll settings. I added this script with required parameters regarding current power mode and magic is happening. 

## Usage

```bash
powersaver.sh [ none | mg | half | ultra | custom [max_freq] [Mhz|GHz] ]
PowerSaver 2024.0821 Tomas Mark
```

## Modes

1. **none**: Sets the CPU to its maximum frequency for all cores.
2. **mg**: Sets the CPU to its maximum frequency minus one Gigahertz for each core.
3. **half**: Sets the CPU to half of its maximum frequency for all cores.
4. **ultra**: Sets the CPU to its minimum frequency for all cores.
5. **custom**: Allows you to set a custom frequency for all cores. Requires additional parameters for the maximum frequency and its unit (MHz or GHz).

## Examples

```bash
./PowerSaver.sh mg
./PowerSaver.sh custom 1.6 GHz
./PowerSaver.sh custom 1800 MHz
```

## Requirements

- `cpupower`: The script relies on `cpupower` to manage CPU frequencies. Ensure it is installed and accessible with the necessary permissions.

## Notes

- Running this script requires `sudo` permissions to change CPU frequency settings.
- Ensure there is a space between parameters when specifying the custom power saver mode.

## License

PowerSaver is open-source software, released under the **unlicense**. If you like this script, you may mention my name.

Enjoy!

For more information, visit the [GitHub repository](https://github.com/tomasmark79/powermaster).