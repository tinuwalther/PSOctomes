[CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String] $WebhookUrl,

        [Parameter(Mandatory=$false)]
        [String] $SectionTitle,

        [Parameter(Mandatory=$true)]
        [String] $SectionDescription,

        [Parameter(Mandatory=$false)]
        [Int] $SectionColor = 5789910, #5858D6

        [Parameter(Mandatory=$false)]
        [String] $FactTitle,

        [Parameter(Mandatory=$false)]
        [String] $FactMessage,

        [Parameter(Mandatory=$false)]
        [String] $AuthorName = 'The PowerSHell Hook',

        [Parameter(Mandatory=$false)]
        [String] $AuthorAvatar = 'http://img1.wikia.nocookie.net/__cb20111027212138/pichipichipitchadventures/es/images/thumb/f/fd/Captain-Hook-Wallpaper-disney-villains-976702_1024_768.png/456px-Captain-Hook-Wallpaper-disney-villains-976702_1024_768.png'
)

begin{
    $StartTime = Get-Date
    $function = $($MyInvocation.MyCommand.Name)
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Begin   ]', $function -Join ' ')
    $ret = $null
}

process{
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ Process ]', $function -Join ' ')

    try{

        # Facts
        if([String]::IsNullOrEmpty($FactTitle)){
            # New section with no embed object
            $EmbededSection = @{
                'title'       = $SectionTitle
                'description' = $SectionDescription
                'color'       = $SectionColor
            }
            Write-Verbose "EmbededSection:"
            Write-Verbose "$($EmbededSection | Out-String)"
        }else{
            $EmbededFacts = @{
                'name'   = $FactTitle
                'value'  = $FactMessage
                'inline' = $false
            }
            Write-Verbose "EmbededFacts:"
            Write-Verbose "$($EmbededFacts | Out-String)"

            # New section as embed object
            $EmbededSection = @{
                'title'       = $SectionTitle
                'description' = $SectionDescription
                'color'       = $SectionColor
                "fields"      = @($EmbededFacts)
            }
            Write-Verbose "EmbededSection:"
            Write-Verbose "$($EmbededSection | Out-String)"
        }

        # Full message
        $FullMessage = @{
            'username'   = $AuthorName
            'avatar_url' = $AuthorAvatar
            "embeds"     = @($EmbededSection)
        }
        Write-Verbose "FullMessage:"
        Write-Verbose "$($FullMessage | Out-String)"

        $Properties = @{
            Uri         = $WebhookUrl
            Body        = (ConvertTo-Json -Depth 6 -InputObject $FullMessage)
            Method      = 'Post'
            ContentType = 'application/json; charset=UTF-8'
        }
        $Response = Invoke-RestMethod @Properties
        $ret = $Response.result

    }catch{
        Write-Warning $('ScriptName:', $($_.InvocationInfo.ScriptName), 'LineNumber:', $($_.InvocationInfo.ScriptLineNumber), 'Message:', $($_.Exception.Message) -Join ' ')
        $Error.Clear()
    }
}

end{
    Write-Verbose $('[', (Get-Date -f 'yyyy-MM-dd HH:mm:ss.fff'), ']', '[ End     ]', $function -Join ' ')
    $TimeSpan  = New-TimeSpan -Start $StartTime -End (Get-Date)
    $Formatted = $TimeSpan | ForEach-Object {
        '{1:0}h {2:0}m {3:0}s {4:000}ms' -f $_.Days, $_.Hours, $_.Minutes, $_.Seconds, $_.Milliseconds
    }
    Write-Verbose $('Finished in:', $Formatted -Join ' ')
    return $ret
}
