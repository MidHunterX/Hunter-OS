# Automata

An automaton (automata in plural) is an abstract self-propelled computing device which follows a predetermined sequence of operations automatically.

## Ocular Brightness Adaptation (Iris)

![iris](./.assets/auto_adaptation.jpg)

Maintains the contrast of a transparent window across different wallpapers;
doesn't matter if the wallpaper is dark or light, the window will have the same
perceived opacity. It does this by dynamically adjusting the brightness of
the window based on the perceived brightness of the current wallpaper.
Similar to how your eyes adapt to different light conditions.

## Hardware Brightness Adaptation (Radiance)

```
|| = Data Point
[] = Detection Window for Set

<--|PREV|------------[  |CURRENT|  ]------------|NEXT|-->
```

A day is a finite closed circular scale of time. Radiance learns your
brightness preferences throughout the day and use that sparse data to Linear
Interpolate brightness smoothly throughout the whole day.

- Case 0 (Initial): 14% @ 12:34 = Stay the same until like normal brightness system until it's more than one data point. When wrapping around to next day, NEXT will be detected as the first data point.
- Case 1 (Subsequent): Set 0% @ 4:00, 7% @ 6:30, 12% @ 9:00 = LERP(PREV, NEXT).
- Case 2 (Update): Next day, set 4% @ 6:25. NEXT will be detected as 7% @ 6:30 which might not be the intended value since data points are close to each-other = SET with a padding to detection window. This same philosophy is used in UI Buttons and Touch Keyboards as well to detect nearest touch/click and accept it as intended.
