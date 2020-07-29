


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
 
 
 

#ask for admin rights
Use-RunAs
"Running as administrator"


""
""
"Please answer Y (yes) to the following question"
""
""

# Set start mode to automatic
Set-Service WinRM -StartMode Automatic -ErrorAction SilentlyContinue

"Step 1 done"

# Verify start mode and state - it should be running
#Get-WmiObject -Class win32_service | Where-Object {$_.name -like "WinRM"}


# Trust all hosts
Set-Item WSMan:localhost\client\trustedhosts -value * -ErrorAction SilentlyContinue

""
"Step 2 done"

# Verify trusted hosts configuration
#Get-Item WSMan:\localhost\Client\TrustedHosts
""


Try {
    Enable-PSRemoting –force
}Catch {
"An error occured while trying to enable powershell remoting."
"It may happen when it was already activated, or else you are in trouble"
}

""
""
"All set!"
"This will close automatically now"
Start-Sleep -s 5 
exit
