#region <# INFORMATION #>
<#

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

![Infomercial Screen](https://user-images.githubusercontent.com/16578236/93937232-c62d3b80-fcfd-11ea-8ced-9088a873d189.png)

![Back End View](https://user-images.githubusercontent.com/16578236/93941345-a0effb80-fd04-11ea-8fb7-ed0aa40e0e8c.png)



## USAGE
1. Download _Your Steam Library Infomercial.ps1_
2. Run the script on your computer.
3. Visit the home page (Default is http://localhost:8080 )
4. Plug in a valid Steam profile URL
5. Click search, and it will generate a randomized playlist of games.
6. Press F11 in your browser, sit back and enjoy!
7. Use on-screen buttons to navigate. See: INTERACTIONS



## OPTIONAL
View/set user variables on line **145** - **169** for fine tuning before running.



## INTERACTIONS


**HOME PAGE**

- Search Box - enter a full steam profile address.

- Submit Button - Submit a search

- Quit Button - Quit the application


**HOME PAGE WHEN PROFILE IS LOADED**
 
 The same as HOME PAGE, but includes:
 
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

- Capture a log, or any unhandled errors, and paste them to github.



_If videos don't seem to be playing, it may be due to the browser settings preventing autoplay:_

- Firefox : Follow this https://support.mozilla.org/en-US/kb/block-autoplay

- Try using MS Edge.

_If you don't quit the script gracefully, you might leave a web port open, and might need to manually run "StopServer" in the terminal to terminate it._

_This is a single-user web application._

Technically more than one person can use it at a time, but due to the game data being stored locally it can have unintended effects if more than one user uses it (such as seeing games that aren't in your library).



## TECHNICAL
Internet required!



## TESTED IN

Windows 10 Version 2004

Powershell Version 5.1.19041.1

Firefox Version 80.0.1

Microsoft Edge Version 44.19041.423.0

#>
#endregion <# INFORMATION #>


#region <# ASSEMBLIES #>


    Add-Type -AssemblyName System.Web


#endregion <# ASSEMBLIES #>


#region <# VARIABLES #>


    #region <# USER #>


        [bool] $RunScript = $true

        [bool] $Logging = $false                             # $true = Will log all selected output.  SEE: $LogFile & <# MESSAGE DISPLAY CONTROL #>

        [bool] $ShowGamesProtectedByAgeCheck = $true         # $false will not show any age-protected games.

        [bool] $SaveProfileData = $false                     # $true = Will save retrieved $Global:Profiles data on graceful exit.  SEE: $SaveFile

        [bool] $DefaultForward = $true                       # $false = will default to iterate stream backwards [user changes this in stream using forward/backward arrows or urls].

        [bool] $ShowVideoControls = $false                   # $true = will show HTML5 video controls for <video> elements.

        [uint16] $OnScreenControlFadeTime = 1000             # Milliseconds of no mouse movement for the on-screen controls to fade out [0 will hide them].

        [single] $DefaultLogoTransparency = 0.6              # How transparent the logo will be when resting. [0.0 - 1.0]

        [uint16] $InitialLogoFadeInTime = 6000               # Milliseconds for the initial logo fade-in on page-load to reach $DefaultLogoTransparency.

        [uint16] $PageFadeTime = 2000                        # Milliseconds the fade transition will last on page changes. [0-5000 = good (-gt 6000 = overkill)]

        [uint16] $ImageStillDisplayTime = 5000               # Milliseconds still images will be displayed in a slide show [3000-10000 = good ( -lt 3000 = psychedelic) ( -gt 10000 = overkill)]

        [uint16] $VideoTimeOutSeconds = 10                   # How many seconds it should take a video to begin playing before reloading the page.                         #TODO: Currently Unused

        [uint16] $GameReloadRetries = 2                      # How many failed $VideoTimeOutSeconds before giving up and moving to the next game.                          #TODO: Currently Unused


    #endregion <# USER #>


    #region <# SCRIPT #>


        [string] $ScriptName = (Get-Item $PSCommandPath).BaseName

        [string] $LogFile = "$((Get-Item $PSCommandPath).Directory.FullName)\$($ScriptName).log"

        [string] $SaveFile = "$((Get-Item $PSCommandPath).Directory.FullName)\$($ScriptName).sav"

        [system.array] $Global:Profiles = @()


    #endregion <# SCRIPT #>


    #region <# SERVER #>


        #region <# MESSAGE DISPLAY CONTROL #>


            [bool] $GoodMsg = $true

            [bool] $BadMsg = $true

            [bool] $ActionMsg = $true

            [bool] $NetMsg = $true

            [bool] $WebMsg = $true

            [bool] $NoticeMsg = $true


        #endregion <# LOGS & MESSAGES #>


        #region <# ROUTE NAMES #>


            [string] $Home = "Home"

            [string] $Forward = "Forward"

            [string] $Backward = "Backward"

            [string] $Quit = "Quit"

            [string] $ViewMore = "ViewMore"

            [string] $Reload = "Reload"

            [string] $ValidateProfile = "ValidateProfile"


        #endregion <# ROUTE NAMES #>


        #region <# HOME/QUIT PAGE COLOUR #>


            [string] $PageTopGradient = "#141d2d"

            [string] $PageBottomGradient = "#1f2021"

            [string] $TitleTopGradient = "#1b2838"

            [string] $TitleBottomGradient = "#2a475e"

            [string] $TitleTextColor = "#b2ddf5"


        #endregion <# HOME/QUIT PAGE COLORS #>


        [string] $WebHostname = "localhost"

        [string] $WebPort = "8080"

        [string] $WebServerAddress = "http://$($WebHostname):$($WebPort)"

        [string] $WebServerRoot = "$($WebServerAddress)/"

        [string] $UserDataVariable = "UserData"

        [uint16] $WebFailureLimit = 10

        [datetime] $UnixEpochTime = Get-Date -Year 1970 -Month 1 -Day 1 -Hour 0 -Minute 0 -Second 0

        [System.Net.HttpListener] $Global:WebServer = $null


    #endregion <# SERVER #>


    #region <# STEAM CONTROLLED #>


        [string] $SteamGameBaseURL = "https://store.steampowered.com/app/"            # + Appid + /

        [string] $SteamRunBaseURL = "steam://run/"                                    # + Appid + /

        [string] $SteamFavIcon = "https://steamcommunity.com/favicon.ico"

        [string] $SteamProfileGamesSuffix = "/games/?tab=all"

        [string] $SteamProfileAvatarClassName = "playerAvatar"

        [string] $SteamPofileAvatarImagePattern = "/avatars/"

        [string] $SteamPofileNameClassName = "whiteLink persona_name_text_content"

        [string] $SteamPrivateProfilePattern = "*This profile is private.*"

        [string] $SteamGameJSpattern = "var rgGames ="

        [string] $SteamAgeCheckPattern = "agecheck"

        [string] $SteamSetcookie = "Set-Cookie"

        [string] $SteamAgePostPattern = "&ageDay=1&ageMonth=January&ageYear="          # (e.g): "sessionid=da367081c6ef4c90faaefaed$($SteamAgePostPattern)1995"

        [string] $SteamAgePostURLReplacement = "/agecheckset/app/"

        [string] $SteamGameStoreMovieClassPattern = "highlight_player_item highlight_movie"

        [string] $SteamGameStoreImageClassPattern = "highlight_screenshot_link"

        [string] $SteamSDMP4Pattern = "data-mp4-source"

        [string] $SteamSDWebMPattern = "data-webm-source"

        [string] $SteamHDMP4Pattern = "data-mp4-hd-source"

        [string] $SteamHDWebMPattern = "data-webm-hd-source"


    #endregion <# STEAM CONTROLLED #>


    #region <# EMBEDDED IMAGES #>


        [string] $QuitImage = "data:image/png;base64,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"

        [string] $PlayImage = "data:image/png;base64,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"

        [string] $HomeImage = "data:image/png;base64,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"

        [string] $ViewMoreImage = "data:image/png;base64,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"

        [string] $BackwardImage = "data:image/png;base64,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"

        [string] $ForwardImage = "data:image/png;base64,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"


    #endregion <# EMBEDDED IMAGES #>


#endregion <# VARIABLES #>


#region <# CLASSES #>


    Class Profile
    {
        [string] $Name = ""

        [string] $URL = ""

        [string] $Avatar = ""

        [uint32] $Index = 0

        [uint16] $ReloadCount = $GameReloadRetries

        [uint16] $WebFailureCount = 0

        [system.array] $Games = @()
    }


    Class Game
    {
        [string] $AppID = ""

        [string] $Name = ""

        [string] $Store = ""

        [string] $Logo = ""

        [string] $Play = ""

        [string] $AllHours = ""

        [string] $RecentHours =  ""

        [dateTime] $LastPlayed = $UnixEpochTime

        [bool] $RetrievedFromWeb = $false

        [system.array] $Videos = @()

        [Images] $Images = $Null
    }


    Class Video
    {
        [bool] $Viewed = $false

        [string] $HDMP4

        [string] $HDWebM

        [string] $SDMP4

        [string] $SDWebM
    }


    Class Images
    {
        [bool] $Viewed = $false

        [system.array] $All = @()
    }


#endregion <# CLASSES #>


#region <# FUNCTIONS #>


    #region <# WEB SERVER #>


        #region <# LOGS & MESSAGES #>

            function GetScriptErrorLine
            {
                return $MyInvocation.ScriptLineNumber
            }


            function Logger
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($Logging)
                {
                    try
                    {
                        $Msg >> $LogFile

                        #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                    }
                    catch
                    {
                        $Script:Logging = $false

                        BadMsg "Problem writing log to '$($LogFile)':`r`n$($_)"

                        NoticeMsg "Logging disabled"
                    }
                }
            }


            function TimeStamp
            {
                return (Get-Date).ToString("[yyyy-MM-ddTHH:mm:ss]")
            }


            function GoodMsg
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($GoodMsg)
                {
                    $Message = "$(TimeStamp) $($Msg)"

                    Logger -Msg $Message

                    Write-Host $Message -ForegroundColor Green
                }
            }


            function BadMsg
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($BadMsg)
                {
                    $Message = "$(TimeStamp) $($Msg)"

                    Logger -Msg $Message

                    Write-Host $Message -ForegroundColor red
                }
            }


            function ActionMsg
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($ActionMsg)
                {
                    $Message = "$(TimeStamp) $($Msg)"

                    Logger -Msg $Message

                    Write-Host $Message -ForegroundColor Gray
                }
            }


            function NetMsg
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($NetMsg)
                {
                    $Message = "$(TimeStamp) $($Msg)"

                    Logger -Msg $Message

                    Write-Host $Message -ForegroundColor DarkCyan
                }
            }


            function WebMsg
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($WebMsg)
                {
                    $Message = "$(TimeStamp) $($Msg)"

                    Logger -Msg $Message

                    Write-Host $Message -ForegroundColor Cyan
                }
            }


            function NoticeMsg
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Msg )

                if ($NoticeMsg)
                {
                    $Message = "$(TimeStamp) $($Msg)"

                    Logger -Msg $Message

                    Write-Host $Message -ForegroundColor Yellow
                }
            }


        #endregion <# LOGS & MESSAGES #>


        function StartServer
        {
            if ($Global:WebServer.IsListening)
            {
                NoticeMsg "Web server is already running at: $($WebServerRoot)"

                return
            }

            try
            {
                NoticeMsg "Initializing web server"

                $Global:WebServer = [System.Net.HttpListener]::new()

                $Global:WebServer.Prefixes.Add($WebServerRoot)

                $Global:WebServer.Start()

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                BadMsg "Problem starting web server:`r`n$($_)"

                exit
            }

            if ($Global:WebServer.IsListening)
            {
                GoodMsg "Web server is listening at: $($WebServerRoot)"
            }
            else
            {
                BadMsg "Web server failed to load"

                exit
            }
        }


        function StopServer
        {
            if (!$Global:WebServer.IsListening)
            {
                NoticeMsg "Web server is not running"

                return
            }

            try
            {
                NoticeMsg "Stopping web server"

                $Global:WebServer.Stop()

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                BadMsg "Problem stopping web server:`r`n$($_)"
            }

            if (!$Global:WebServer.IsListening)
            {
                GoodMsg "Web server terminated"
            }
            else
            {
                BadMsg "Web server failed to unload (Try running StopServer manually)"
            }
        }


        function SendResponse
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [byte[]] $Stream )

            try
            {
                NetMsg "Sending response to user"

                $Global:Context.Response.ContentLength64 = $Stream.Length

                $Global:Context.Response.OutputStream.Write($Stream, 0, $Stream.Length)

                $Global:Context.Response.OutputStream.Close()

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                BadMsg "Problem encountered while sending response to user:`r`n$($_)"
            }
        }


        function RedirectUser
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $Location )

            try
            {
                NetMsg "Redirecting user to '$($WebServerAddress)$($Location)'"

                $Global:Context.Response.Redirect($Location)

                $Global:Context.Response.OutputStream.Close()

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                BadMsg "Problem encountered during redirect:`r`n$($_)"
            }
        }


        function SendUserToNextGame
        {
            ActionMsg "Sending user to next game"

            RedirectUser (UserDirection)
        }


    #endregion <# WEB SERVER #>


    #region <# WEB REQUESTS #>


        function InvokeWebRequest
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $URL )

            WebMsg "Invoking web request to retrieve '$($URL)'"

            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            [Microsoft.PowerShell.Commands.WebResponseObject] $WebObject = $null

            [string] $WebError = ""

            try
            {
                $WebObject = Invoke-WebRequest -Uri $URL -UseBasicParsing -SessionVariable SteamWebSession -ErrorAction Stop

                GetWebResult $WebObject

                if($WebObject.content -like "*$($SteamAgeCheckPattern)*")
                {

                    NoticeMsg "This game has an age check"

                    if ($ShowGamesProtectedByAgeCheck)
                    {
                        $WebObject = BypassAgeCheck -WebResponse $WebObject -URL $URL -ErrorAction Stop
                    }
                    else
                    {
                        BadMsg "`$ShowGamesProtectedByAgeCheck set to `$false - no media will be found"
                    }
                }

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                if ($ThisProfile -ne $null)
                {
                    $ThisProfile.WebFailureCount++
                }

                $WebError = "Problem encountered:`r`n$($_)"

                throw "$($WebError)"
            }

            return $WebObject
        }


        function BypassAgeCheck
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [Microsoft.PowerShell.Commands.WebResponseObject] $WebResponse,
                   [Parameter(Position = 1, Mandatory=$true)] [string] $URL)

            <# This is a bit of a mess. $SteamWebSession proved difficult to reuse.  May look at it in the future. #>

            #throw "

            ActionMsg "Getting Header Cookie"

            [string] $SessionID = ($WebResponse.Headers.$SteamSetcookie).split(';')[0]

            if ($SessionID -eq "")
            {
                throw "Session ID could not be found in WebResponse (Time to udpate the script?)"
            }

            ActionMsg "Preparing age check post response for Steam"

            [uint16] $BirthYear = ([uint16] (Get-Date).ToString("yyyy")) - (Get-Random -Minimum 25 -Maximum 75)

            [string] $ReturnData = "$($SessionID)$($SteamAgePostPattern)$($BirthYear)"

            [string] $ReturnURL = $URL.Replace("/app/", "$($SteamAgePostURLReplacement)")

            try
            {
                WebMsg "Posting '$($ReturnData)' to '$($ReturnURL)'"

                [Microsoft.PowerShell.Commands.WebResponseObject] $Response = Invoke-WebRequest $ReturnURL -WebSession $SteamWebSession -Body $ReturnData -Method Post -ErrorAction STOP

                GetWebResult $Response

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                $WebError = "$($_)"

                throw "$($WebError)"
            }

            try
            {
                WebMsg "Invoking web request to re-retrieve '$($URL)'"

                [Microsoft.PowerShell.Commands.WebResponseObject] $NewWebObject = Invoke-WebRequest -Uri $URL -UseBasicParsing -WebSession $SteamWebSession

                GetWebResult $NewWebObject

                #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
            }
            catch
            {
                $WebError = "$($_)"

                throw "$($WebError)"
            }

            return $NewWebObject
        }


        function GetWebResult
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] $WebResponse )

            if($WebResponse.StatusCode -ne 200)
            {
                throw "[Status $($WebResponse.StatusDescription), Code $($WebResponse.StatusCode)]"
            }
            else
            {
                WebMsg "Good Response: [Status $($WebResponse.StatusDescription), Code $($WebResponse.StatusCode)]"
            }
        }


    #endregion <# WEB REQUESTS #>


    #region <# USER INPUT #>


        function ExtractUserData
        {
            [string] $UserData = [System.IO.StreamReader]::new($Global:Context.Request.InputStream).ReadToEnd()

            $UserData = [System.Web.HttpUtility]::UrlDecode($UserData)

            $UserData = $UserData.Replace("$($UserDataVariable)=","").Trim()

            return $UserData
        }


        function ValidateUserData
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $UserData )

            <#      $RegexPattern Explanation ( Regex101 Link: https://regex101.com/r/Hj34VE/1 ):
                    ^                         = The start of the string.
                    (?i)                      = Case insensitive mode to ignore UPPER or lower case.
                    (https?:\/\/)?            = Match "https:\\" or "http:\\" if either is there or not.
                    (www.)?                   = Must be followed by a match of "www." if it's there or not.
                    steamcommunity.com\/      = Must be followed by a match "steamcommunity.com/".
                    (id|profiles)\/           = Must be followed by match of either "id/" or "profiles/".
                    [a-z0-9_-]+               = Must be followed by a match of any combination of a-z, 0-9, underscore _, or dash -, as many times as required.
                    (\/)?                     = Must be followed by a closing slash if it's there or not.
                    $                         = The end of the string (nothing further will be accepted).
            #>
            [string] $RegexPattern = "^(?i)(https?:\/\/)?(www.)?steamcommunity.com\/(id|profiles)\/[a-zA-z0-9_-]+(\/)?$"

            ActionMsg "Validating user data '$($UserData)'"

            return ($UserData -Match $RegexPattern)
        }

        function EliminatePossibleBadData
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $UserData )

            $UserData = ($UserData).Replace("<","&lt;").Replace(">","&gt;") #POSSIBLE TODO: Might need to expand this to capture some things that break the $Home page.

            return $UserData
        }

        function UserDataToValidURL
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $UserData)

            [bool] $Formatted = $false

            if ($UserData.Substring(0,4) -ne "http")
            {
                $UserData = "https://$($UserData)"

                $Formatted = $true
            }

            if ($UserData[$UserData.Length - 1] -eq "/")
            {
                $UserData = $UserData.Substring(0,$UserData.Length - 1)

                $Formatted = $true
            }

            if ($UserData -cmatch '[A-Z]')
            {
                $UserData = $UserData.ToLower();

                $Formatted = $true
            }

            if ($Formatted)
            {
                ActionMsg "User data formatted to proper URL: '$($UserData)'"
            }
            else
            {
                ActionMsg "User data was a proper URL"
            }

            return $UserData
        }


        function UserDirectionChangeCheck
        {
            if ($Global:Context.Request.RawUrl -eq "/$($Forward)")
            {
                if (!$DefaultForward)
                {
                    $Script:DefaultForward = $true

                    NoticeMsg "User sitched direction to '/$($Forward)'"
                }
            }
            elseif ($Global:Context.Request.RawUrl -eq "/$($Backward)")
            {
                if ($DefaultForward)
                {
                    $Script:DefaultForward = $false

                    NoticeMsg "User sitched direction to '/$($Backward)'"
                }
            }
        }


        function UserDirection
        {
            if ($DefaultForward)
            {
                return "/$($Forward)"
            }
            else
            {
                return "/$($Backward)"
            }
        }


    #endregion <# USER INPUT #>


    #region <# DATA PROCESSING #>


        function ProfileRetrieved
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $ProfileURL )

            if ($Global:Profiles.Count -le 0)
            {
                return $false
            }

            foreach ($Profile in $Global:Profiles)
            {
                if ($Profile.URL -eq $ProfileURL)
                {
                    return $true
                }
            }

            return $false
        }


        function PrepareRawGameDataForJSON
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [string] $RawGameData)

            $RawGameData = $RawGameData.Trim()

            #Replace the variable at the start of the string:
            $RawGameData = $RawGameData.Replace("$($SteamGameJSpattern) [","[")

            #replace end of string:
            $RawGameData = $RawGameData.Replace("];","]")

            return $RawGameData
        }


        function ConvertUnixTime
        {
            Param( [Parameter(Position = 0, Mandatory=$true)] [uint64] $Seconds)

            [DateTime] $EpochTimeStart = $UnixEpochTime

            return $EpochTimeStart.AddSeconds($Seconds)
        }


        function ProfileHasGames
        {
            ActionMsg "Checking for games"

            if (($ThisProfile -eq $null) -or
                ($ThisProfile.Games.Count -eq 0))
            {
                [string] $NoGames = "No games to display"

                BadMsg "$($NoGames)"

                [string] $Issue = "$($NoGames):"

                [string] $Detail = "No games to display!"

                [string] $Suggest = "Try getting some games from a Steam Profile first!"

                $Script:PageError = GeneratePageError $Issue $Detail $Suggest -UseCode

                RedirectUser "/$($Home)"

                return $false
            }

            return $true
        }


        function SelectGame
        {
            ActionMsg "Selecting game"

            if ($Global:Context.Request.RawUrl -eq "/$($ViewMore)")
            {
                #Leave Index where it is.
            }
            elseif ($Global:Context.Request.RawUrl -eq "/$($Forward)")
            {
                if (($ThisProfile.Index + 1) -le ($ThisProfile.Games.Count-1))
                {
                    $ThisProfile.Index++
                }
                else
                {
                    $ThisProfile.Index = 0
                }
            }
            elseif ($Global:Context.Request.RawUrl -eq "/$($Backward)")
            {
                if (($ThisProfile.Index - 1) -ge 0)
                {
                    $ThisProfile.Index--
                }
                else
                {
                    $ThisProfile.Index = $ThisProfile.Games.Count - 1
                }
            }

            return $ThisProfile.Games[$ThisProfile.Index]
        }


        function AllVideosViewed
        {
            foreach ($Video in $ThisGame.Videos)
            {
                if ($Video.Viewed -eq $false)
                {
                    return $false
                }
            }

            return $true
        }


        function GetUnseenVideoIndex
        {
            [system.array] $UnseenVideos = @()

            for ([int] $i = 0; $i -lt $ThisGame.Videos.Count; $i++)
            {
                if ($ThisGame.Videos[$i].Viewed -eq $false)
                {
                    $UnseenVideos += , $i
                }
            }

            return ($UnseenVideos | Get-Random)
        }


        function DumpSaveFile
        {
            if ($SaveProfileData -and ($Global:Profiles.Count -gt 0))
            {
                try
                {
                    ActionMsg "Exporting `$Global:Profile data to '$($SaveFile)'"

                    $Global:Profiles | ConvertTo-Json -Depth 100 | out-file $SaveFile

                    #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                }
                catch
                {
                    BadMsg "Problem exporting data:`r`n$($_)"

                    $Script:DumpProfilesToSaveFile = $false
                }
            }
            elseif ($SaveProfileData)
            {
                BadMsg "`$SaveProfileData was set to true, but no profile data was gathered in this run"

                $Script:DumpProfilesToSaveFile = $false
            }
        }


        function FlushVariables
        {
            ActionMsg "Flushing variables"

            $Script:ThisProfile = $null

            $Script:Profiles = $null

            $Script:HTML = $null

            $Global:WebServer  = $null
        }


    #endregion <# DATA PROCESSING #>


    #region <# HTML PAGE GENERATION #>


            function GeneratePage
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $PageHead,
                       [Parameter(Position = 1, Mandatory=$true)] [string] $PageBody)

                [string] $HTML = "<!DOCTYPE html>

                                    <html lang='en'>
                                        $($PageHead)
                                        $($PageBody)
                                    </html>"

                return $HTML
            }


            function GenerateHead
            {
                Param( [Parameter(Position = 0, Mandatory=$true)] [string] $PageTitle,
                       [Parameter(Position = 1, Mandatory=$true)] [string] $PageStyle)

                [string] $HEAD = "
                                        <head>

                                            <meta charset='utf-8'>

                                            <title>$($PageTitle)</title>

                                            <link rel='icon' href='$($SteamFavIcon)'>

                                            <meta name='viewport' content='width=device-width, initial-scale=1, user-scalable=no'>

                                            <link rel='stylesheet' href='https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css'>

                                            <script src='https://code.jquery.com/jquery-3.5.1.js'></script>

                                            <script src='https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.bundle.min.js'></script>

                                            <script src='https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js'></script>

                                            $($PageStyle)

                                        </head>
                                "

                return $HEAD
            }


            function GenerateStyle
            {
                Param( [Parameter(Mandatory=$false)] [switch] $HomePage,
                       [Parameter(Mandatory=$false)] [switch] $HomeHasProfile,
                       [Parameter(Mandatory=$false)] [switch] $ImagePage,
                       [Parameter(Mandatory=$false)] [switch] $VideoPage,
                       [Parameter(Mandatory=$false)] [switch] $QuitPage)

                [string] $STYLE = "
                                            <style>

                                                //div { outline: 1px solid red !important; }

                                                html, body
                                                {
                                                    height:               100%;

                                                    width:                100%;
                                                }

                                                body
                                                {
                                                    background-color:     #000000;

                                                    transition:           $($PageFadeTime)ms opacity ;

                                                    font-family:          arial, helvetica, sans-serif;
                                                }
                "

                if ($HomePage -or $QuitPage)
                {
                    $STYLE += "
                                                body
                                                {
                                                    opacity:              0;
                                                }

                                                a
                                                {
                                                    color:                #000000;
                                                }

                                                a:hover
                                                {
                                                    color:                $($TitleTextColor);
                                                }

                                                #background
                                                {
                                                    background-image:     linear-gradient($($PageTopGradient), $($PageBottomGradient));

                                                    position:             fixed;

                                                    height:               100%;

                                                    width:                100%;

                                                    z-index:              -10;
                                                }

                                                #padding-row
                                                {
                                                    padding:              5%;
                                                }

                                                .jumbotron
                                                {
                                                    background-image:     linear-gradient($($TitleTopGradient), $($TitleBottomGradient));

                                                    color:                $($TitleTextColor);

                                                    text-shadow:          0px 0px 7px #000000;

                                                    border-radius:        1rem;
                                                }

                                                .alert
                                                {
                                                    word-break:           break-all;
                                                }
                    "
                }

                if ($HomePage)
                {
                    $STYLE += "
                                                #quit
                                                {
                                                    top:                  4%;

                                                    right:                4%;

                                                    opacity:              0.1;

                                                    transition:           0.5s opacity;

                                                    visibility:           visible;

                                                    position:             fixed;

                                                    z-index:              10;

                                                    max-height:           7%;

                                                    min-height:           4%;

                                                    width:                auto;
                                                }

                                                #quit:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                .pageError
                                                {
                                                    padding-right:        50%;

                                                    padding-left:         50%;
                                                }
                        "

                    if ($HomeHasProfile)
                    {
                        $STYLE += "
                                                #avatar
                                                {
                                                    top:                  5%;

                                                    left:                 3%;

                                                    border:               2px solid black;

                                                    opacity:              $($DefaultLogoTransparency);

                                                    transition:           0.5s opacity;

                                                    visibility:           visible;

                                                    position:             fixed;

                                                    z-index:              9;

                                                    max-height:           15%;

                                                    min-height:           5%;

                                                    width:                auto;
                                                }

                                                #forward, #backward
                                                {
                                                    opacity:              0.1;

                                                    transition:           0.5s opacity;

                                                    visibility:           visible;

                                                    position:             fixed;

                                                    z-index:              10;

                                                    top:                  50%;

                                                    transform:            translate(0%, -50%);

                                                    max-height:           20%;

                                                    min-height:           10%;

                                                    max-width:            5%;

                                                    min-width:            3%;
                                                }

                                                #forward
                                                {
                                                    right:                3%;
                                                }

                                                #backward
                                                {
                                                    left:                 3%;
                                                }

                                                #forward:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #backward:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #avatar:hover
                                                {
                                                    filter:               brightness(120%);
                                                }
                            "
                    }

                    $STYLE += "
                                                .input-group
                                                {
                                                    width:                100%;

                                                    padding-left:         5%;

                                                    padding-right:        5%;
                                                }

                                                .form-control
                                                {
                                                    padding-right:        20px;

                                                    padding-left:         20px;
                                                }
                    "
                }

                if ($ImagePage)
                {
                    $STYLE += "
                                                body
                                                {
                                                    opacity:              0;
                                                }

                                                img#imageContainer
                                                {
                                                    visibility:           visible;

                                                    z-index:              -1;

                                                    opacity:              0;

                                                    transition:           3s opacity;
                                                }

                                                body, img#imageContainer
                                                {
                                                    left:                 50%;

                                                    top:                  50%;

                                                    position:             absolute;

                                                    transform:            translate(-50%, -50%);

                                                    overflow:             hidden;

                                                    min-width:            100%;

                                                    max-width:            100%;

                                                    min-height:           100%;

                                                    max-height:           100%;

                                                    object-fit:           fill;
                                                }
                                        "
                }

                if ($VideoPage)
                {
                    $STYLE += "
                                                video#videoContainer
                                                {
                                                    visibility:           hidden;

                                                    z-index:              -1;

                                                    volume:               1;
                                                }

                                                body, video#videoContainer
                                                {
                                                    left:                 50%;

                                                    top:                  50%;

                                                    position:             absolute;

                                                    transform:            translate(-50%, -50%);

                                                    overflow:             hidden;

                                                    min-width:            100%;

                                                    max-width:            100%;

                                                    min-height:           100%;

                                                    max-height:           100%;

                                                    object-fit:           fill;
                                                }
                                        "
                }

                if ($VideoPage -or $ImagePage)
                {
                    $STYLE += "
                                                #gameLogo
                                                {
                                                    top:                  5%;

                                                    left:                 3%;

                                                    border:               2px solid black;

                                                    opacity:              0;

                                                    transition:           $($InitialLogoFadeInTime)ms opacity;

                                                    visibility:           visible;

                                                    position:             fixed;

                                                    z-index:              9;

                                                    max-height:           15%;

                                                    min-height:           5%;

                                                    width:                auto;
                                                }

                                                #forward, #backward, #playNow, #viewMore, #home, #quit
                                                {
                                                    opacity:              0;

                                                    transition:           0.5s opacity;

                                                    visibility:           visible;

                                                    position:             fixed;

                                                    z-index:              10;
                                                }

                                                #forward, #backward
                                                {
                                                    top:                  50%;

                                                    transform:            translate(0%, -50%);

                                                    max-height:           20%;

                                                    min-height:           10%;

                                                    max-width:            5%;

                                                    min-width:            3%;
                                                }

                                                #playNow, #viewMore
                                                {
                                                    left:                 50%;

                                                    right:                50%;

                                                    transform:            translate(-50%, -50%);

                                                    max-height:           10%;

                                                    min-height:           4%;

                                                    width:                auto;
                                                }

                                                #home, #quit
                                                {
                                                    top:                  4%;

                                                    max-height:           7%;

                                                    min-height:           4%;

                                                    width:                auto;
                                                }

                                                #forward
                                                {
                                                    right:                3%;
                                                }

                                                #backward
                                                {
                                                    left:                 3%;
                                                }

                                                #playNow
                                                {
                                                    top:                  10%;
                                                }

                                                #viewMore
                                                {
                                                    bottom:               5%;
                                                }

                                                #home
                                                {
                                                    right:                14%;
                                                }

                                                #quit
                                                {
                                                    right:                4%;
                                                }

                                                #forward:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #viewMore:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #backward:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #playNow:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #gameLogo:hover
                                                {
                                                    filter:               brightness(120%);
                                                }

                                                #quit:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                                                #home:hover
                                                {
                                                    filter:               brightness(200%);
                                                }

                        "
                }

                $STYLE += "
                                            </style>
                "

                return $STYLE
            }


            function GenerateBody
            {
                Param( [Parameter(Mandatory=$false)] [AllowEmptyString()] [string] $PageName,
                       [Parameter(Mandatory=$false)] [switch] $HomePage,
                       [Parameter(Mandatory=$false)] [switch] $HomeHasProfile,
                       [Parameter(Mandatory=$false)] [switch] $ImagePage,
                       [Parameter(Mandatory=$false)] [switch] $VideoPage,
                       [Parameter(Mandatory=$false)] [switch] $QuitPage)

                [string] $BODY = ""

                if ($HomePage)
                {
                    $BODY += "
                                        <body onmousemove='mouseIsMoving()'>

                                            <div id='background'></div>
                                "

                    if ($HomeHasProfile)
                    {
                        $BODY += "
                                            <img id='avatar' onclick=`"window.open('$($ThisProfile.URL)','_blank');`" src='$($ThisProfile.Avatar)'>

                                            <img id='forward' onclick='goSomewhere(`"$($WebServerAddress)/$($Forward)`");' src='$($ForwardImage)'>

                                            <img id='backward' onclick='goSomewhere(`"$($WebServerAddress)/$($Backward)`");' src='$($BackwardImage)'>
                        "
                    }

                    $BODY += "
                                            <img id='quit' onclick='goSomewhere(`"$($WebServerAddress)/$($Quit)`");' src='$($QuitImage)'>

                                            <div class='container'>

                                                <div id='padding-row' class='row'></div>

                                                <div class='row justify-content-md-center'>

                                                    <div class='col-md-1'></div>

                                                    <div class='col-md-8 jumbotron text-center'>
                                                        <h1>$($ScriptName)</h1>
                                                        <h3>$($PageName)</h3>
                                                    </div>

                                                    <div class='col-md-1'></div>

                                                </div>

                                                <div class='row justify-content-md-center'>

                                                    <div class='col-md-1'></div>

                                                    <div class='col-md-10 justify-content-md-center'>

                                                        <form id='profileSearch' action='/$($ValidateProfile)' method='post' class='text-center'>
                                                            <div class='form-group'>
                                                                <div class='input-group justify-content-md-center'>
                                                                    <input id='profileSearchBox' type='text' class='form-control' maxlength='128' name='$($UserDataVariable)' placeholder='Enter A$(if($HomeHasProfile){"nother"}) Steam Profile Address$(if($HomeHasProfile){"!"}else{" Here!"})'>
                                                                    <div class='input-group-append'>
                                                                        <button id='profileSearchButton' class='btn btn-primary'>🔍</button>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        </form>

                                                    </div>

                                                    <div class='col-md-1'></div>

                                                </div>

                                                <div class='row justify-content-md-center'>
                                                    <div class='col-md-3'></div>

                                                    <div class='col-md-6'>$($PageError)</div>

                                                    <div class='col-md-3'></div>

                                                </div>

                                                <div id='padding-row' class='row' ></div>
                                            </div>
                    "

                    if ($HomeHasProfile)
                    {
                        $BODY += "
                                            $(GenerateJavascript -HomePage -HomeHasProfile)
                        "
                    }
                    else
                    {
                        $BODY += "
                                            $(GenerateJavascript -HomePage)
                        "
                    }


                }

                if ($ImagePage -or $VideoPage)
                {
                    $BODY += "
                                        <body onmousemove='mouseIsMoving()'>

                                            <img id='gameLogo' onclick=`"window.open('$($ThisGame.Store)','_blank');`" src='$($ThisGame.Logo)' />

                                            <img id='playNow' onclick=`"GameWindow = window.open('$($ThisGame.Play)','_blank'); GameWindow.close();`" src='$($PlayImage)' />

                                            <img id='backward' onclick='goSomewhere(`"$($WebServerAddress)/$($Backward)`");' src='$($BackwardImage)' />

                                            <img id='viewMore' onclick='goSomewhere(`"$($WebServerAddress)/$($ViewMore)`");' src='$($ViewMoreImage)' />

                                            <img id='forward' onclick='goSomewhere(`"$($WebServerAddress)/$($Forward)`");' src='$($ForwardImage)' />

                                            <img id='home' onclick='goSomewhere(`"$($WebServerAddress)/$($Home)`");' src='$($HomeImage)' />

                                            <img id='quit' onclick='goSomewhere(`"$($WebServerAddress)/$($Quit)`");' src='$($QuitImage)' />
                    "
                }

                if  ($ImagePage)
                {
                    [int] $ImageCounter = 1

                    [system.array] $RandomizedImages = $ThisGame.Images.All | Sort-Object | Get-Random -Count ([int]::MaxValue)

                    foreach ($Image in $RandomizedImages)
                    {
                        $BODY += "
                                            <img id='imageContainer' name='Image$(($ImageCounter).ToString("0000"))' src='$Image'>
                        "
                        $ImageCounter++
                    }

                    $BODY += "
                                            $(GenerateJavascript -ImagePage)
                        "
                }

                if ($VideoPage)
                {
                    $BODY += "
                                            <video id ='videoContainer' autoplay $(if($ShowVideoControls){'controls'}) disablePictureInPicture = 'true' >

                                                <source src='$($VideoChoice.HDMP4)' type='video/mp4'>

                                                <source src='$($VideoChoice.HDWebM)' type='video/webm'>

                                                <source src='$($VideoChoice.SDMP4)' type='video/mp4'>

                                                <source src='$($VideoChoice.SDWebM)' type='video/webm'>

                                                video not supported

                                            </video>

                                            $(GenerateJavascript -VideoPage)
                    "
                }

                if ($QuitPage)
                {
                    $BODY += "
                                        <body>

                                            <div id='background'></div>

                                            <div class='container full-height'>

                                                <div id='padding-row' class='row'></div>

                                                <div class='row justify-content-md-center'>

                                                    <div class='col-md-1'></div>

                                                    <div class='col-md-8 jumbotron text-center'>

                                                            <h1>$($ScriptName) $($PageName)</h1>
                                                            <h4>Enjoy your rediscovered library!</h4>
                                                            <h4>-TkA 😃</h4>
                                                            <small><a href='https://www.github.com/xTkAx/'>https://www.github.com/xTkAx/</a></small>

                                                    </div>

                                                    <div class='col-md-1'></div>

                                                </div>

                                                <div class='row' id='padding-row'> </div>

                                            </div>

                                            $(GenerateJavascript -QuitPage)
                    "
                }

                $BODY += "
                                        </body>
                    "

                return $BODY
            }


            function GenerateJavascript
            {
                Param( [Parameter(Mandatory=$false)] [switch] $HomePage,
                       [Parameter(Mandatory=$false)] [switch] $HomeHasProfile,
                       [Parameter(Mandatory=$false)] [switch] $ImagePage,
                       [Parameter(Mandatory=$false)] [switch] $VideoPage,
                       [Parameter(Mandatory=$false)] [switch] $QuitPage)

                [string] $JAVASCRIPT = "
                                        <script type='text/javascript' defer>

                                            //debugger; console.log('Javascript has started.');

                                                /* Script Variables */"

                if ($HomePage)
                {
                    if ($HomeHasProfile)
                    {
                        $JAVASCRIPT += "
                                            var avatar = document.getElementById('avatar');

                                            var forward = document.getElementById('forward');

                                            var backward = document.getElementById('backward');
                        "
                    }

                    $JAVASCRIPT += "
                                            var quit = document.getElementById('quit');

                                            var profileSearch = document.getElementById('profileSearch');

                                            var profileSearchBox = document.getElementById('profileSearchBox');

                                            var profileSearchButton = document.getElementById('profileSearchButton');


                                                /* On document load event */
                                            document.addEventListener('DOMContentLoaded',
                                                function()
                                                {
                                                    //debugger; console.log('In DOMContentLoaded event.');

                                                    document.body.style.opacity = 1;

                                                    profileSearchBox.focus();
                                                });


                                                /* Event listener for submitting the form: */
                                            profileSearch.addEventListener('submit',
                                                function(event)
                                                {
                                                    //debugger; console.log('In submit form event.');

                                                    event.preventDefault();

                                                    goingSomewhere();

                                                    setTimeout(
                                                        function()
                                                        {
                                                            profileSearchButton.disabled = false;

                                                            profileSearchBox.disabled = false;

                                                            profileSearch.submit();
                                                        },
                                                        $($PageFadeTime));
                                                });


                                                /* Handle when a button is clicked to go somewhere */
                                            function goSomewhere(destination)
                                            {
                                                //debugger; console.log('In goSomewhere() function.');

                                                goingSomewhere();

                                                setTimeout(
                                                    function()
                                                    {
                                                        window.location.href = destination;
                                                    },
                                                    $($PageFadeTime));
                                            }


                                                /* Things to do before going somewhere */
                                            function goingSomewhere()
                                            {
                                                //debugger; console.log('In goingSomewhere() function.');

                                                disableClickables();

                                                document.body.style.opacity = 0;
                                            }


                                                /* Disable all clickable things on this page */
                                            function disableClickables()
                                            {
                                                //debugger; console.log('In disableClickables() function.');

                                                quit.onclick = '';
                    "

                    if ($HomeHasProfile)
                    {
                        $JAVASCRIPT += "
                                                avatar.disabled = true;

                                                forward.disabled = true;

                                                backward.disabled = true;
                        "
                    }

                    $JAVASCRIPT += "
                                                profileSearchButton.disabled = true;

                                                profileSearchBox.disabled = true;
                                            }


                                                /* Handle what happens when the mouse moves */
                                            function mouseIsMoving()
                                            {
                                                //debugger; console.log('In mouseIsMoving() function.');

                                                clearTimeout(window['TimerClear']);

                                                quit.style.opacity = 0.7;
                    "

                    if ($HomeHasProfile)
                    {
                        $JAVASCRIPT += "
                                                avatar.style.opacity = 1;

                                                forward.style.opacity = 0.7;

                                                backward.style.opacity = 0.7;
                        "
                    }

                    $JAVASCRIPT += "
                                                window['TimerClear'] = setTimeout(
                                                    function()
                                                    {
                                                        quit.style.opacity = 0.1;"

                    if ($HomeHasProfile)
                    {
                        $JAVASCRIPT += "
                                                        avatar.style.opacity = $($DefaultLogoTransparency);

                                                        forward.style.opacity = 0.1;

                                                        backward.style.opacity = 0.1;"
                    }

                    $JAVASCRIPT += "
                                                            },
                                                            $($OnScreenControlFadeTime));
                                                    }
                                "
                }

                if ($VideoPage)
                {
                    $JAVASCRIPT += "
                                            var videoContainer = document.getElementById('videoContainer');

                                            var fadeVolumeInterval;

                    "
                }

                if ($ImagePage)
                {
                    $JAVASCRIPT +="
                                            var allImages = document.querySelectorAll('[name^=Image]');

                                            var imageIndex = 0;

                    "
                }

                if ($VideoPage -or $ImagePage)
                {
                    $JAVASCRIPT +="
                                                /* Page Control Images */
                                            var gameLogo = document.getElementById('gameLogo');

                                            var playNow = document.getElementById('playNow');

                                            var backward = document.getElementById('backward');

                                            var viewMore = document.getElementById('viewMore');

                                            var forward = document.getElementById('forward');

                                            var home = document.getElementById('home');

                                            var quit = document.getElementById('quit');

                    "
                }

                if ($ImagePage)
                {
                    $JAVASCRIPT +="
                                                /* Handle when image page is loaded */
                                            document.addEventListener('DOMContentLoaded',
                                                function()
                                                {
                                                    //debugger; console.log('In DOMContentLoaded function.');

                                                    document.body.style.opacity = 1;

                                                    gameLogo.style.opacity = $($DefaultLogoTransparency);

                                                    setTimeout(
                                                        function()
                                                        {
                                                            gameLogo.style.transitionDuration = '0.5s';
                                                        },
                                                        $($InitialLogoFadeInTime));

                                                    runSlideShow();
                                                },
                                                false);


                                                /* Handle the image slide show */
                                            function runSlideShow()
                                            {
                                                if (imageIndex <= allImages.length - 1)
                                                {
                                                    allImages[imageIndex].style.opacity = 1;

                                                    setTimeout(
                                                        function()
                                                        {
                                                            imageIndex++;

                                                            runSlideShow();
                                                        },
                                                        $($ImageStillDisplayTime));
                                                }
                                                else
                                                {
                                                    goingSomewhere();

                                                    setTimeout(
                                                        function()
                                                        {
                                                            window.location.href = '$($WebServerAddress)$(UserDirection)';
                                                        },
                                                        $($PageFadeTime));
                                                }
                                            }


                                                /* Handle when a button is clicked to go somewhere */
                                            function goSomewhere(destination)
                                            {
                                                //debugger; console.log('In goSomewhere() function.');

                                                goingSomewhere();

                                                setTimeout(function()
                                                   {
                                                        window.location.href = destination;

                                                   }, $($PageFadeTime));
                                            }
                                    "
                }

                if ($VideoPage)
                {
                    [int] $VolumeFadeTime = (($PageFadeTime) / 1000)

                    $JAVASCRIPT += "
                                                /* Page Video Event Listeners: */
                                            videoContainer.addEventListener('loadeddata',onVideoLoad,false);

                                            videoContainer.addEventListener('ended',onVideoEnd,false);

                                            videoContainer.addEventListener('playing',onVideoPlay,false);

                                            //videoContainer.addEventListener('stalled',onVideoStalled,false); /* TODO?  in short, handle if a video has a network issue. */


                                                /* Volume fader interval trigger: */
                                            function fadeVolumeTrigger()
                                            {
                                                //debugger; console.log('In fadeVolumeTrigger() function.');

                                                if ($($VolumeFadeTime) != 0)
                                                {
                                                    fadeVolumeInterval = setInterval(fadeVolume, $($VolumeFadeTime));
                                                }
                                                else
                                                {
                                                    videoContainer.volume = 0;
                                                }
                                            }

                                                /* Fade the volume */
                                            function fadeVolume()
                                            {
                                                //debugger; console.log('In fadeVolume() function.');

                                                var volume = Math.round((videoContainer.volume + Number.EPSILON) * 100) / 100;

                                                if (volume > 0.0)
                                                {
                                                    videoContainer.volume = volume - 0.01;
                                                }
                                                else
                                                {
                                                    clearInterval(fadeVolumeInterval);
                                                }
                                            }


                                                /* Handle on video load event */
                                            function onVideoLoad()
                                            {
                                                //debugger; console.log('In onVideoLoad() function.');

                                                videoContainer.volume = 1;

                                                videoContainer.style.visibility = 'visible';
                                            }


                                                /* Handle on video play event */
                                            function onVideoPlay()
                                            {
                                                //debugger; console.log('In onVideoPlay() function.');

                                                gameLogo.style.opacity = $($DefaultLogoTransparency);

                                                setTimeout(
                                                    function()
                                                    {
                                                        gameLogo.style.transitionDuration = '0.5s';
                                                    },
                                                    $($InitialLogoFadeInTime));
                                            }


                                                /* Handle on video end event */
                                            function onVideoEnd()
                                            {
                                                //debugger; console.log('In onVideoEnd() function.');

                                                videoContainer.controls = false;

                                                goingSomewhere();

                                                if ($($PageFadeTime) != 0)
                                                {
                                                    setTimeout(
                                                        function()
                                                        {
                                                            window.location.href = '$($WebServerAddress)$(UserDirection)';
                                                        },
                                                        $($PageFadeTime));
                                                }
                                                else
                                                {
                                                    window.location.href = '$($WebServerAddress)$(UserDirection)';
                                                }
                                            }


                                                /* Handle when a button is clicked to go somewhere */
                                            function goSomewhere(destination)
                                            {
                                                //debugger; console.log('In goSomewhere() function.');

                                                videoContainer.controls = false;

                                                fadeVolumeTrigger();

                                                goingSomewhere();

                                                if ($($PageFadeTime) != 0)
                                                {
                                                    setTimeout(
                                                        function()
                                                        {
                                                            window.location.href = destination;
                                                        },
                                                        $($PageFadeTime));
                                                }
                                                else
                                                {
                                                    window.location.href = '$($WebServerAddress)$(UserDirection)';
                                                }
                                            }
                                "
                }

                if ($ImagePage -or $VideoPage)
                {
                    $JAVASCRIPT += "
                                                /* Things to do before going somewhere */
                                            function goingSomewhere()
                                            {
                                                //debugger; console.log('In goingSomewhere() function.');

                                                disableClickables();

                                                document.body.style.opacity = 0;
                                            }


                                                /* Disable all clickable things on this page */
                                            function disableClickables()
                                            {
                                                //debugger; console.log('In disableClickables() function.');

                                                gameLogo.onclick = '';

                                                playNow.onclick = '';

                                                backward.onclick = '';

                                                viewMore.onclick = '';

                                                forward.onclick = '';

                                                home.onclick = '';

                                                quit.onclick = '';
                                            }


                                                /* Handle what happens when the mouse moves */
                                            function mouseIsMoving()
                                            {
                                                //debugger; console.log('In mouseIsMoving() function.');

                                                clearTimeout(window['timerClear']);

                                                gameLogo.style.opacity = 1.0;

                                                playNow.style.opacity = 0.7;

                                                backward.style.opacity = 0.7;

                                                viewMore.style.opacity = 0.7;

                                                forward.style.opacity = 0.7;

                                                home.style.opacity = 0.7;

                                                quit.style.opacity = 0.7;

                                                window['timerClear'] = setTimeout(
                                                    function()
                                                    {
                                                        gameLogo.style.opacity = $($DefaultLogoTransparency);

                                                        playNow.style.opacity = 0.0;

                                                        backward.style.opacity = 0.0;

                                                        viewMore.style.opacity = 0.0;

                                                        forward.style.opacity = 0.0;

                                                        home.style.opacity = 0.0;

                                                        quit.style.opacity = 0.0;
                                                    },
                                                    $($OnScreenControlFadeTime));
                                            }
                                "
                }

                if ($QuitPage)
                {
                    $JAVASCRIPT += "
                                                /* On document load */
                                            document.addEventListener('DOMContentLoaded',
                                                function()
                                                {
                                                    //debugger; console.log('In DOMContentLoaded function.');

                                                    document.body.style.opacity = 1;
                                                });
                                "
                }

                $JAVASCRIPT += "
                                        </script>
                            "

                return $JAVASCRIPT
            }


            function GeneratePageError
            {
                Param(  [Parameter(Position = 0, Mandatory=$true)] [string] $Issue,
                        [Parameter(Position = 1, Mandatory=$true)] [string] $Detail,
                        [Parameter(Position = 2, Mandatory=$true)] [string] $Suggest,
                        [Parameter(Position = 3, Mandatory=$false)] [switch] $UseCode )

                return "
                                            <div class='p-2 alert alert-danger' role='alert'>

                                                <strong>$($Issue)</strong><br/>

                                                <small class='form-text text-muted'>

                                                    $(if ($UseCode) {"<code>$($Detail)</code>"}
                                                    else {$Detail})<br />

                                                    <strong>$($Suggest)</strong>

                                                </small>

                                            </div>
                        "
            }


    #endregion <# HTML PAGE GENERATION #>


#endregion <# FUNCTIONS #>


#region <# MAIN SCRIPT #>


GoodMsg "$($ScriptName) has begun"

if($Logging)
{
    NoticeMsg "Logging to '$($LogFile)'"
}

if ($RunScript)
{
    StartServer

    ActionMsg "Attempting to open user web browser"

    Invoke-Expression “cmd.exe /C start $($WebServerRoot)”

    NoticeMsg "If nothing is happening, visit $($WebServerRoot) using a web browser on this computer"

    [string] $PageError = ""

    while ($RunScript)
    {
        [System.Net.HttPListenerContext] $Global:Context = $Global:WebServer.GetContext()

        #region <# ROOT/$HOME ROUTE - GET [ http://localhost/, http://localhost/$($Home) ] #>

            if ($Global:Context.Request.HttpMethod -eq "GET" -and
                ($Global:Context.Request.RawUrl -eq "/" -or
                 $Global:Context.Request.RawUrl -eq "/$($Home)" ))
            {
                NetMsg "User: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"

                ActionMsg "Building $($Global:Context.Request.Url) for user"

                [string] $PageName = "Rediscover your Steam Library!"

                [string] $PageTitle = "$($ScriptName) - $($PageName)"

                [string] $HTML = ""

                if ($ThisProfile -ne $null)
                {
                    [string] $Style = GenerateStyle -HomePage -HomeHasProfile

                    [string] $Body = GenerateBody -PageName $PageName -HomePage -HomeHasProfile
                }
                else
                {
                    [string] $Style = GenerateStyle -HomePage

                    [string] $Body = GenerateBody -PageName $PageName -HomePage
                }

                [string] $Head = GenerateHead $PageTitle $Style

                $HTML = GeneratePage $Head $Body

                $PageError = ""

                [byte[]] $Stream = [System.Text.Encoding]::UTF8.GetBytes($HTML)

                SendResponse -Stream $Stream
            }

        #endregion <# ROOT/$HOME ROUTE - GET [ http://localhost/, http://localhost/$($Home) ] #>


        #region <# $QUIT ROUTE - GET [ http://localhost/$($Quit) ] #>


            elseif ($Global:Context.Request.HttpMethod -eq "GET" -and
                    $Global:Context.Request.RawUrl -eq "/$($Quit)")
            {

                NetMsg "User: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"

                ActionMsg "Building $($Global:Context.Request.Url) for user"

                [string] $PageName = "Ended!"

                [string] $PageTitle = "$($ScriptName) $($PageName)"

                [string] $HTML = ""

                [string] $Style = GenerateStyle -QuitPage

                [string] $Head = GenerateHead $PageTitle $Style

                [string] $Body = GenerateBody $PageName -QuitPage

                $HTML = GeneratePage $Head $Body

                ActionMsg "Toggling `$RunScript flag"

                $RunScript = !$RunScript

                [byte[]] $Stream = [System.Text.Encoding]::UTF8.GetBytes($HTML)

                SendResponse -Stream $Stream
            }


        #endregion <# $QUIT ROUTE - GET [ http://localhost/$($Quit) ] #>


        #region <# $VALIDATEPROFILE ROUTE - POST [ http://localhost/$(ValidateProfile) ] #>


            elseif ($Global:Context.Request.HttpMethod -eq "POST" -and
                    $Global:Context.Request.RawUrl -eq "/$($ValidateProfile)")
            {
                NetMsg "User: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"


                ActionMsg "Analyzing user data"

                [string] $UserData =  ExtractUserData

                if (($UserData -eq "") -or
                    !(ValidateUserData $UserData))
                {
                    $UserData = EliminatePossibleBadData $UserData

                    [string] $InvalidURL = "'$($UserData)' is not a valid address"

                    BadMsg "$($InvalidURL)"

                    [string] $Issue = "$($InvalidURL)!"

                    [string] $Detail = "<strong>Examples:</strong><br >
                                        https://www.steamcommunity.com/id/CustomProfileName/<br />
                                        http://steamcommunity.com/profiles/a1phanumericID007<br />"

                    [string] $Suggest = "Try using a valid address!"

                    $PageError = GeneratePageError $Issue $Detail $Suggest

                    RedirectUser "/$($Home)"

                    continue
                }

                [string] $ValidProfileURL = UserDataToValidURL $UserData

                if (ProfileRetrieved $ValidProfileURL)
                {
                    NoticeMsg "Using previously retrieved profile for '$($ValidProfileURL)'"

                    [Profile] $ThisProfile = $Global:Profiles | Where-Object -Property URL -eq $ValidProfileURL
                }
                else
                {
                    [Microsoft.PowerShell.Commands.WebResponseObject] $ProfileWebObject = $null

                    try
                    {
                        $ProfileWebObject = InvokeWebRequest -URL "$($ValidProfileURL)$($SteamProfileGamesSuffix)"

                        #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                    }
                    catch
                    {
                        [string] $WebError = "Error Invoking Web Request"

                        BadMsg "$($WebError): `r`n$($_)"

                        [string] $Issue = "$($WebError):"

                        [string] $Detail = "$($_)"

                        [string] $Suggest = "Try Again Later!"

                        $PageError = GeneratePageError $Issue $Detail $Suggest -UseCode

                        RedirectUser "/$($Home)"

                        continue
                    }


                    ActionMsg "Parsing profile page"

                    [System.MarshalByRefObject] $ProfilePage = New-Object -Com "HTMLFile"

                    $ProfilePage.Write([System.Text.Encoding]::Unicode.GetBytes($ProfileWebObject))


                    ActionMsg "Gathering raw game data"

                    [string] $RawGameData = ""

                    foreach ($Script in $ProfilePage.scripts)
                    {
                        if (($Script.text -ne $null) -and
                            ($Script.text -like "*$($SteamGameJSpattern)*"))
                        {
                            $RawGameData = $($Script.text.ToString()) -Split "`r`n" | Where-Object { $_.Trim() -Like "$($SteamGameJSpattern) *"}

                            break
                        }
                    }

                    if ($RawGameData.Length -le $($SteamGameJSpattern).Length)
                    {
                        [string] $ProfileStatus = ""

                        if ($ProfileWebObject.ToString() -like $($SteamPrivateProfilePattern))
                        {
                            $ProfileStatus += "The profile is private"
                        }
                        else
                        {
                            $ProfileStatus += "The profile was not found"
                        }

                        BadMsg "$($ProfileStatus)"

                        [string] $Issue = "$($ProfileStatus)"

                        [string] $Detail = "See for yourself: <a href='$($ValidProfileURL)$($SteamProfileGamesSuffix)' target='_blank'>$($ValidProfileURL)$($SteamProfileGamesSuffix)</a><br/>"

                        [string] $Suggest = "Try a valid profile? Set your profile temporarily public? Try a another profile?"

                        $PageError = GeneratePageError $Issue $Detail $Suggest

                        RedirectUser "/$($Home)"

                        continue
                    }


                    ActionMsg "Cleaning raw game data for JSON conversion"

                    $RawGameData = PrepareRawGameDataForJSON $RawGameData

                    [System.Array] $JSONGameData = $null


                    ActionMsg "Generating JSON game data"
                    try
                    {
                        $JSONGameData = $RawGameData | ConvertFrom-JSON -ErrorAction Stop

                        #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                    }
                    catch
                    {
                        [string] $JSONProblem = "There was a problem generating JSON from the raw game data"

                        [string] $JSONError = "$($_)"

                        BadMsg "$($JSONProblem):`r`n$($JSONError)"

                        [string] $Issue = "$($JSONProblem):"

                        [string] $Detail = "$($JSONError)"

                        [string] $Suggest = "This might mean Steam changes broke the script 🤬!"

                        $PageError = GeneratePageError $Issue $Detail $Suggest

                        RedirectUser "/$($Home)"

                        continue
                    }


                    if ($JSONGameData.Count -eq 0)
                    {
                        [string] $UserStatus = "The profile game library is not public, or has no games"

                        BadMsg "$($UserStatus)"

                        [string] $Issue = "$($UserStatus)"

                        [string] $Detail = "See for yourself: <a href='$($ValidProfileURL)$($SteamProfileGamesSuffix)' target='_blank'>$($ValidProfileURL)$($SteamProfileGamesSuffix)</a><br/>"

                        [string] $Suggest = "Try a different profile? Make your library public?"

                        $PageError = GeneratePageError $Issue $Detail $Suggest

                        RedirectUser "/$($Home)"

                        continue
                    }


                    ActionMsg "Creating new profile object"

                    [Profile] $ThisProfile = new-Object Profile

                    $ThisProfile.URL = $ValidProfileURL


                    ActionMsg "Gathering profile avatar"

                    try
                    {
                        $ThisProfile.Avatar = $($($ProfilePage.getElementsByClassName($SteamProfileAvatarClassName)).getElementsByTagName('img')).getattribute('href') | where-object {$_.tostring() -like "*$($SteamPofileAvatarImagePattern)*"}

                        #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                    }
                    catch
                    {
                        BadMsg "Could not get avatar"
                    }


                    ActionMsg "Gathering profile name"

                    try
                    {
                        $ThisProfile.Name = $($ProfilePage.GetElementsByClassName($SteamPofileNameClassName)).innerHTML #POSSIBLE TODO: make it convert emoji's (UTF-32?) if you want to use!

                        #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                    }
                    catch
                    {
                        BadMsg "Could not getname"
                    }


                    ActionMsg "Injecting randomized JSON game data into profile object"

                    $JSONGameData = $JSONGameData | Sort-Object | Get-Random -Count ([int]::MaxValue)

                    foreach ($JSONGame in $JSONGameData)
                    {
                        <# ENHANCEMENT OPPORTUNITY: Add conditions to reject/accept games based on hours played, achievements, global leader boards, etc (but no tags - they are page only vars)
                                                    This idealy would be fed in along with the user upon search. #>

                        [Game] $NewGame = New-Object Game

                        $NewGame.Name = $JSONGame.Name

                        $NewGame.AppID = $JSONGame.appid

                        $NewGame.Logo = $JSONGame.logo

                        $NewGame.Store = "$($SteamGameBaseURL)$($NewGame.AppID)/"

                        $NewGame.Play = "$($SteamRunBaseURL)$($NewGame.AppID)/"

                        $NewGame.AllHours = $JSONGame.hours_forever

                        $NewGame.RecentHours = $JSONGame.Hours

                        $NewGame.LastPlayed = ConvertUnixTime -Seconds $JSONGame.last_played

                        $ThisProfile.Games += , $NewGame
                    }

                    $Global:Profiles += $ThisProfile

                    NoticeMsg "`$Global:Profiles now contains $($Global:Profiles.Count) profile$(if ($Global:Profiles.Count -ne 1){"s"})"
                }

                $ThisProfile.WebFailureCount = 0;

                RedirectUser "/$($ViewMore)"
            }


        #endregion <# $VALIDATEPROFILE ROUTE - POST [ http://localhost/$($ValidateProfile) ] #>


        #region <# $RELOAD ROUTE - GET [ http://localhost/$($Reload) ] #>


            elseif ($Global:Context.Request.HttpMethod -eq "GET" -and
                    $Global:Context.Request.RawUrl -eq "/$($Reload)")
            {
                NetMsg "User: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"

                if (!(ProfileHasGames))
                {
                    continue
                }

                if ($ThisProfile.ReloadCount -le 0)
                {
                    NoticeMsg "No more reloads for '$($ThisProfile.Games[$ThisProfile.Index].Name)'"

                    SendUserToNextGame

                    continue
                }
                else
                {
                    $ThisProfile.ReloadCount -= 1

                    ActionMsg "Reloading last page for '$($ThisProfile.Games[$ThisProfile.Index].Name)'"

                    [byte[]] $Stream = [System.Text.Encoding]::UTF8.GetBytes($html) #$html should already be in memory to work with.

                    SendResponse -Stream $Stream

                    continue
                }
            }


        #endregion #region <# $RELOAD ROUTE - GET [ http://localhost/$($Reload) ] #>


        #region <# $FORWARD/$VIEWMORE/$BACKWARD ROUTE - GET [ http://localhost/$($Forward), http://localhost/$($ViewMore), http://localhost/$($Backward) ] #>


            elseif ($Global:Context.Request.HttpMethod -eq "GET" -and
                    ($Global:Context.Request.RawUrl -eq "/$($Forward)" -or
                     $Global:Context.Request.RawUrl -eq "/$($ViewMore)" -or
                     $Global:Context.Request.RawUrl -eq "/$($Backward)"))
            {
                NetMsg "User: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"

                UserDirectionChangeCheck

                if ($ThisProfile.WebFailureCount -ge $WebFailureLimit)
                {
                    [string] $WebFailure = "Too many web retrieval errors occurred"

                    BadMsg "$($WebFailure)"

                    [string] $Issue = "$($WebFailure):"

                    [string] $Detail = "$($ThisProfile.WebFailureCount) web request failures in a row met `$WebFailureLimit of $($WebFailureLimit)"

                    [string] $Suggest = "Is your network experiencing problems?  Try again later!"

                    $PageError = GeneratePageError $Issue $Detail $Suggest -UseCode

                    RedirectUser "/$($Home)"

                    $ThisProfile.WebFailureCount = 0;

                    continue
                }

                if (!(ProfileHasGames))
                {
                    continue
                }

                $ThisProfile.ReloadCount = $GameReloadRetries

                $ThisGame = SelectGame

                NoticeMsg "Index $($ThisProfile.Index) of $($ThisProfile.Games.Count -1): [ $($ThisGame.Name) ] [ $($ThisGame.Store) ]"

                if (!$ThisGame.RetrievedFromWeb)
                {
                    ActionMsg "Retrieving information from the web"

                    [Microsoft.PowerShell.Commands.WebResponseObject] $ThisGamesWebObject = $null

                    try
                    {
                        $ThisGamesWebObject = InvokeWebRequest -URL $ThisGame.Store

                        #throw "UNCOMMENTED THROW TEST ON LINE $(GetScriptErrorLine)"
                    }
                    catch
                    {
                        BadMsg "$($_)"

                        SendUserToNextGame

                        continue
                    }


                    ActionMsg "Parsing page data"

                    [System.MarshalByRefObject] $ThisGamesPage = New-Object -Com "HTMLFile"

                    $ThisGamesPage.Write([System.Text.Encoding]::Unicode.GetBytes($ThisGamesWebObject))


                    ActionMsg "Checking for app id '$($ThisGame.AppID)' in page header"

                    if ($ThisGamesPage.head.outerHTML -NotLike "*$($ThisGame.AppID)*")
                    {
                        BadMsg "Store page does not exist at '$($ThisGame.Store)'"

                        SendUserToNextGame

                        continue
                    }


                    ActionMsg "Gathering media"

                    foreach ($Movie in ($ThisGamesPage.getElementsByClassName("$($SteamGameStoreMovieClassPattern)")))
                    {
                        [Video] $NewVideo = New-Object Video

                        $NewVideo.SDMP4 = $Movie.getAttribute("$($SteamSDMP4Pattern)")

                        $NewVideo.SDWebM = $Movie.getAttribute("$($SteamSDWebMPattern)")

                        $NewVideo.HDMP4 = $Movie.getAttribute("$($SteamHDMP4Pattern)")

                        $NewVideo.HDWebM = $Movie.getAttribute("$($SteamHDWebMPattern)")

                        $ThisGame.Videos += ,$NewVideo
                    }

                    $ThisGame.Images = New-Object Images

                    foreach ($Image in ($ThisGamesPage.getElementsByClassName("$($SteamGameStoreImageClassPattern)")))
                    {
                        $ThisGame.Images.All += ,($Image.getAttribute("href"))
                    }

                    $ThisGame.RetrievedFromWeb = $true
                }
                else
                {
                    ActionMsg "Reusing previously retrieved information"
                }


                if (($ThisGame.Videos.Count -eq 0) -and ($ThisGame.Images.All.Count -eq 0))
                {
                    BadMsg "No media to use for '$($ThisGame.Name)' @ '$($ThisGame.Store)'"

                    SendUserToNextGame

                    continue
                }

                GoodMsg "Found $($ThisGame.Videos.Count) video$(if ($ThisGame.Videos.Count -ne 1){"s"}) & $($ThisGame.Images.All.Count) image$(if ($ThisGame.Images.All.Count -ne 1){"s"})"

                if ((($ThisGame.Videos.Count -eq 0) -or (AllVideosViewed)) -and
                    ($ThisGame.Images.Viewed))
                {
                    NoticeMsg "Resetting flags for all viewed '$($ThisGame.Name)' media"

                    if ($ThisGame.Videos.Count -gt 0)
                    {
                        foreach ($Video in $ThisGame.Videos)
                        {
                            $Video.Viewed = $false
                        }
                    }

                    $ThisGame.Images.Viewed = $false
                }


                ActionMsg "Selecting media"

                [string] $HTML = ""

                [string] $PageName = "$($ThisGame.Name) - $($ScriptName)"

                if (($ThisGame.Videos.Count -eq 0) -or (AllVideosViewed))
                {
                    ActionMsg "Generating image page"

                    [string] $Style = GenerateStyle -ImagePage

                    [string] $Head = GenerateHead $PageName $Style

                    [string] $Body = GenerateBody -ImagePage

                    $HTML = GeneratePage $Head $Body

                    $ThisGame.Images.Viewed = $true
                }
                else
                {
                    [int] $VideoIndex = GetUnseenVideoIndex

                    [Video] $VideoChoice = $ThisGame.Videos[$VideoIndex]

                    ActionMsg "Generating video page"

                    [string] $Style = GenerateStyle -VideoPage

                    [string] $Head = GenerateHead $PageName $Style

                    [string] $Body = GenerateBody -VideoPage

                    $HTML = GeneratePage $Head $Body

                    $VideoChoice.Viewed = $true
                }

                [byte[]] $Stream = [System.Text.Encoding]::UTF8.GetBytes($HTML)

                SendResponse $Stream

                $ThisProfile.WebFailureCount = 0;
            }


        #endregion <# $FORWARD/$VIEWMORE/$BACKWARD ROUTE - GET [ http://localhost/$($Forward), http://localhost/$($ViewMore), http://localhost/$($Backward) ] #>


        #region <# ELSE ROUTE - ALL OTHER UNKNOWN REQUESTS: OPTIONS/PATCH/DELETE/HEAD/PUT/POST/GET [ http://localhost/* ] #>


            elseif ($Global:Context.Request.HttpMethod -eq 'OPTIONS' -or
                    $Global:Context.Request.HttpMethod -eq 'PATCH' -or
                    $Global:Context.Request.HttpMethod -eq 'DELETE' -or
                    $Global:Context.Request.HttpMethod -eq 'HEAD' -or
                    $Global:Context.Request.HttpMethod -eq 'PUT' -or
                    $Global:Context.Request.HttpMethod -eq 'POST' -or
                    $Global:Context.Request.HttpMethod -eq 'GET')
            {
                NetMsg "User: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"

                NoticeMsg "Ignored non-implemented request: '$($Global:Context.Request.HttpMethod) - $($Global:Context.Request.Url)'"
            }


        #endregion <# ELSE ROUTE - ALL OTHER UNKNOWN REQUESTS: OPTIONS/PATCH/DELETE/HEAD/PUT/POST/GET [ http://localhost/* ] #>

    }

    StopServer

    DumpSaveFile

    FlushVariables
}
else
{
    BadMsg "Set `$RunScript to `$true to run"
}

GoodMsg "$($ScriptName) has ended$(if ($Logging) {" [ Log was appended to '$($LogFile)' ]"})$(if ($SaveProfileData) {" [ Gathered profile data was exported to '$($SaveFile)' ]"})"


#endregion <# MAIN SCRIPT #>