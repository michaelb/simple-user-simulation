

<# 
.Synopsis 
   Function to email a specified log file. 
.DESCRIPTION 
   This funtion is designed to email a log file to a user or distribution list. 
 
.NOTES  
   Created by: Jason Wasser @wasserja 
   Modified: 4/2/2015 11:42:45 AM   
   Version 1.3 
   Changelog: 
    * Added authentication support with default of anonymous. Send-MailMessage  
      with Exchange forces authentication. 
    * Changed to use Send-MailMessage 
 
    To Do: 
     * Add ability to prompt for credentials 
     * secure password 
.EXAMPLE 
   Send-Log -Path "C:\Logs\Reboot.log" 
   Sends the C:\Logs\Reboot.log to the recipient in the script parameters. 
.EXAMPLE 
   Send-Log -Path c:\Logs\install.log -to admin@domain.com -from no-reply@domain.com -subject "See attached Log" -messagebody "See attached" -smtpserver smtp.domain.com 
#> 
function sendlogmail
{ 
    [CmdletBinding()] 
    [OutputType([int])] 
    Param 
    ( 
        # Enter the path for the log file to be emailed. 
        [Parameter(Mandatory=$true, 
                   ValueFromPipelineByPropertyName=$true, 
                   Position=0)] 
        [Alias("Attachment","LogPath")] 
        $Path, 
        [string]$SmtpServer = "smtp.domain.com", 
        [string]$ToAddress = "email@domain.com", 
        [string]$FromAddress = "usersimulationbot@domain.com", 
        [string]$Subject = "Automaton Alert $(get-date -Format "MM/dd/yyyy HH:mm")", 
        [string]$MessageBody = "Please see attached.`n`nSincerely,`nYour friendly AutoMaton.", 
        [string]$Username = "anonymous", 
        [string]$Password = "anonymous", 
        [int]$Port=25 
    ) 
 
    Begin 
    { 
    } 
    Process 
    { 
        if (Test-Path $Path) { 
             
            # SMTP Authentication 
            $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force 
            $Credential = New-Object System.Management.Automation.PSCredential($Username,$SecurePassword) 
 
            #Sending email  
            Write-Verbose "Sending $Path via SMTP." 
            Send-MailMessage -To $ToAddress -From $FromAddress -Subject $Subject -Body $MessageBody -Attachments $Path -SmtpServer $smtpServer -Credential $Credential -Port $Port 
            } 
        else { 
            Write-Error "Unable to find $Path." 
            } 
    } 
    End 
    { 
    } 
}



function Start-Process-Active
{
    param
    (
        [System.Management.Automation.Runspaces.PSSession]$Session,
        [string]$Executable,
        [string]$Argument,
        [string]$WorkingDirectory,
        [string]$UserID,
        [switch]$Verbose = $false

    )

    if (($Session -eq $null) -or ($Session.Availability -ne [System.Management.Automation.Runspaces.RunspaceAvailability]::Available))
    {
        $Session.Availability
        throw [System.Exception] "Session is not availabile"
    }

    Invoke-Command -Session $Session -ArgumentList $Executable,$Argument,$WorkingDirectory,$UserID -ScriptBlock {
        param($Executable, $Argument, $WorkingDirectory, $UserID)
        $action = New-ScheduledTaskAction -Execute $Executable -Argument $Argument -WorkingDirectory $WorkingDirectory
        $principal = New-ScheduledTaskPrincipal -userid $UserID
        $task = New-ScheduledTask -Action $action -Principal $principal
        $taskname = "_StartProcessActiveTask"
        try 
        {
            $registeredTask = Get-ScheduledTask $taskname -ErrorAction SilentlyContinue
        } 
        catch 
        {
            $registeredTask = $null
        }
        if ($registeredTask)
        {
            Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
        }
        $registeredTask = Register-ScheduledTask $taskname -InputObject $task

        Start-ScheduledTask -InputObject $registeredTask

        Unregister-ScheduledTask -InputObject $registeredTask -Confirm:$false
    }

}




function log_header 
{
    Param([int]$round_counter,
        [Parameter(Mandatory=$False)]
        [bool]$display=$true)

    if ($display){
        ""
        ""
        "=============================================================="
        "=========== Round N:" + [string]$round_counter+ " at time:" + (Get-Date) +  " ============"
        "=============================================================="
    }
}




function Use-RunAs 
{    
    # Check if script is running as Adminstrator and if not use RunAs 
    # Use Check Switch to check if admin 
     
    param([Switch]$Check) 
     
    $IsAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()` 
        ).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
         
    if ($Check) { return $IsAdmin }     
 
    if ($MyInvocation.ScriptName -ne "") 
    {  
        if (-not $IsAdmin)  
        {  
            try 
            {  
                $arg = "-file `"$($MyInvocation.ScriptName)`"" 
                Start-Process "$psHome\powershell.exe" -Verb Runas -ArgumentList $arg -ErrorAction 'stop'  
            } 
            catch 
            { 
                Write-Warning "Error - Failed to restart script with runas"
                "This script needs Admin rights to run! Exiting now"  
                Start-Sleep -s 6
                break               
            } 
            exit # Quit this session of powershell 
        }  
    }  
    else  
    {  
        Write-Warning "Error - Script must be saved as a .ps1 file first"  
        break  
    }  
} 
 
 


 function something-to-do
 {
    Param([hashtable]$hash)
    $empty = $true

    $hash.keys | % {$empty = ($empty -or $hash.Item($_))}

    return $empty 
 
 }
 

 function read-txt-line
 {
    Param([int]$line)
    $linecontent = @((Get-Content .\schedule.txt -TotalCount $line))[-1]
    
    $Action, $Parameter, $activity, $on, $PC, $timetype, $time = ($linecontent.ToLower()).Split(' ')
    $hr, $min = $time.Split(':')
    $minutes = [int]$hr * 60 + [int]$min
    #TODO trsanfert this to actions


    return $Action, $Parameter, $PC, $timetype, $minutes
 }

 

 function change-variables
 {
     [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
		[hashtable]$IEhash,
        [Parameter(Mandatory=$False)]
		[hashtable]$Maphash,
        [Parameter(Mandatory=$False)]
		[hashtable]$Typehash,
        [Parameter(Mandatory=$False)]
		[string]$Action,
        [Parameter(Mandatory=$False)]
		[string]$Parameter,
        [Parameter(Mandatory=$False)]
		[string]$PC,
        [Parameter(Mandatory=$False)]
		[int]$line_number,
        [Parameter(Mandatory=$False)]
		[array]$PClist
    )
    $bool = [bool]($Action -eq "start")

    if ($PC -eq "all"){
        if ($Parameter -eq "ie" -or $Parameter -eq "all"){$PClist | ForEach-Object {$IEhash.set_item($_, $bool)}}
        if ($Parameter -eq "mapshare" -or $Parameter -eq "all"){$PClist| ForEach-Object {$Maphash.set_item($_, $bool)}}
        if ($Parameter -eq "typing" -or $Parameter -eq "all"){$PClist| ForEach-Object {$Typehash.set_item($_, $bool)}}
    }


    elseif ($PC -eq "first" ){
        $PC = $PClist[0]
        if ($Parameter -eq "ie" -or $Parameter -eq "all"){$IEhash.set_item($PC, $bool)}
        if ($Parameter -eq "mapshare" -or $Parameter -eq "all"){$Maphash.set_item($PC, $bool)}
        if ($Parameter -eq "typing" -or $Parameter -eq "all"){$Typehash.set_item($PC, $bool)}

    }
    elseif ($PC -eq "random" ){
        $nb_pc = Get-Random -Maximum $PClist.Length
        if ($Parameter -eq "ie" -or $Parameter -eq "all"){$PClist| Get-Random -Count $nb_pc | ForEach-Object {$IEhash.set_item($_, $bool)}}
        if ($Parameter -eq "mapshare" -or $Parameter -eq "all"){$PClist| Get-Random -Count $nb_pc | ForEach-Object {$Maphash.set_item($_, $bool)}}
        if ($Parameter -eq "typing" -or $Parameter -eq "all"){$PClist| Get-Random -Count $nb_pc | ForEach-Object {$Typehash.set_item($_, $bool)}}

    }
    else { #so it must be a particular PC name
        if ($Parameter -eq "ie" -or $Parameter -eq "all"){$IEhash.set_item($PC, $bool)}
        if ($Parameter -eq "mapshare" -or $Parameter -eq "all"){$Maphash.set_item($PC, $bool)}
        if ($Parameter -eq "typing" -or $Parameter -eq "all"){$Typehash.set_item($PC, $bool)}
    }


    $lastactiontimestamp = [int]((Get-Date -UFormat "%R").Split(":")[0]) * 60 + [int]((Get-Date -UFormat "%R").Split(":")[1])
    return $IEhash, $Maphash, $Typehash, ($line_number+1), $lastactiontimestamp
 
 }





 function update-schedule
 <#return a new set of variables for each scheduled event
 #>
 {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
		[hashtable]$IEhash,
        [Parameter(Mandatory=$False)]
		[hashtable]$Maphash,
        [Parameter(Mandatory=$False)]
		[hashtable]$Typehash,
        [Parameter(Mandatory=$False)]
		[int]$line_number,
        [Parameter(Mandatory=$False)]
		[int]$lastactiontimestamp,
        [Parameter(Mandatory=$False)]
		[array]$PClist
    )

    $CurrentAction, $CurrentParameter, $CurrentPC, $Currenttimetype, $Currentminutes = read-txt-line -line $line_number
    $NextAction, $NextParameter, $NextPC, $Nexttimetype, $Nextminutes = read-txt-line -line ($line_number+1)
    $now = [int]((Get-Date -UFormat "%R").Split(":")[0]) * 60 + [int]((Get-Date -UFormat "%R").Split(":")[1]) #return time of the day in minutes


    if ($NextAction, $NextParameter, $NextPC, $Nexttimetype, $Nextminutes -eq $CurrentAction, $CurrentParameter, $CurrentPC, $Currenttimetype, $Currentminutes){
        return $IEhash,$Maphash, $Typehash, ($line_number+1), $lastactiontimestamp
    }#do not change anything if two same lines or last line of the file




    if ($Nexttimetype -eq "at"){
        if ($now -ge $Nextminutes){
            return (change-variables -IEhash $IEhash -Maphash $Maphash -Typehash $Typehash -Action $NextAction -Parameter $NextParameter -PC $NextPC -line_number $line_number -PClist $PClist)
        }
    }



    if ($Nexttimetype -eq "after"){
        $diff = $now - $lastactiontimestamp
        if ($diff -ge $Nextminutes){
            return (change-variables -IEhash $IEhash -Maphash $Maphash  -Typehash $Typehash -Action $NextAction -Parameter $NextParameter -PC $NextPC -line_number $line_number -PClist $PClist)
        }
    }

    return $IEhash, $Maphash,$Typehash, $line_number, $lastactiontimestamp
 
 }


