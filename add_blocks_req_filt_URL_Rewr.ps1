#///////// Script to add blocks to Request Filtering and URL Rewrite Module \\\\\\\\#

####### Only need to declare these variables. $blockedURIs can be list of comma separated values
$blockedURIs = '.bat' #'.ppp','.p','.t0'
$Websitename = 'Default Web Site'
$RuleName = 'RequestBlockingRule1 with spaces'      #URL Rewrite rule name
$RuleName2 = 'Test rule'                            #Request FIltering rule name

####### Get a list of all conditions currently defined in the above rule
$listofcollections = Get-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST/$Websitename" -Filter "/system.webServer/rewrite/rules/rule[@name='$RuleName']/conditions" -Name collection | select -ExpandProperty pattern
$listofreqfiltering = Get-WebConfigurationProperty -PSPath "MACHINE/WEBROOT/APPHOST/$Websitename" -Filter "/system.webServer/security/requestFiltering/filteringRules/filteringRule[@name='$RuleName2']" -Name denyStrings | select -ExpandProperty collection | select -ExpandProperty string

####### Cycle through all the block requests above
ForEach($URI in $blockedURIs){

####### Check to see if that condition already exists in Request FIltering rule $RuleName2
if ($URI -notin $listofreqfiltering) {
    Write-Output "adsadsadsadsadsa"
     $list2 = @{
     pspath = "MACHINE/WEBROOT/APPHOST/$Websitename"
     filter = "system.webServer/security/requestFiltering/filteringRules/filteringRule[@name='$RuleName2']/denyStrings"
     Value = @{
        string = $URI
        }
    }
    Write-Output "[+] Adding '$URI' to Request Filtering rule '$RuleName2'"
    Add-WebConfiguration @list2

    }
else {Write-Output "[!] This condition: '$URI' already exists in Request Filtering rule '$RuleName2'"}

####### Request filtering blocks the string $URI in the URL request, but we need to specify wildcard '*' for URL Rewrite
$URI = "*$URI*"

####### Check to see if that condition already exists in URL Rewrite rule $RuleName
if ($URI -notin $listofcollections) {
    $list = @{
     pspath = "MACHINE/WEBROOT/APPHOST/$Websitename"
     filter = "/system.webServer/rewrite/rules/rule[@name='$RuleName']/conditions"
     Value = @{
        input = '{REQUEST_URI}'
        matchType ='Pattern'
        pattern =$URI
        ignoreCase ='True'
        negate ='False'
        }
    }
    Write-Output "[+] Adding '$URI' to '$RuleName'"
    Add-WebConfiguration @list
}

else {
    Write-Output "[!] This condition: '$URI' already exists in '$RuleName'"
    }
}
