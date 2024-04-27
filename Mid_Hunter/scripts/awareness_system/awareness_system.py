import sys

window_class = sys.argv[1]
window_title = sys.argv[2]
# window_class = "firefoxdeveloperedition"
# window_title = "firefoxdeveloperedition | How to draw on metal. Easy to make at home - YouTube — Firefox Developer Edition"


# █▀▄▀█ ▄▀█ █ █▄░█   █░░ █▀█ █▀▀ █ █▀▀
# █░▀░█ █▀█ █ █░▀█   █▄▄ █▄█ █▄█ █ █▄▄
def main():
    wintype = window_type(window_class)  # On this type of software
    action = context_action(wintype, window_title)  # Doing specific thing
    content = general_content(window_title)  # Type of content present
    # Default: Something on NULL for Nothing
    print(f"{action} on {wintype} for {content}")


# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   ▀█▀ █▄█ █▀█ █▀▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   ░█░ ░█░ █▀▀ ██▄
# Converts window_class -> window_type
# Window Types: terminal, browser, image, video, document, nothing
def window_type(window_class):
    from window_types import window_types

    window_class = str(window_class).lower()
    for key in window_types:
        if key == window_class:
            return window_types[key]

    return window_types["null"]


# █▀▀ █▀█ █▄░█ ▀█▀ █▀▀ ▀▄▀ ▀█▀   ▄▀█ █▀▀ ▀█▀ █ █▀█ █▄░█
# █▄▄ █▄█ █░▀█ ░█░ ██▄ █░█ ░█░   █▀█ █▄▄ ░█░ █ █▄█ █░▀█
# Converts window_title -> context action
def context_action(window_category, window_title):
    from window_actions import category_actions

    window_title = str(window_title).lower()
    actions = category_actions[window_category]
    for key in actions:
        keywords = actions[key]
        for keyword in keywords:
            if keyword in window_title:
                return key

    # Default case
    return "nothing"


# █░█░█ █ █▄░█ █▀▄ █▀█ █░█░█   █▀▀ █▀█ █▄░█ ▀█▀ █▀▀ █▄░█ ▀█▀
# ▀▄▀▄▀ █ █░▀█ █▄▀ █▄█ ▀▄▀▄▀   █▄▄ █▄█ █░▀█ ░█░ ██▄ █░▀█ ░█░
# Window Title -> Window Content
def general_content(window_title):
    from window_contents import contents

    window_title = str(window_title).lower()
    for key in contents:
        keywords = contents[key]
        for keyword in keywords:
            if keyword in window_title:
                return key

    return "something"


if __name__ == "__main__":
    main()
