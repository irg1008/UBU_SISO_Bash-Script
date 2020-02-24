from gtts import gTTS
import os

fh = open("test.txt", "r")
myText = fh.read().replace("\n", " ")

language = 'es'

output= gTTS(text=myText, lang=language, slow=False)

output.save("output.mp3")

os.system("xdg-open output.mp3")