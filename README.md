# Your-Steam-Library-Infomercial
## Rediscover your Steam Library!
![Your Steam Library Infomercial](https://user-images.githubusercontent.com/16578236/93937273-d5ac8480-fcfd-11ea-916e-96a27ab960de.png)



### PURPOSE
Do you have a problem of owning too many games, and don't know what's in your massive library?

Do you remember purchasing a good game based on the video or pictures, but now forget what it was?

This is where this script comes in.  It helps you re-discover your library with minimal effort! 

It provides Steam Users with an Infomercial or demo-mode to help them explore their Steam Library.

Watch the infomercial-like presentation as you drift off to sleep, or when you're bored, or take
control by stepping forward or backwards through the library!



## USAGE
1. Download _Your Steam Library Infomercial.ps1_
2. Run the script on your computer.
3. Visit the home page (Default is http://localhost:8080 )
4. Plug in a valid Steam profile URL
5. Click search, and it will generate a randomized playlist of games.
6. Press F11 in your browser, sit back and enjoy!
7. Use on-screen buttons to navigate. See: INTERACTIONS
        
![Infomercial Screen](https://user-images.githubusercontent.com/16578236/93937232-c62d3b80-fcfd-11ea-8ced-9088a873d189.png)

![Back End View](https://user-images.githubusercontent.com/16578236/93941345-a0effb80-fd04-11ea-8fb7-ed0aa40e0e8c.png)



## OPTIONAL
View the VARIABLES / USER section of the script for available fine tuning before running.



## INTERACTIONS

**HOME PAGE**
- Search Box - enter a full steam profile address.

- Submit Button - Submit a search

- Quit Button - Quit the application


**HOME PAGE WHEN PROFILE IS LOADED**
 (The same as HOME PAGE, but including:)
 
- Profile Button - clicking will take you to the profile page of the library you're currently viewing.

- Backward Arrow Button - Go to the profile's previous game.

- Forward Arrow Button - Go to the profile's next game.


**VIDEO OR IMAGE PAGE**
- Logo Button - Clicking will take you to the Steam Page of the game being played.

- Play Button - Clicking will launch the steam client to attempt to play or install, or take you to the Steam store page.

- Home Button - Clicking will take you to HOME PAGE WHEN PROFILE IS LOADED.

- Reload Button - Clicking will cycle you to the next media available for the current game.

- Backward Arrow Button - Go to the profile's previous game.

- Forward Arrow Button - Go to the profile's next game.


**QUIT PAGE**
- None.


## PROBLEMS

_For general problems:_

- Close your instance of Powershell to purge all variables, and retry again with the original script.

- Capture a log.. or any unhandled errors.. paste them to github.



_If videos don't seem to be playing, it may be due to the browser settings preventing autoplay:_

- Firefox : Follow this https://support.mozilla.org/en-US/kb/block-autoplay

- Try using MS Edge.

_If you don't quit the script gracefully, you might leave a web port open, and might need to manually run "StopServer" in the terminal to terminate it._

This is a single-user web application.  Technically more than one person can use it at a time, but due to the game data being stored locally it can have unintended effects if more than one user uses it (such as seeing games that aren't in your library).



## TECHNICAL
Internet required!



## TESTING
Windows 10 Version 2004

Powershell Version 5.1.19041.1

Firefox Version 80.0.1

Microsoft Edge Version 44.19041.423.0
