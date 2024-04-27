import sys

user_request = sys.argv[1]
window_class = sys.argv[2]
window_title = sys.argv[3]


# █▀▄▀█ ▄▀█ █ █▄░█   █░░ █▀█ █▀▀ █ █▀▀
# █░▀░█ █▀█ █ █░▀█   █▄▄ █▄█ █▄█ █ █▄▄
def main():
    if user_request == 'content':
        content = general_content(window_title)  # Type of content present
        print(content)
        exit(0)

    if user_request == 'wintype':
        wintype = window_type(window_class)  # On this type of software
        print(wintype)
        exit(0)

    if user_request == 'action':
        wintype = window_type(window_class)  # On this type of software
        action = context_action(wintype, window_title)  # Doing specific thing
        print(action)
        exit(0)


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
