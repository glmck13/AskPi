# Askpi
A lightweight personal assitant for your Linux/Raspberry Pi host
## Background
For some time I've wanted to convert my Raspberry Pi into a personal assitant, like Amazon's Alexa, Apple's Siri, etc.  I dabbled with [Amazon's Alexa Skill Kit (ASK)](https://developer.amazon.com/alexa-skills-kit), and [Facebook's WIT](https://wit.ai/), but was frustrated since I had to develop and host my app in their cloud.  Moreover, I wasn't looking to develop a very sophisticated voice command system, just something that could respond to some very basic utterances.  

In essence, a personal assistant is composed of three components:
1. a speech-to-text (STT) voice recognition service
2. a command processing engine
3. a text-to-speech (TTS) utility
  
Once the STT part is solved, the other components of the solution are relatively easy to address.  Any scripting language can handle #2, while pico2wave/espeak/etc. are viable alternatives for TTS.  The difficulty is in trying to implement a stand-alone STT service on the Pi that's halway decent.  Moreover, a mechanism must be designed to detect when a user starts & stops speaking.  

Then it dawned on me... Mobile phones are one of the best STT appliances out there.  Instead of trying to replicate an STT solution on the Pi, I could just leverage a mobile phone for this.  Not an optimal solution, but not such a bad one either!  Moreover, using the phone would allow me to create a richer user experice, as you'll see.  

So if I need a mobile phone, how is this any differnet from just using the vioce assitant that's already built into the phone?  First of all, by hosting the processing engine locally, I can create a much more personal & customized experience.  If I ask my assitant for sport scores, for example, it might play the scores for just my teams.  Moreover, I can create customized vioce assistants for special events, like birthday parties, business meetings, etc.  

Enough background, let's talk about how to install and configure the solution.

## Installation
## Configuration
