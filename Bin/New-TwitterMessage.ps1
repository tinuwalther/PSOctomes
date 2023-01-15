#Requires -Modules BluebirdPS

<#
    https://powershellisfun.com/2022/08/01/create-a-tweet-on-twitter-using-powershell/
    got to the developer portal
    create a new app
    save your keys
    https://github.com/thedavecarroll/BluebirdPS
#>

[CmdletBinding()]
param (
    [Parameter(Mandatory=$false)]
    [String] $ApiUri,
    
    [Parameter(Mandatory=$true)]
    [String] $Message,

    [Parameter(Mandatory=$true)]
    [Object] $PSOctomes
)

begin {
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
    $ret = $null
}

process {
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')
    if ($message.Length -gt 140) {
        Write-Warning ("Length of tweet is {0} characters, maximum amount is 140. Aborting..." -f $Message.Length)
        break
    }

    try{

        $ApiKey            = "$($PSOctomes | Where-Object User -eq Twitter_ApiKey            | Select-Object -ExpandProperty Token)"
        $ApiSecret         = "$($PSOctomes | Where-Object User -eq Twitter_ApiSecret         | Select-Object -ExpandProperty Token)"
        $AccessToken       = "$($PSOctomes | Where-Object User -eq Twitter_AccessToken       | Select-Object -ExpandProperty Token)"
        $AccessTokenSecret = "$($PSOctomes | Where-Object User -eq Twitter_AccessTokenSecret | Select-Object -ExpandProperty Token)"

        if(Test-TwitterAuthentication){
            Write-Verbose "TwitterAuthentication: $true"
        }else{
            Write-Warning "Could not authenticate to Twitter, check the authentication values:"
            Write-Host $(Show-TwitterAuthentication -Confirm:$false | Out-String)
        }

        $Properties = @{
            TweetText = $Message
        }
        $ret = Publish-Tweet @Properties

        Write-Host "$($function)"
        $ret | Out-String

    }catch{
        Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
        $Error.Clear()
    }
}

end {
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Verbose $('Finished in:', $Formatted -Join ' ')
    return $ret
}

<#
#Requires -Modules BluebirdPS

https://docs.bluebirdps.dev/en/latest/about_BluebirdPS/

$BluebirdPSLastResponse
Get-BluebirdPSHistory -Last 5

Set-TwitterAuthentication
Show-TwitterAuthentication
Test-TwitterAuthentication
#>

<#
        #region Authentication
        $ApiUri                 = $PSOctomes | Where-Object User -eq oauth_token        | Select-Object -ExpandProperty ApiUri #API Key
        $signature_uri          = $PSOctomes | Where-Object User -eq oauth_consumer_key | Select-Object -ExpandProperty ApiUri #Access Token
        $oauth_consumer_key     = $PSOctomes | Where-Object User -eq oauth_consumer_key | Select-Object -ExpandProperty Token #API Key
        $oauth_token            = $PSOctomes | Where-Object User -eq oauth_token        | Select-Object -ExpandProperty Token #Access Token

        $oauth_signature_method = 'HMAC-SHA1'
        $oauth_timestamp        = [System.Math]::Floor(([System.DateTime]::UtcNow - [System.DateTime]::Parse("1/1/1970")).TotalSeconds)
        $oauth_nonce            =  [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes((Get-Random -Minimum 100000 -Maximum 999999).ToString()))
        $oauth_version          = '1.0'
        
            #region signautre
            $signature = 'POST&'  
            $signature += [System.Uri]::EscapeDataString($signature_uri) + '&'  
            $signature += [System.Uri]::EscapeDataString('oauth_consumer_key=' + $oauth_consumer_key + '&')  
            $signature += [System.Uri]::EscapeDataString('oauth_nonce=' + $oauth_nonce + '&')   
            $signature += [System.Uri]::EscapeDataString('oauth_signature_method=HMAC-SHA1&')  
            $signature += [System.Uri]::EscapeDataString('oauth_timestamp=' + $oauth_timestamp + '&')  
            $signature += [System.Uri]::EscapeDataString('oauth_token=' + $oauth_token + '&')  
            $signature += [System.Uri]::EscapeDataString('oauth_version=1.0a&')  
            $signature += [System.Uri]::EscapeDataString('status=' + $status)  

            $signature_key = [System.Uri]::EscapeDataString("oauth_consumer_key=" + $oauth_consumer_key) + '&' + [System.Uri]::EscapeDataString("oauth_token =" + $oauth_token)  

            $hmacsha1 = New-Object  -TypeName System.Security.Cryptography.HMACSHA1  
            $hmacsha1.Key = [System.Text.Encoding]::ASCII.GetBytes($signature_key)  
            $oauth_signature =  [System.Convert]::ToBase64String($hmacsha1.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($signature)))  
            #endregion signature

        #endregion

        #region Authorization
        $oauth_authorization = 'OAuth '
        $oauth_authorization += "oauth_consumer_key=`"$($oauth_consumer_key)`","
        $oauth_authorization += "oauth_token=`"$($oauth_consumer_key)`","
        $oauth_authorization += "oauth_signature_method=`"$($oauth_signature_method)`","
        $oauth_authorization += "oauth_timestamp=`"$($oauth_timestamp)`","
        $oauth_authorization += "oauth_nonce=`"$($oauth_nonce)`","
        $oauth_authorization += "oauth_version=`"$($oauth_version)`","
        $oauth_authorization += "oauth_signature=`"$($oauth_signature)`""
        #endregion

        $headers = @{
            Authorization = $oauth_authorization
        }

        # $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
        # $headers.Add("Authorization", "OAuth oauth_consumer_key=`"$($oauth_consumer_key)`",oauth_token=`"$($oauth_consumer_key)`",oauth_signature_method=`"$($oauth_signature_method)`",oauth_timestamp=`"$($oauth_timestamp)`",oauth_nonce=`"$($oauth_nonce)`",oauth_version=`"$($oauth_version)`",oauth_signature=`"$($oauth_signature)`"")
        # $headers.Add("Content-Type", "application/json")

        $payload = @{
            text = $Message
        }

        $Properties = @{
            Uri         = $ApiUri
            Headers     = $headers
            Body        = (ConvertTo-Json -Depth 6 -InputObject $payload)
            Method      = 'POST'
            ContentType = 'application/json; charset=UTF-8'
            ErrorAction = 'Stop'
        }
        $ret = Invoke-RestMethod @Properties
        $ret | ConvertTo-Json
#>