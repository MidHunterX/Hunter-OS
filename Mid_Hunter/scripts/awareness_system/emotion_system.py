import time

emotion_queue = {"happy": 0, "sad": 0, "angry": 0, "neutral": 0}
decay_rate = 1

def update_emotion(content_type):
    if content_type == "happy":
        emotion_queue["happy"] += 10
    elif content_type == "sad":
        emotion_queue["sad"] += 10
    elif content_type == "angry":
        emotion_queue["angry"] += 10
    else:
        emotion_queue["neutral"] += 10


def decay_emotions():
    for emotion in emotion_queue:
        emotion_queue[emotion] -= decay_rate
        if emotion_queue[emotion] < 0:
            emotion_queue[emotion] = 0


# Function to simulate AI's response based on current emotional state
def ai_response():
    dominant_emotion = max(emotion_queue, key=emotion_queue.get)
    if emotion_queue[dominant_emotion] > 0:
        print(f"AI is feeling {dominant_emotion}!")
    else:
        print("neutral.")


# Simulating interactions with content
update_emotion("happy")
update_emotion("happy")
update_emotion("sad")
update_emotion("neutral")

# Simulating decay over time
for _ in range(5):
    decay_emotions()
    time.sleep(1)  # Simulating 1 second passing

# Simulating AI's response
ai_response()
