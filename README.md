# Your-Steam-Library-Infomercial
Rediscover your Steam Library!

PURPOSE
    
        Provide Steam Users with an Infomercial or demo-mode to help them explore their Steam Library.

        Do you have a problem of owning too many games, and don't know what's in your massive library?
        Do you remember purchasing a good game based on the video or pictures, but now forget what it was?
        This is where this script comes in.  It helps you re-discover your library with minimal effort! 

        All you need to do is plug in a valid Steam profile URL, click search, and it will generate
        a randomized playlist of games, based off of the provided profile.  It will then start showing
        you the library.  
        
        Watch the infomercial-like presentation as you drift off to sleep, or when you're bored, or take
        control by stepping forward or backwards through the library.

        It pulls resources from Steam, and uses your own computer's resources.

    USAGE

        -View the VARIABLES / USER section of the script for available fine tuning before running.
        -Run the powershell script on a Windows computer.
        -The script is primarily handled through the front-end browser interface.
        -The back-end is primarily used to alert the user of what's happening.

    INTERACTIONS:

        HOME PAGE:
            -Search Box - enter a full steam profile address.
            -Submit Button - Submit a search
            -Quit Button - Quit the application

        HOME PAGE WHEN PROFILE IS LOADED:
            The same as HOME PAGE, but including:
            -Profile Button - clicking will take you to the profile page of the library you're currently viewing.
            -Backward Arrow Button - Go to the profile's previous game.
            -Forward Arrow Button - Go to the profile's next game.

        VIDEO OR IMAGE PAGE:
            -Logo Button - clicking will take you to the Steam Page of the game being played.
            -Play Button - clicking will launch the steam client.  If you own the game it will attempt to play or install. If not it will take you to the Steam store page.
            -Home Button - Clicking will take you to HOME PAGE WHEN PROFILE IS LOADED.
            -Reload Button - Clicking will cycle you to the next media available for the current game.
            -Backward Arrow Button - Go to the profile's previous game.
            -Forward Arrow Button - Go to the profile's next game.

        QUIT PAGE
            -None.


    BEST USAGE:

        -Start Script with default settings.
        -Visit http://localhost:8080 if the web page doesn't open.
        -Enter a valid, non private, profile with publicly viewable games.
        -Press F11 to view the library in full screen.
        -Use on-screen buttons to navigate. See: INTERACTIONS
        
                
    PROBLEMS

        If you encounter problems with it:
        - Close your instance of Powershell to purge all variables, and retry again with the original script.
        - Capture a log.. or any unhandled errors.. paste them to github.

        If videos don't seem to be playing, it may be due to the browser settings preventing autoplay.
        -Firefox : Follow this: https://support.mozilla.org/en-US/kb/block-autoplay
        -Try using MS Edge.

        If you don't quit the script gracefully, you might leave a web port open, and might need to manually run "StopServer"
        in the terminal to terminate it.

        This is a single-user web application.  Technically more than one person can use it at a time,
        but due to the game data being stored locally it can have unintended effects if more than one user uses it
        (such as seeing games that aren't in your library).

    TECHNICAL

        Internet required!

    TESTING:

        Windows 10 Version 2004
        Powershell Version 5.1.19041.1
        Firefox Version 80.0.1
        Microsoft Edge Version 44.19041.423.0
