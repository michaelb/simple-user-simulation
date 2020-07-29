#requires -version 3.0
Set-Location $args[0]


Try{. .\Config.ps1 -ErrorAction Stop}
Catch {
    Write-Host Config File could not ne loaded. Looks like you removed the config file, left it open, or that you made a error when ediditng it.
    Write-Host This program will exit in one minute
    Start-Sleep -s 60
    Break
}



function mapdrive #warning : this could expose the machine to a real attack
{
    #$MapShare_locations = "\\sharepointofjohnsmith.microsoft", "\\MySharedDrivs", "\\catchmeifyoukhan.net" #this figures in the config file




    try {
        "Trying to connect to shared drive and map it to drive 'K'"
        $sharelocation = $MapShare_locations[(Get-Random -Maximum ([array]$MapShare_locations).count)]
        New-PSDrive -Name "K" -PSProvider FileSystem -Root $sharelocation  -ErrorAction Stop
    }
    catch {
        "Failure attempting to connect to shared drive. You may have (purposely?) provided a wrong sharepoint network location"
    }

    if (!$Error){"Result: Map Shares simulation completed successfully"}


}

mapdrive