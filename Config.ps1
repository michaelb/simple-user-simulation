#Hey! If you want to change some parameters you are at the right place!
#You can ONLY change the values of the variables, not their names!!
#You also MUST change values by values of the same type: eg you can change "$IEdepth = 4" to "$IEdepth = 3" but NOT to "$IEdepth = 'auto' "




##################################################################################################################
#######################################################[GLOBAL CONFIG]#####################################################		           
				 #parameters for the main programm

#what to simulate ($false / $true)

$global_IE = $true		         	#whether to simulate an user internet explorer activity
$global_MapShare = $false	      		#whether to attempt to map shared drives to 'K' !Warning! This can expose the machine to attacks

$global_type = $false                       #whether to simulate keystrokes (copying the contents of file .\Misc\to_write.txt) 
                                         #!Beware of this feature! If another script is running, or even just an user clicking somewhere, this could shut down the virtual machine or launch programms via keystrokes
                                         


 			

$global_unactivity = 1		   	#time (seconds) the user will do nothing, before repeating a range of different activities. Value between 1 and 3600
$global_actiontimeout = 60	        	#max time in seconds by activity, if something takes longer it will be terminated. Value between 1 and 3600
$global_duration = 0				#how long run the simulation? Specify the duration in minutes from 1 to 1000000000, with 0 indicating infinite. Remember it has to complete a round of activities before stopping
						            #so if some activity takes long it will not stop exactly after the specified time.






$global_standalone = $true		#whether to operate only localy ($true) or server-mode ($false)






$global_schedule = $false       #whether to follow the given schedule




$global_email = $false          		#whether to send an email with the latest log to the specified address at the end of the simulation (if it's ending). Your server must support anonymous sending (rarely the case...).

  
##################################################################################################################
##################################################################################################################












##################################################################################################################
#######################################################[Server Mode]#####################################################		           
				 #parameters for the server mode function (if active)
$global_autodetect = $true 		# whether to auto-detect PC running on the same network. Beware! : it relies on microsoft 'net -view' command and windows discovery of network PC. It is unreliable, even more if the
					#instructions given in documentation are not followed

$global_listPCs = "PC1","PC2"		#Has no effect if autodetect is $true. But can be useful if one already know the what the network is made of (read: the names of PCs in the network)
					               # IF you already know the names of the PCs in the network and are sure they are connected etc... PLEASE set autodetect to false and use this list, it is much more reliable



##################################################################################################################
##################################################################################################################















##################################################################################################################
#######################################################[IE]#####################################################		           
				 #parameters for the internet explorer usage simulation

$IE_quitafter = 3                #quitafter : How much time to wait before closing a webpage. default 3 (seconds), value between 1 and 10000000000

 $IE_depth = 5                   #depth: IE simulation browse a website from the list, click a link found on the page etc.... 
                                  #until  it reach depth. value between 1 and 1000000 . Note: the bigger the depth, the higher the chances of browsing being reported as failure (more chances to click a invalid link or timeout)



$IE_URIs = 	"https://news.google.com",
		"https://www.reddit.com",
		"https://www.msn.com",
		"http://www.cnn.com",
		"http://www.bbc.com",
		"http://unvalidaddressthisdonoexist.ddns.net"	      #list of urls to try to visit for IE simulation

##################################################################################################################
##################################################################################################################
















##################################################################################################################
##################################################[MapShare]#########################################################
				#parameters for the shared drive maping (LLMNR traffic generator)



$MapShare_locations =	"\\sharepointofjohnsmith.microsoft\share", 
			            "\\MySharedDrivs\share"		                    	#list of (fakes?) sharepoints the user try to connect to and map their K drive to.



####################################################################################################################
##################################################################################################################











##################################################[MapShare]#########################################################
				#parameters for the shared drive maping (LLMNR traffic generator)

#the text to be typed can be found (and modified) in Misc\to_write.txt


$Type_speed = 60        #time taken to write one character, in milliseconds (lower value means faster typing) Value between 1 and 10000000 . Anything too big is unadvised as for long text it would take a while and get timeout-ed



####################################################################################################################











##################################################[Mail logs]#########################################################
                                      #how and to whom send logs. !this could not be tested. IF YOU ARE UNSURE DO NOT MODIFY ANTYHING

$global:PSEmailServer = "smtp.domain.com"  	  	#if you wish to get logs via e-mail and activated the global_email option, you must provide a valid SMTP server. The server also must support anonymous sender (which is rarely the case..)
$global:email_address = "name@domain.com"   		#The email address to who send the logs. If global_email is activated, you have to provide a valid email.



##################################################################################################################

 