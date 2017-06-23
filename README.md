# AskPi
A lightweight virtual assistant for your Linux/Raspberry Pi host  
<img src=https://github.com/glmck13/Askpi/blob/master/docs/Askpi.jpg height=300>  

## Background
For some time I've wanted to convert my Raspberry Pi into a virtual assistant, like Amazon's Alexa, Apple's Siri, etc.  I dabbled with [Amazon's Alexa Skill Kit (ASK)](https://developer.amazon.com/alexa-skills-kit), [Facebook's WIT](https://wit.ai/), and [Recast.ai](https://recast.ai) but was frustrated since I had to develop and host my app in their cloud.  Moreover, I wasn't looking to develop a very sophisticated voice command system, just something that could respond to some very basic verbal cues.  

In essence, a virtal assistant is composed of three components:
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
apt install gridsite-clients # contains urlencode utility
apt install libttspico-utils # contains pico2wave text-to-speech engine
```
Now that you have the basic server platform installed, copy the supplied .cgi, .dat, and .cfg files somewhere under /var/www/html.  I created an "Askpi" folder, and installed them there.  You'll also need to create a local "tmp" directory in the same folder where you deposit the cgi scripts. Afterwards, be sure to set the correct file ownership and permissions:
```
sudo ksh
cd /var/www
chown -R www-data:www-data .
cd /var/www/html/Askpi
chmod +x *.cgi
```
## Use
1. In order to interact with your assistant, open a web browser on your smart phone (or any other client), and navigate to the URL where you installed askpi.  Screen #1.  

2. Tap on the text box to enter a message.  A keyboard will appear.  Screen #2.  

3. Use the keyboard to type a message directly into the text box, or better yet, tap the microphone icon to voice a message using the speech-to-text capabilities built into the phone.  Screen #3.  

4. After a message is populated in the text box, select whether or not you'd like the assistant to read the response aloud from the Pi's speaker (Announce=Y/N), then click submit.  Screen #4.  

5. The Pi will process the message based on the instructions you've specified within "assist.dat", and deliver a response.  Screen #5.  

#1: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen1.png height=250> #2: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen2.png height=250> #3: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen3.png height=250> #4: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen4.png height=250> #5: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen5.png height=250>  

A playback widget will appear on the response screen if the assistant generated an audio reply.  The user can use the controls on the playback widget to listen to the reply on their local client.  A written transcript of the audio will also be displayed below the playback widget.  

As I mentioned above, the fact that askpi requires a client device to process speech input is both a drawback and benefit, as compared to other personal assistants like Amazon's Alexa.  One benefit of using a client device, for example, is the ability to integrate additional content (in addition to audio) into a response, making for a richer user experience.  Additional text, images, and even video can be incorporated into a response, which will appear following the audio transcript.

## Configuration
Input text, which is saved in the "$Speech" variable, is processed according to directives specified in askpi's "assist.dat" file. The assist.dat file is comprised of a series of "expr" or "grep"-like regular expressions, followed by commands to execute once a regex is matched.  Lines in the file are ignored until a regex is encountered that matches the supplied input text.  Once a matching regex is encountered, all subsequent lines in the file are processed until a line is found that begins with a period ".".  

If a line does **not** start with a special character (more on those below), it is treated as a text string that is passed to the text-to-speech engine for subsequent output.  These lines can incorporate embedded shell commands - using '$( )' syntax - to include dynamic content in the output.   

Alternatively, if a line begins with any of the special characters below, it is processed as described:  

| Char | Meaning |
| --- | --- |
| # | Treat line as a comment |
| ! | Pass line to shell for execution |
| ' | Append line (usually html text) to response |
| . | Exit script processing |
| = | Match "$Speech" against regex pattern |
| + | Match "$LastWord $Speech" against regex pattern |
| ~ | Set LastWord text to be returned in next cgi call |
  
Use of '\~' and '+' requires some futher explanation... I wanted to implement a simple dialogue capability in the assistant,
but to do so, I needed a way to preserve the $Speech (or some other context) entered in one cgi script and pass it to the next.
Another advantage of using a web browser to interface to the platform is the ability to save cookies, which provide exactly
what's needed to do this.  By default, askpi populates a browser cookie (called "LastWord") with the current message text,
so this is available to a follow-on call.  Alternatively, the "LastWord" cookie can be populated with some other string by
using the '~' character.  As mentioned in the table above, a line starting with '=' in assist.dat makes a comparison against the
current text input string, "$Speech", while a line starting with '+' attempts to match against a string containing the
prior text/context prepended to the current input, i.e. "$LastWord $Speech".  

As regards the quote character ', this is a handy mechanism to incorporate additional content in responses.
Just as in the case of plain speech directives, you can make use of embedded shell commands - using '$( )' syntax - to
inject dynamic content. Use html markup tags to embed text, lists, images, and
[even additional audio and video content using HTML5](https://www.w3schools.com/html/html_media.asp).
I created a separate "docs" directory under my askpi installation folder to store any custom content I wanted
to include.  

I hope you find this project both fun & useful.  I'd appreciate any feedback.  Enjoy!
