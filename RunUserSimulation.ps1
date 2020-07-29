

#just in case it was launched from the wrong folder, as the present working directory
# NEEDS to be the one containing the script (because of relative-path dot sourcing other modules)
$script_path = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
cd $script_path



#generate logs
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
$LogName = Get-Date -Format "yyyy-MM-dd-----HH-mm-ss"
$global:global_Log = ".\Logs\" + $LogName + ".txt"
Start-Transcript -path $global_Log -append -IncludeInvocationHeader




# Start the actual script



#import config and tools, and modules
Try{. .\Config.ps1 -ErrorAction Stop}
Catch {
    Write-Host Config File could not ne loaded. Looks like you removed the config file, left it open, or that you made a error when ediditng it.
    Write-Host This program will exit in one minute
    Start-Sleep -s 60
    Break
}

Try{. .\Modules\Tools.ps1 -ErrorAction Stop}
Catch {
    Write-Host One or more module could not be loaded.
    Write-Host This program will exit in one minute
    Start-Sleep -s 60
    Break
}










function simulate-user 
{
<#
.SYNOPSIS
This function simulate user behavior on the local windows systems. Author: Michael Bleuez. All rights belong to RHEA GROUP


.PARAMETER Unactivity
Performs selected actions each "Unactivity" seconds (default 2s); a higher unactivity will generate less traffic & user activity. Must be a positive integer

.PARAMETER actiontimeout
Set timeout in seconds for each action to be perfomed so the script does not hang (default 60s).

.PARAMETER duration
How long the whole programm should run (in minutes). 0 means no limit

.PARAMETER All
Equivalent to all parameters below

.PARAMETER IE
Turn on Internet Explorer (random) navigation

.PARAMETER MapShare
Turn on network shares mapping

.NOTES
Some of the powershell cmdlets require powershell version 3+


#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
		[bool]$IE,
        [Parameter(Mandatory=$False)]
		[bool]$MapShare,
        [Parameter(Mandatory=$False)]
		[bool]$Typing,
        [Parameter(Mandatory=$False)]
		[bool]$schedule,
        [Parameter(Mandatory=$False)]
		[int]$Unactivity = 2,
        [Parameter(Mandatory=$False)]
		[int]$actiontimeout = 60,
        [Parameter(Mandatory=$False)]
		[int]$duration = 0
    )


    $pc = "all"
    $list_computer = ,$pc
    $IEhash = @{}
    $Maphash = @{}
    $Typehash = @{}

    $IEhash.Add($pc, $IE)
    $Maphash.Add($pc, $MapShare)
    $Typehash.Add($pc, $Typing)
  

    "Start of operations"
    $round_counter = 0
    $startDate = Get-Date
    $lastactiontimestamp = [int]((Get-Date -UFormat "%R").Split(":")[0]) * 60 + [int]((Get-Date -UFormat "%R").Split(":")[1])#time of the day but in minutes
    $line_number = 1
    $displayheader = $true

    while (($duration -eq 0) -or ($startDate.AddMinutes($duration) -gt (Get-Date))) {                                                           
        Start-Sleep -s $Unactivity #sleep for unactivity time
        log_header $round_counter $displayheader
        $round_counter += $displayheader #only increase count if we displayed the previous header
        $displayheader = $false #set to false to only display non-empty round headers 


        if ($schedule) {$IEhash, $Maphash, $Typehash, $line_number, $lastactiontimestamp = update-schedule -IEhash $IEhash -Maphash $Maphash -Typehash $Typehash -line_number $line_number -lastactiontimestamp $lastactiontimestamp -PClist $list_computer}


        ########################################################################place new features under this

        <#if (<$switchhash>[$pc]){
            $job = Start-Job -Name <name> -ArgumentList $pwd -FilePath Modules\name.ps1"
            Get-Job | Wait-Job -Timeout $actiontimeout |  Receive-Job
                      
            #failsafe so no stray windows/process
            $temp = (Get-Job  -Name <name> -ErrorAction SilentlyContinue| Stop-Job) 
            "----------------------------------------------------------"
            $displayheader = $true
            Start-Sleep -s $Unactivity
        }#> #template

        if ($IEhash[$pc]){
            $job = Start-Job -Name EIsimu -ArgumentList $pwd -FilePath .\Modules\IE.ps1
            Get-Job | Wait-Job -Timeout $actiontimeout |  Receive-Job
           
    
            #failsafe so no stray windows/process
            $temp = (Get-Job -Name EIsimu -ErrorAction SilentlyContinue| Stop-Job) 
            $temp = (Get-Process iexplore -ErrorAction SilentlyContinue | Stop-Process) 
            $temp = (Get-Process ielowutil -ErrorAction SilentlyContinue | Stop-Process) 
            "----------------------------------------------------------"
            $displayheader = $true
            Start-Sleep -s $Unactivity
        } #generate IE activity


        if ($Maphash[$pc]){
            $job = Start-Job -Name MapShare -ArgumentList $pwd -FilePath .\Modules\MapShare.ps1
            Get-Job | Wait-Job -Timeout $actiontimeout | Receive-Job
  
            
            #failsafe so no stray windows/process
            (Get-Job MapSharesimu -ErrorAction SilentlyContinue | Stop-Job) |Out-Null
            "-------------------------------------------------------------------------------"
            $displayheader = $true
            Start-Sleep -s $Unactivity
        } #generate shares map activity


        if ($Typehash[$pc]){
                $job = Start-Job -Name Typekey -ArgumentList $pwd -FilePath "Modules\Type.ps1"
                Get-Job | Wait-Job -Timeout $actiontimeout |  Receive-Job
    
                      
                #failsafe so no stray windows/process
                $temp = (Get-Job  -Name Typekey -ErrorAction SilentlyContinue| Stop-Job) 
                "----------------------------------------------------------"
                $displayheader = $true
                Start-Sleep -s $Unactivity
        }#generate key strokes activity



        #######################################################################place new features above this

    }#end of while
    
    
    #stop the transcript
    Stop-Transcript
     
    if ($global_email){
        sendlogmail -Path $global_Log -SmtpServer $PSEmailServer -ToAddress $email_address
        }


    "This is the end of the user simulation"
    "Script will exit in one minute"
    Start-Sleep -s 60

}

















function simulate-user-server 
{
<#
.SYNOPSIS
This function simulate user behavior on multiple (networked) windows systems. Author: Michael Bleuez. All rights belong to RHEA GROUP
See simulate-user for the common parameters.

.PARAMETER autodetect
If the computer is to detect automatically the PCs on the same network. Not reliable

.PARAMETER PClist
In case autodetect is disabled, provide a list of the PCs of the network to send tasks to.




.NOTES
Some of the powershell cmdlets require powershell version 3+


#>
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
		[bool]$IE,
        [Parameter(Mandatory=$False)]
		[bool]$MapShare,
        [Parameter(Mandatory=$False)]
		[bool]$Typing,
        [Parameter(Mandatory=$False)]
		[bool]$schedule,
        [Parameter(Mandatory=$False)]
		[int]$Unactivity = 2,
        [Parameter(Mandatory=$False)]
		[int]$actiontimeout = 60,
        [Parameter(Mandatory=$False)]
		[int]$duration = 0,
        [Parameter(Mandatory=$False)]
		[bool]$autodetect = $true,
        [Parameter(Mandatory=$False)]
		[array]$PClist
    )


    Use-RunAs
    "Running as administrator"

    if ($autodetect){
        $list_computer_dirty = net view
        $list_computer = @()
        ForEach ($line in $list_computer_dirty){
            if ($line.StartsWith("\\")){
                $list_computer += $line.substring(2) -replace '(^\s+|\s+$)','' -replace '\s+',' '
            }
        }
        "Detected Computers:"
        $list_computer 
        "Start of operations"
    } 
     else {
        $list_computer = $PClist
        "Computers on the network:"
        $list_computer
        "Start of operations"
    }


        
    $IEhash = @{}
    $Maphash = @{}
    $Typehash = @{}

    foreach ($pc in $list_computer){
        $IEhash.Add($pc, $IE)
        $Maphash.Add($pc, $MapShare)
        $Typehash.Add($pc, $Typing)
    }
  




    $round_counter = 0
    $startDate = Get-Date
    $lastactiontimestamp = [int]((Get-Date -UFormat "%R").Split(":")[0]) * 60 + [int]((Get-Date -UFormat "%R").Split(":")[1]) #time of the day but in minutes
    $line_number = 1
    $displayheader = $true

    while (($duration -eq 0) -or ($startDate.AddMinutes($duration) -gt (Get-Date))) {  
            Start-Sleep -s $Unactivity
            log_header $round_counter $displayheader
            $round_counter += $displayheader #only increase count if we displayed the previous header
            
             if ($schedule) {$IEhash, $Maphash, $Typehash, $line_number, $lastactiontimestamp = update-schedule -IEhash $IEhash -Maphash $Maphash -Typehash $Typehash -line_number $line_number -lastactiontimestamp $lastactiontimestamp -PClist $list_computer}

            ########################################################################place new features under this


            if ($true){
                "#####IE activity####"
                Try {
                    foreach ($pc in $list_computer){
                        if ($IEhash[$pc]){
                            $job = Invoke-Command -ComputerName $pc -ArgumentList $pwd -FilePath .\Modules\IE.ps1 -AsJob -JobName $pc -ErrorAction Stop
                        }
                    }

                    #wait for all to complete or timeout
                    Get-Job | Wait-Job -Timeout $actiontimeout |  Receive-Job 

                    #failsafe
                    "Exiting activity"
                      foreach ($pc in $list_computer){
                         if ($IEhash[$pc]){
                            (Get-Job IEsimu -ErrorAction SilentlyContinue | Stop-Job) |Out-Null -ErrorAction Stop
                            $temp = Invoke-Command -ComputerName $pc -ScriptBlock {Get-Process iexplore -ErrorAction SilentlyContinue | Stop-Process} -ErrorAction Stop
                            $temp = Invoke-Command -ComputerName $pc -ScriptBlock {Get-Process ielowutil -ErrorAction SilentlyContinue | Stop-Process} -ErrorAction Stop
                         }
                      } 
                    "----------------------------------------------------------"
                }
                Catch {"Failed to send command to remote PC"}
            } #generate IE activity
            
            Start-Sleep -s $Unactivity

            if ($true){
                "#####Map Shares activity#####"
                Try {
                    foreach ($pc in $list_computer){
                        if ($Maphash[$pc]){
                            $job = Invoke-Command -ComputerName $pc -ArgumentList $pwd -FilePath .\Modules\MapShare.ps1 -AsJob -JobName MapShares -ErrorAction Stop
                        }
                    }

                    #wait for all to complete or timeout
                    Get-Job | Wait-Job -Timeout $actiontimeout | Receive-Job 
  
                    #failsafe so no stray windows/process
                    "Exiting activity"
                    foreach ($pc in $list_computer){
                        if ($Maphash[$pc]){$temp = Invoke-Command -ComputerName $pc -ScriptBlock {(Get-Job MapShares -ErrorAction SilentlyContinue | Stop-Job) |Out-Null} -ErrorAction Stop}
                    }
                    "----------------------------------------------------------"
                }
                catch {"Failed to send command to remote PC"}
            } #generate shares map activity

            Start-Sleep -s $Unactivity

              if ($true){
                "#####Typing activity#####"
                Try {
                    foreach ($pc in $list_computer){
                        if ($Typehash[$pc]){
                            $job = Invoke-Command -ComputerName $pc -ArgumentList $pwd -FilePath .\Modules\Type.ps1 -AsJob -JobName Type -ErrorAction Stop
                        }
                    }

                    #wait for all to complete or timeout
                    Get-Job | Wait-Job -Timeout $actiontimeout | Receive-Job 
  
                    #failsafe so no stray windows/process
                    "Exiting activity"
                    foreach ($pc in $list_computer){
                        if ($Typehash[$pc]){$temp = Invoke-Command -ComputerName $pc -ScriptBlock {(Get-Job Type -ErrorAction SilentlyContinue | Stop-Job) |Out-Null} -ErrorAction Stop}
                    }
                    "----------------------------------------------------------"
                }
                catch {"Failed to send command to remote PC"}
            } #generate shares map activity


            #######################################################################place new features above this

    }#end of while
    





        
}



















#Launch the correct script

if (!$global_standalone){
    "If you see an empty log, or few logs starting at about the same time, only the most recent will be significant";"The formers are 'orphan' logs stopped when the script was relaunched with admin rights (after the UAC prompt)"
    "Running in multisession mode"
    simulate-user-server -IE $global_IE -MapShare $global_MapShare -Typing $global_type -schedule $global_schedule -Unactivity $global_unactivity -actiontimeout $global_actiontimeout -duration $global_duration -autodetect $global_autodetect -PClist $global_listPCs
}
else {
    "Running on the local session only"
    simulate-user -IE $global_IE -MapShare $global_MapShare -Typing $global_type -schedule $global_schedule -Unactivity $global_unactivity -actiontimeout $global_actiontimeout -duration $global_duration
}

"This is the end of the user simulation"
"Script will exit in one minute"
Start-Sleep -s 60















#stop the transcrit if it was not stopped before
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"