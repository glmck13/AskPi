# Askpi
A lightweight personal assistant for your Linux/Raspberry Pi host
## Background
For some time I've wanted to convert my Raspberry Pi into a personal assistant, like Amazon's Alexa, Apple's Siri, etc.  I dabbled with [Amazon's Alexa Skill Kit (ASK)](https://developer.amazon.com/alexa-skills-kit), and [Facebook's WIT](https://wit.ai/), but was frustrated since I had to develop and host my app in their cloud.  Moreover, I wasn't looking to develop a very sophisticated voice command system, just something that could respond to some very basic verbal cues.  

In essence, a personal assistant is composed of three components:
1. a speech-to-text (STT) voice recognition service
2. a command processing engine
3. a text-to-speech (TTS) utility
  
Once the STT part is solved, the other elements of the solution are relatively easy to address.  Any scripting language can handle #2, while pico2wave, espeak, etc. are viable alternatives for TTS.  The difficulty is in trying to implement a stand-alone STT service on the Pi that's halfway decent.  Moreover, a mechanism must be designed to detect when a user starts & stops speaking.  

Then it dawned on me... Mobile phones are one of the best STT appliances out there.  Instead of trying to replicate an STT solution on the Pi, I could just leverage a mobile phone for this.  Not an optimal solution, but not such a bad one either!  Moreover, using the phone would allow me to create a richer user experience, as you'll see.  

So if I need a mobile phone, how is this any different from just using the voice assistant that's already built into the phone?  First of all, by hosting the processing engine locally, I can create a much more personal & customized experience.  If I ask my assistant for sport scores, for example, it might play the scores for just my teams.  Moreover, I can create customized voice assistants for special events, like weddings, business meetings, etc.  

Enough background, let's talk about how to install and configure the solution.

## Installation
Start with a default raspbian build for the Pi, and follow the [installation instructions on the "MyVitals" wiki](https://github.com/glmck13/MyVitals/wiki/1-Install) to configure a web server & sound support.  Don't bother with any of the Bluetooth setup, since that won't be needed for this project.  You'll also need to install a few more packages:
```
sudo ksh
apt install gridsite-clients # contains urlencode
apt install libttspico-utils # contains pico2wave
```
Now that you have the basic server platform installed, copy the supplied .cgi, .dat, and .cfg files somewhere under /var/www/html.  I created an "Askpi" folder, and installed them there.  You'll also need to create a local "tmp" directory in the same folder where you deposit the cgi scripts. Afterwards, be sure to set the correct file ownership and permissions:
```
sudo ksh
cd /var/www
chown -R www-data:www-data .
cd /var/www/html/Askpi
chmod +x *.cgi
```
## Usage & Configuration
* In order to interact with your assitant, open a web browser on your smart phone (or any other client), and navigate to the URL where you installed askpi.  Screen #1.  
* Tap on the text box to enter a message.  A keyboard will appear.  Screen #2.  
* Use the keyboard to type a message directly into the text box, or better yet, tap the microphone icon to voice a message using the speech-to-text capabilities built into the phone.  Screen #3.  
* After a message is populated in the text box, select whether or not you'd like the assistant to read the response aloud from the Pi's speaker (Announce=Y/N), then click submit.  Screen #4.  
* The Pi will process the message based on the instructions you've specified within "assist.dat", and deliver a response.  Screen #5.  
#1: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen1.png height=250> #2: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen2.png height=250> #3: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen3.png height=250> #4: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen4.png height=250> #5: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen5.png height=250>

The "assist.dat" file is structured as a series of "expr" or "grep"-like regular expressions, followed by commands to execute once a regex is matched.  Lines in the file are ignored until a regex is encountered that matches the supplied input text.  Once a matching regex is encountered, all subsequest lines in the file are processed until a line is found that begins with a period ".".  

If a line does **not** start with a special character (more on those below), it is treated as a text string that is passed to the text-to-speech engine for subsequent output.  These lines can incorporate embedded shell commands - using '$( )' syntax - to include dynamic content in the output.   

Altermatively, if a line begins with any of the special characters below, it is processed as described in the table:  

| Char | Meaning |
| --- | --- |
| '#' | Treat line as a comment |
| '!' | Pass line to shell for execution |
| '.' | Exit script processing |
| '=' | Match supplied text against regex pattern |
| '+' | Match (previous & current) text against regex pattern |
| '~' | Override last text assignment |

