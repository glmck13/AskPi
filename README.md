# Askpi
A lightweight personal assitant for your Linux/Raspberry Pi host
## Background
For some time I've wanted to convert my Raspberry Pi into a personal assitant, like Amazon's Alexa, Apple's Siri, etc.  I dabbled with [Amazon's Alexa Skill Kit (ASK)](https://developer.amazon.com/alexa-skills-kit), and [Facebook's WIT](https://wit.ai/), but was frustrated since I had to develop and host my app in their cloud.  Moreover, I wasn't looking to develop a very sophisticated voice command system, just something that could respond to some very basic utterances.  

In essence, the personal assistant is composed of three components:
1. a speech-to-text (STT) voice recognition service
2. a command processing engine
3. a text-to-speech (TTS) utility
  
Once the STT part is solved, the other components of the solution are relatively easy to address.  Aay scripting language can handle #2, while pico2wave/espeak/etc. are viable alternatives for TTS.
