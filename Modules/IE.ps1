Set-Location $args[0]



Try{. .\Config.ps1 -ErrorAction Stop}
Catch {
    Write-Host Config File could not ne loaded. Looks like you removed the config file, left it open, or that you made a error when ediditng it.
    Write-Host This program will exit in one minute
    Start-Sleep -s 60
    Break
}






function simulateIE
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$False)]
        [int]$quitafter=3,
        [Parameter(Mandatory=$False)]
        [int]$depth=3
        )

    Try {



        $url2 = get_url
        browse -url $url2 -depth $depth -quitafter $quitafter -ErrorAction Stop
	   
    }
    Catch {

       "Result: Something failed with IE simulation"
    }
    if(!$Error){"Result: IE simulation successfully completed"}

    #close everything
    $temp = (Get-Process iexplore -ErrorAction SilentlyContinue | Stop-Process) 
    $temp = (Get-Process ielowutil -ErrorAction SilentlyContinue | Stop-Process) 

}





function browse 
{

# open internet explorer and follow links found on the page up to provided depth
    [CmdletBinding()]
    Param ([string]$url,
            [int]$depth,
            [int]$quitafter)

    $IE = New-Object -com internetexplorer.application 
    $IE.visible = $true


    $asm = [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $screen = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    $ie.Width = $screen.width
    $ie.Height =$screen.height
    $ie.Top =  0
    $ie.Left = 0



    $IE.navigate2($url)
    $IE.visible = $true
    Start-Sleep -s $quitafter
  

    while ($depth -gt 0){



     $hsg = Invoke-WebRequest -Uri ($url) -UseBasicParsing

        #get all valid links in the page
        $links = $hsg.Links.Href | Sort-Object | Get-Unique | select-string -pattern http
        $nblink = ($links).count

        #if there are links in the page
        if ($nblink -gt 0) {
            

            #prepare next link and depth for recursive call
            $url = $links[(Get-Random -Maximum ([array]$links).count)]



            $IE.navigate2($url)
            $IE.visible = $true
            Start-Sleep -s $quitafter

            $depth = $depth - 1 
     
       }
    }


    Start-Sleep -s 2

    $IE.quit()
    
}




function get_url
{

    $url = $IE_URIs[(Get-Random -Maximum ([array]$IE_URIs).count)]
    return $url
}

simulateIE -quitafter $IE_quitafter -depth $IE_depth 