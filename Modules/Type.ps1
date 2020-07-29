#type module

Set-Location $args[0]



Try{. .\Config.ps1 -ErrorAction Stop}
Catch {
    Write-Host Config File could not ne loaded. Looks like you removed the config file, left it open, or that you made a error when ediditng it.
    Write-Host This program will exit in one minute
    Start-Sleep -s 60
    Break
}






function simulate-keys{

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
		[bool]$save=$true
    )



    Try{

        $text = Get-Content Misc\to_write.txt
        $text = $text.Split(" ")


    
        $wshell = new-object -comObject wscript.shell -ErrorAction Stop

        "This will not go in the file, but just in case there is a problem so there are still keystrokes password is johnsmith1985" | ForEach {$word = $_;$word = $word.Split("");$word | foreach {Start-Sleep -Milliseconds $Type_speed; $wshell.SendKeys($_)};$wshell.sendkeys(" ")}
        
        start notepad Misc\written.txt
        $null = $wshell.AppActivate('written - Notepad')
        Sleep 1


        #clear file
        $wshell.SendKeys("^{a}")
        $wshell.SendKeys("{DEL}")



        #sending keystrokes, with letters well separated, one after each other
       
       $text | ForEach {
            $word = $_
            $word = $word.Split("")

            $word | foreach {
                Start-Sleep -Milliseconds $Type_speed
                $wshell.SendKeys($_)
            }

            $wshell.sendkeys(" ")
        }



        if ($save){$wshell.SendKeys("^{s}");$wshell.SendKeys("%{F4}")}

     }
     Catch{
        "Failed to send keystrokes to text editor"
     }
     if (!$Error){"Result: Typing simulation completed succesfully"}
}




simulate-keys



