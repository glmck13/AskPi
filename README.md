# Askpi
A lightweight personal assistant for your Linux/Raspberry Pi host
## Background
For some time I've wanted to convert my Raspberry Pi into a personal assistant, like Amazon's Alexa, Apple's Siri, etc.  I dabbled with [Amazon's Alexa Skill Kit (ASK)](https://developer.amazon.com/alexa-skills-kit), and [Facebook's WIT](https://wit.ai/), but was frustrated since I had to develop and host my app in their cloud.  Moreover, I wasn't looking to develop a very sophisticated voice command system, just something that could respond to some very basic utterances.  

In essence, a personal assistant is composed of three components:
1. a speech-to-text (STT) voice recognition service
2. a command processing engine
3. a text-to-speech (TTS) utility
  
Once the STT part is solved, the other elements of the solution are relatively easy to address.  Any scripting language can handle #2, while pico2wave, espeak, etc. are viable alternatives for TTS.  The difficulty is in trying to implement a stand-alone STT service on the Pi that's halfway decent.  Moreover, a mechanism must be designed to detect when a user starts & stops speaking.  

Then it dawned on me... Mobile phones are one of the best STT appliances out there.  Instead of trying to replicate an STT solution on the Pi, I could just leverage a mobile phone for this.  Not an optimal solution, but not such a bad one either!  Moreover, using the phone would allow me to create a richer user experience, as you'll see.  

So if I need a mobile phone, how is this any different from just using the voice assistant that's already built into the phone?  First of all, by hosting the processing engine locally, I can create a much more personal & customized experience.  If I ask my assistant for sport scores, for example, it might play the scores for just my teams.  Moreover, I can create customized voice assistants for special events, like birthday parties, business meetings, etc.  

Enough background, let's talk about how to install and configure the solution.

## Installation
Start with a default raspbian build for the Pi, and follow the [installation instructions on the "MyVitals" wiki](https://github.com/glmck13/MyVitals/wiki/1-Install) to configure a web server & sound support.  Don't bother with any of the Bluetooth setup, since that won't be needed for this project.  You'll also need to install a few more packages:
```
sudo ksh
apt install gridsite-clients # contains urlencode
apt install libttspico-utils # contains pico2wave
```
Now that you have the basic server platform installed, copy the supplied .cgi, .dat, and .cfg files somewhere under /var/www/html.  I created an "Askpi" folder, and installed them there.  Afterwards, be sure to set the correct file ownership and permissions:
```
sudo ksh
cd /var/www
chown -R www-data:www-data .
cd /var/www/html/Askpi
chmod +x *.cgi
```
## Usage & Configuration
In order to interact with your assitant, open a web browser on your smart phone (or any other client), and navigate to the URL where you installed Askpi.  You'll see a screen which looks like this:  
![](/docs/askpi.png)
The box is simply a text-input box.  You can choose to type a message directly into this box, or better yet, invoke the STT feature on your smart phone to voice a message.  To accees the speech-to-text capabiltiy on an iPhone, for example, first tap somewhere inside the text box.  At this point a keyboard will appear on your screen which contains a small microphone icon on the bottom:  
![](/docs/iphone.png)
Tap the microphoe, and utter some text.  After the text is populated in the text box, click submit.
