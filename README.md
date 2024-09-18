# PowerSaver

## Division of Responsibilities
PowerSaver is intended for managing the power (maximum) frequency settings of individual CPU cores, which the Linux system can use for itself. You can actually throttle the processor to save electricity.

 - The enormous strength is in the simplicity of the concept of this script.
 - At the same time, the script tries to extract the best from each processor core.
 - It combines automation with common sense, which is perhaps the best combination!

# 1. Saves battery

First of all, I will describe how it is for me.

I have it set in my ***Kde Plasma*** to always run the script with the appropriate parameter when the power status of my laptop changes. That is, when the device switches from one mode to another.

Specifically, this means that,

if the laptop ***disconnects from power*** Where Plasma calls the following command: `/home/tomas/dev/bash/powersaver/powersaver.sh half`

This ensures that the laptop on battery will use half (parameter half , or h ) of the maximum power for all processor cores. You wouldn't believe how many hours this adds to your device's battery life!

Conversely, when I ***plug the laptop into the charger***, the settings in Kde Plasma calls this command: `/home/tomas/dev/bash/powersaver/powersaver.sh mg`

This ensures that the processor cores will go to the maximum possible frequency minus 1Ghz .

*Explanation of why this minus 1Ghz: I have it because I have a Pro series processor and at its maximum frequencies the processor heats up a lot. Although Linux will use the maximum frequency of the cores only if this performance is requested during some activity, I avoid this and keep my laptop without the need for active cooling. By simply editing the script, you can change the settings according to your own preferences.*

This all happens automatically when you set it up in the Kde Plasma settings. The following is an image for illustration.


# 2. It gives me choice

Another possibility of using this script is that it is ***called with the required parameter directly from the console*** according to your specific needs.

by manually calling ***powersaver half , or mg , or n , or ultra*** , you define how powersaver should set the maximum core frequencies

# Maximum performance
If you need to maximize the performance of the laptop, just call powersaver n or powersaver none which will set zero power saving and let all processor cores work at the maximum possible frequency. Of course, if the system requires this performance.

# Extreme power reduction for critical moments
Sometimes it can happen that you need to squeeze some extra time out of your laptop and the battery is almost dead. For this case, here is the extreme profile ultra . Calling powersaver ultra reduces the maximum possible frequencies to the minimum possible frequencies. This will make the laptop very slow, but at the same time even more economical and you can save additional time at your important meeting when the laptop is still on.

# It's just a script
This is a script that is simple even for further modifications.

Get PowerSaver on GitHub for free
https://github.com/tomasmark79/powersaver

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

PowerSaver is open-source software, released under the **unlicense**. If you like this script, you may mention my name or just send me hello.

Enjoy!

For more information, visit the [GitHub repository](https://github.com/tomasmark79/powermaster).