# MagneticDeclination
A Garmin Connect IQ (Monkey C) widget to show the magnetic declination at the current location and time.

If there is screen space, modern watches that support the Glance mode of launching widgets will display the last value that was calculated. Depending on where you last ran the app this could be different from the current value.

It’s well known that a magnetic compass doesn’t point exactly towards True North – it points to Magnetic North. The difference is called the magnetic declination. It varies both around the world and over time but can be calculated for any given time and place using the World Magnetic Model. This was developed by the National Centers for Environmental Information and the British Geological Survey. (https://www.ngdc.noaa.gov/geomag/WMM/). The model is updated every 5 years. The current one is WMM2020 covering 2020-2024. Hopefully, I’ll update the widget in 2024 when the next model is released!!

The code is based on WMM_Tiny by John Blaiklock (https://github.com/miniwinwm/WMM_Tiny/) which is itself a cut down version of the original source code available from NOAA. The WMM coefficients file from NOAA (WMM.COF) needs to be converted to Monkey C for use in the widget. I have included a C source file, also derived from John Blaiklock's work, that does this conversion. WMM_Tiny, and therefore this work, is released under the MIT licence (https://opensource.org/licenses/MIT). 

The icons are based on the image https://upload.wikimedia.org/wikipedia/commons/c/c2/Magnetic_declination.svg which is licensed under the Creative Commons licence CC BY 3.0 (https://creativecommons.org/licenses/by/3.0/).
