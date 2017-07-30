# AskPi
A lightweight virtual assitant for your Linux/Raspberry Pi host, integrating APIs for Google Speech & Amazon Polly  
<img src=https://github.com/glmck13/Askpi/blob/master/docs/architecture.png>  
 
## Update: July 22, 2017
Added a pocketsphinx utility to listen for verbal cues to supplement the iTag.

## Update: July 15, 2017
Finished integrating AWS Polly to provide higher quality text-to-speech.  Also added a hook to perform Google searches. 

## Update: July 4th, 2017
When I first published this project, I decided to forego speech recognition on the Pi, and just focus on the backend processing engine.  But I couldn't shake the urge to add a voice processing component, so I finally took the plunge, and recently tackled that part as well.  

The design is pretty simple.  I implement a very basic client that records user speech, translates this to text (using Google's API), then submits the translated text to the CGI backend I had built in phase one.  The client then post-processes URLs returned from the CGI app, and outputs these on the Pi using the appropriate video/audio player.  Most recently I integrated Amazon's text-to-speech service (Polly) to render all spoken responses.  

In order to simplify the design, I needed a way to detect when to listen for verbal input from a user.  At first I experimented with [pocketsphinx_continuous](https://cmusphinx.github.io/) - a copy of which is already included in the Raspian distribution - with the intent of recognizing a set of verbal cues that might be used to initiate a transaction with the Pi (just like Captain Kirk addresses the ship's computer as "Computer" on Star Trek).  While this worked much of the time, the pocketsphinx engine was still prone to make translation errors, especially in noisy environments.  

My answer?  A little gadget I used in my [MyVitals](../../../MyVitals) project: the iTag.  The iTag is essentially a wireless button that connects to the Pi over its Bluetooth (low energy) interface.  So in order for a user to "talk" to the Pi, they must first press the button on the iTag.  The Pi will respond with a short "beep" that signals to the user to talk into the microphone.  The Pi then records a few seconds of user speech, and submits this to Google's speech-to-text platform for translation.  

## Parts List
The table below lists the parts you'll need to build your virtual assitant.  All of the items can be ordered on Amazon.  Total cost is ~$100.  

| Description | Price |
| --- | --- |
| [CanaKit Raspberry Pi 3 Complete Starter Kit - 32 GB Edition](https://www.amazon.com/exec/obidos/ASIN/B01C6Q2GSY) |	$69.99 |
| [Plugable USB Audio Adapter with 3.5mm Speaker/Headphone and Microphone Jacks](https://www.amazon.com/exec/obidos/ASIN/B00NMXY2MO) | $7.85 |
| [Connectland Goose Neck Tabletop Stereo Microphone with Stand](https://www.amazon.com/exec/obidos/ASIN/B0028Y4DCC) | $6.99 |
| [Satechi iTour-Pop 3.5mm Aux Portable Rechargeable Speaker](https://www.amazon.com/exec/obidos/ASIN/B003Y7PXSK) | $12.99 |
| [Mini Wireless Phone Bluetooth 4.0 Tracker Alarm iTag](https://www.amazon.com/exec/obidos/ASIN/B01CEEIJUW) | $6.99 |

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
Start with a default raspbian build for the Pi, and follow the [installation instructions on the "MyVitals" wiki](../../../MyVitals/wiki/1-Install) to configure a web server, bluetooth, and sound support.  It seems that "gatttool" is no longer built by default when compiling the BlueZ package, so you may need to add both "--enable-deprecated" and "--enable-experimental" when running the initial "configure" script.  Go ahead and install the following packages as well:  
```
apt install gridsite-clients # urlencode
apt install pocketsphinx # primitive speech-to-text engine
apt install libttspico-utils # pico2wave text-to-speech engine
apt install sox # rec & play, and synthesized sound
apt install mpg123 # mp3 player
```
Before omxplayer can play YouTube videos on the Pi, I found that YouTube URLs need to be pre-processed to extract the actual audio/video feeds.  The "youtube-dl" python script seems to do a good job with this.  You can download the latest version here: https://rg3.github.io/youtube-dl/download.html.  

I stumbled upon a few other annoyances when trying to play sound & video files on the Pi.  First, recordings would sometimes play in rapid fire.  I don't know whether this behavior can be attributed to using the Plugable USB interface or not.  Regardless, I found that adding "-o alsa:plughw:Device" to omxplayer effectively eliminated the problem.  Similarly, when generating synthetic souds using sox, it would help to specify a sample rate of 16K, i.e. "play -n -r 16k synth ..."   

Now that you have the basic server platform installed, copy the supplied .sh, .cgi, .dat, and .conf files somewhere under /var/www/html.  I created an "Askpi" folder, and installed them there.  You'll also need to mkdir a "tmp" directory in the same folder where you deposit the cgi scripts.  And if you plan to use the askpi.sh voice client, you'll also need to mknod a "askpi.fifo" named pipe in that same folder (mknod askpi.fifo p).  Afterwards, be sure to set the correct file ownership and permissions:
```
sudo ksh
cd /var/www
chown -R www-data:www-data .
cd /var/www/html/Askpi
chmod +x *.cgi
```
One last thing...  The askpi.sh client will try to launch a web browser on the local console whenever it receives a URL from the web assitant that's not an audio/video file (for example, when the user asks to perform a Google search).  In order to open a browser, the client needs permission to access the DISPLAY.  Follow the instructions [here](https://raspberrypi.stackexchange.com/questions/28199/raspberry-pi-starting-programs-automatically-on-startup) to add an "xhost +" command under  Preferences->LXSession->Autostart.

## Google & Amazon cloud services
As mentioned above, the askpi.sh client uses [Google's cloud for speech-to-text services](https://cloud.google.com), and [Amazon's cloud for text-to-speech](https://console.aws.amazon.com).  In order to make use of the client, you'll first need to establish an account with these cloud providers, then obtain credentials to populate in credentials.conf.   

I use the "curl" command to invoke the APIs for these services directly, so there's no need to install/configure any additional SDKs on your Pi.  The google-stt.sh and aws-polly.sh scripts are written as classic UNIX filters:
* google-stt.sh reads a wav-formatted file fron stdin (mono, 16k sampling rate), and outputs a plain text translation to stdout.  [Here's a link that describes how to build the Google API request](https://cloud.google.com/speech/docs/)  
* aws-polly.sh reads plain text fronm stdin, and outputs an mp3-formatted audio stream to stdout.  [Here's a link that describes how to build the Amazon API request](http://czak.pl/2015/09/15/s3-rest-api-with-curl.html)     

## Use Case: Connecting with a smart phone
1. In order to interact with your assistant, open a web browser on your smart phone (or any other client), and navigate to the URL where you installed askpi.  Screen #1.  

2. Tap on the text box to enter a message.  A keyboard will appear.  Screen #2.  

3. Use the keyboard to type a message directly into the text box, or better yet, tap the microphone icon to voice a message using the speech-to-text capabilities built into the phone.  Screen #3.  

4. After a message is populated in the text box, select whether or not you'd like the assistant to read the response aloud from the Pi's speaker (Announce=Y/N), then click submit.  Screen #4.  

5. The Pi will process the message based on the instructions you've specified within "assist.dat", and deliver a response.  Screen #5.  

#1: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen1.png height=250> #2: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen2.png height=250> #3: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen3.png height=250> #4: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen4.png height=250> #5: <img src=https://github.com/glmck13/Askpi/blob/master/docs/screen5.png height=250>  

A playback widget will appear on the response screen if the assistant generated an audio reply.  The user can use the controls on the playback widget to listen to the reply on their local client.  A written transcript of the audio will also be displayed below the playback widget.  

As I mentioned above, the fact that askpi requires a client device to process speech input is both a drawback and benefit, as compared to other personal assistants like Amazon's Alexa.  One benefit of using a client device, for example, is the ability to integrate additional content (in addition to audio) into a response, making for a richer user experience.  Additional text, images, and even video can be incorporated into a response, which will appear following the audio transcript.

## Use case: Connecting with a microphone & speaker
In addition to interacting with the assitant using a smart phone, you can also do so using native audio I/O on the Pi.  The config.cgi script includes buttons at the bottom of the page to start/stop the askpi.sh voice client.  While the client is running, press the button on the iTag, wait for a short beep, then speak a command into the microphone.  Alternatively, speak one of the verbal cues/keywords into the microphone, wait for a short beep, then speak a command.  The system will submit the voice snippet to Google speech, submit the translated text to the local CGI assitant, then process the output from the assitant using the appropriate audio/video players on the Pi.  Any text returned by the assitant will be spoken alond on the speaker after being processed through Amazon Polly.  If your Pi is haedless (no monitor), and you issue a command that invokes a web browser (e.g. you request a Google search), you can export the browser X display to another host by populating the "Display" field when starting the voice client.

## Configuration: Populating "assist.dat"
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
