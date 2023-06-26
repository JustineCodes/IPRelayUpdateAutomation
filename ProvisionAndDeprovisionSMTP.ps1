
<#
    Main script

#>


param(
	[CmdletBinding()]
	[Parameter(Mandatory=$false,
	ValueFromPipelineByPropertyName=$true,
	HelpMessage="New IP Address")]
	$IpAddress,
    [Parameter(Mandatory=$false,
	ValueFromPipelineByPropertyName=$true,
	HelpMessage="New subnet mask")]
	$SubNetMask,
    [Parameter(Mandatory=$false,
	ValueFromPipelineByPropertyName=$true,
	HelpMessage="Add or Remove from ip.txt")]
	$AddOrRemove
    )

# $IpAddress = "96.2.0.128"
# $SubNetMask = "255.255.255.255"
# $AddOrremove = "Remove"

    $Date = Get-date -Format yyyy-MM-dd_HH-mm
    Start-transcript -Path "Update\to\your\transcript\path\$Date-Update-SmtpServerRelay.log" -NoClobber

<#
    Add your smtp relay server here
#>

## --> Update next line with a valid path
    $IpTextFile = "Path to ip.txt file"

    try{
        [System.Collections.ArrayList]$IpAddresses = Get-Content  $IpTextFile # curent ip.txt file

        }catch{
            $emailInfo = @{
                SmtpServer         = "SMTP Server"
                Subject            = "Automation Failed - SMTP"
                To                 = "SMTP Who to send to"
                From               = "SMTP From"
                }

                $CatchError = $Error[0]
                $Message            = "                
                <br>
                Failed to import current ip.txt file.
                <br>
                Error:<br>
                $CatchError
                <br>"

                Send-MailMessage @emailInfo -Body $Message -BodyAsHtml
                Throw "Script failed - An email with more information has been sent."
                Stop-Transcript
                break
        }



    switch ($AddOrRemove)
	{
		'Add'  {

                Write-Host "Before adding"
                $IpAddresses

                    $IpAddressWithMask = "$IpAddress,$SubNetMask"

                    $IpAddresses += ";$IpAddressWithMask"

                    $BuildIpTxt = $IpAddresses -Split ";" |
                        Sort-OBject | 
                        Get-Unique

                        try{
                            $BuildIpTxt | Where-Object {$_ -ne ""} |
                            Out-file $IpTextFile -Encoding ASCII
                    }catch{
                        $emailInfo = @{
                            SmtpServer         = "SMTP Server"
                            Subject            = "Automation Failed - SMTP"
                            To                 = "SMTP Who to send to"
                            From               = "SMTP From"
                            }

                            $CatchError = $Error[0]
                            $Message            = "                
                            <br>
                            Failed to create updated list of IP addresses in ip.tx file.
                            <br>
                            Error:<br>
                            $CatchError
                            <br>"

                            Send-MailMessage @emailInfo -Body $Message -BodyAsHtml
                            Throw "Script failed - An email with more information has been sent."
                            Stop-Transcript
                            break
                            
                    }
                

                        Write-Host "After adding"
                        $BuildIpTxt

            }
		'Remove'   {

                    Write-Host "Before removing"
                    $IpAddresses

                    $IpAddressWithMask = "$IpAddress,$SubNetMask"

                    $IpAddresses.Remove($IpAddressWithMask)

                    $BuildIpTxt = $IpAddresses -Split ";" |
                        Sort-OBject | 
                        Get-Unique

                    try{
                            $BuildIpTxt | Where-Object {$_ -ne ""} |
                            Out-file $IpTextFile  -Encoding ASCII
                    }catch{
                        $emailInfo = @{
                            SmtpServer         = "SMTP Server"
                            Subject            = "Automation Failed - SMTP"
                            To                 = "SMTP Who to send to"
                            From               = "SMTP From"
                            }

                            $CatchError = $Error[0]
                            $Message            = "                
                            <br>
                            Failed to create updated list of IP addresses in ip.tx file.
                            <br>
                            Error:<br>
                            $CatchError
                            <br>"

                            Send-MailMessage @emailInfo -Body $Message -BodyAsHtml
                            Throw "Script failed - An email with more information has been sent."
                            Stop-Transcript
                            break
                    }

                        Write-Host "After removing"
                        $BuildIpTxt

            }
		Default {
			Throw "Switch variable not set."
			break
		}
	}


<#
    Update each server
#>

## --> Update next line with comma seperated list of servers
    $Servers = "Server1","Server2","Server3"

    Foreach($Server in $Servers){

        try{

        Copy-Item -Path $IpTextFile -Destination "\\$Server\Path\to\ip.txt\file"
        Start-Sleep -Seconds 4

        Invoke-Command -ComputerName $Server -ScriptBlock {Start-ScheduledTask -TaskPath \pathName\ -TaskName UpdateSMTPRelay}

    }catch{
        $emailInfo = @{
            SmtpServer         = "SMTP Server"
            Subject            = "Automation Failed - SMTP"
            To                 = "SMTP Who to send to"
            From               = "SMTP From"
            }

            $CatchError = $Error[0]
            $Message            = "                
            <br>
            Failed to update server: $Server
            <br>
            Error:<br>
            $CatchError
            <br>"

            Send-MailMessage @emailInfo -Body $Message -BodyAsHtml
            Throw "Script failed - An email with more information has been sent."
            Stop-Transcript
            break
    }


    }

    Stop-Transcript

