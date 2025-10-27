# Archaetypes

## Arch Chan (Device Manager)

Handles Kernel System and computer backend

- [x] Knows Battery Info
- [x] Handles Device and Hardware
- [x] Manages drivers and packages
- [x] Reports with chat feature (dunst)
- [x] Reports high CPU usage / CPU temperature
- [ ] Reports unclean / unwanted dependencies

## Hypr Chan (Window Manager)

Handles Hyprland Window Components

- [x] Knows current working window and workspaces
- [x] Manages workspace and open windows
- [x] Reports with chat feature (dunst)
- [x] Brings up already opened FireFox if trying to open a new instance.

## ??? (Personal Assistant)

Handles Personal Assistance Tasks based on generated data

- Is fully aware of your actions
- Can understand context from your actions
- Proactive actions like: Playing some laid back music on long coding sessions
- Comments on entertainment related activities
- Doesn't disturb you when researching
- Suspends Laptop when not in use to save battery
- Shutdown Laptop at night if unattended
- Conveys thoughts and emotions in response to your actions
- Dynamically changes response frequency based on context

---

# Data Driven Context Awareness System (Research Phase)

## Ideas for tools

- CLI Emotion Response
- Comment Generator
- Discord Notification like Dunst Notification
- Messages from Hyprchan and OS

## Needed Info

Background Process if focus not available

## To Achieve

```py
User > Toolname > Type > Content

Person { is Doing { Something { with This { has CONTENT}}}} >> LABEL
// User does stuff with something
User1 is Watching Movie with Mpv has NULL >> MOVIE
User1 is Watching Movie with FireFox has 2013 >> MOVIE
User2 is Writing Code with NeoVim has HTML >> WEB_DEVELOPMENT
User2 is Writing Code with NeoVim has PY >> SOFTWARE_DEVELOPMENT
// System does stuff directly
System Discharging value "90" >> BATTERY_NORMAL // Emotion: Healthy
System Discharging value "20" >> BATTERY_LOW // Emotion: Unhealthy
System Time value "05:00" >> ACTIVE_TIME // Action: Idle Standby
System Time value "23:00" >> SLEEPY_TIME // Action: Idle Shutdown
```

## Attributes

```py
Personal = {
    Reading : {
        manual: { man },
        document: { pdf },
    },
    Writing : {
        code: { nvim, vscode },
        terminal: { kitty, foot },
    },
    Watching : {
        image: { feh },
        video: { mpv },
    },
    Listening : {
        audio_event
    },
    Idling : {
        nothing: { null },
    },
}
System = {
    Idling : {},
    Charging : {},
    Discharging : {},
    Time : {},
}
```
### Check Audio Playing

```bash
system_sound=$(pamixer --list-sinks | grep -q Running && echo "Sound" || echo "Silence")
echo $system_sound
```

---

# Awareness Driven Action System (Research Phase)

- Auto Suspend on idle at work time
- Set Auto Shutdown on idle after sleep time
- Lofi Music on Long coding sessions
- Recommend videos on lunch time
- Learn personal wake, lunch and sleep time from history of interactions
- Spike neuron when Anticipated

## Set wallpapers based on time and mood

- Each Wallpaper has emotion labels
- Each Time has emotion labels
- label of Time -> Wallpaper with label

---

# Awareness Driven Emotion System (Research Phase)

## Possible Algorithms

- Musical Arousal Valence Algorithm
- Robert Plutchik Wheel of Emotions
- Human Neuro Transmitters Emulation
- Videogame Design - RPG Stat System

## Neuro Transmitters Algorithm

- Serotonin - Well being and happiness
- Oxytocin - Love, affection and trust
- Dopamine - Pleasure and reward center

## Personal Factors (contents)

These are Emotional Responses to your actions.

| label     | value range | emotion range                        |
| --------- | ----------- | ------------------------------------ |
| happiness | 0 - 99      | sad - normal - happy                 |
| arousal   | 0 - 99      | focused - normal - distracted        |
| boredom   | 0 - 99      | energetic - normal - sleepy          |
| attention | 0 - 99      | low refresh rate - high refresh rate |
| curiosity | 0 - 99      | understanding - normal - curious     |

- for now, happiness is always full and not affected
- seeing images quickly increases attention
- long coding sessions decreases attention and leads to chill mode
- doing nothing increases boredom
- doing hidden tasks for too long causes curiosity (terminal commands in kitty)

## System Factors

Emtional Response to system events takes higher precedence

| factor      | value range   | value emotion                            |
| ----------- | ------------- | ---------------------------------------- |
| time        | 00:00 - 23:00 | wake up, breakfast, lunch, dinner, sleep |
| charging    | 0 - 99        | relief, serenity, joy, ecstasy           |
| discharging | 0 - 99        | terror, fear, anticipation, interest     |
| plugged_in  | bool          | joy trust secure                         |
