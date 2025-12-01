function Enable-MintilsDefaultAlias {
    <#
    .SYNOPSIS
        Load common aliases, only if user opts-in by calling this.
    .NOTES
        Because this is from a module, you might need to use 'Set-alias -Force' and mabye '-Scope Global'
    #>
    [Alias('Mint.Enable-DefaultAlias')]
    [Cmdletbinding()]
    param(
        # required for readonly
        [switch] $Force,

        [ArgumentCompletions('Global', 'Local', 'Script')]
        [string] $Scope = 'Global'
    )

    $splat = @{
        PassThru = $True
    }
    # note: PSBoundParameters does not contain default values
    if( $PSBoundParameters.ContainsKey('Force') ) { $splat.Force = $Force }
    if( $PSBoundParameters.ContainsKey('Scope') -or (-not [string]::IsNullOrWhiteSpace( $Scope ) ) ) {
        $splat.Scope = $Scope
    }
    @(
        # Set-Alias -PassThru -Name 'ls'   -Value Get-ChildItem
        Set-Alias @splat -Name 'sc'   -Value Set-Content
        Set-Alias @splat -Name 'cl'   -Value Set-Clipboard # -Force:$true
        Set-Alias @splat -Name 'gcl'  -Value Get-Clipboard # -Force:$true
        Set-Alias @splat -Name 'impo' -Value Import-Module # -Force:$true
        Set-Alias @splat -Name 'Json.From' -Value 'ConvertFrom-Json'
        Set-Alias @splat -Name 'Json'      -Value 'ConvertTo-Json'

        # aggressive aliases include aliases that don't have a prefix of 'mint'
        Set-Alias @splat -Name 'RelPath' -Value 'Mintils\Format-MintilsRelativePath'
        Set-Alias @splat -Name 'Goto' -Value 'Mintils\Push-MintilsLocation'

    )   | Sort-Object
        | Join-String -f "`n - {0}" -op 'Mintils Set-Alias: ' -p {
            $pre, $rest = $_.DisplayName -split ' -> ', 2
            $pre.ToString().padRight(12, ' '), $rest -join ' -> '
        } | Write-Host -fg 'goldenrod'
}

function Find-MintilsAppCommand {
    <#
    .synopsis
        Find the location and versions of Application/CommandInfo/native commands
    .notes
        When using "Gcm -All", this only tests "--version" for the first of each group
    .example
        Mint.Find-AppCommand 'npm', 'node', 'pnpm'
    .example
        # Syntax highlight /w bat
        Find-MintilsAppCommand 'npm', 'node', 'pwsh' -AsOutputType yaml -withoutAll | bat -l yml
    .example
        # basic, with extra sources
        Find-MintilsAppCommand 'npm', 'node', 'pwsh' | ft
    .example
        Find-MintilsAppCommand 'npm', 'node', 'pwsh' -FilterCommandType Application, ExternalScript
    #>
    [Alias('Mint.Find-AppCommand')]
    [OutputType( 'Mintils.AppCommand.Info' )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]] $CommandName,

        # Filter by "Get-Command -CommandTypes"
        [Management.Automation.CommandTypes[]] $FilterCommandType,

        # Also Convert to yaml/json before output. Drops properties that don't serialize cleanly by default.
        # object and default are equal to using -PassThru
        [ArgumentCompletions('yaml', 'json', 'object')]
        [string] $AsOutputType,

        # skips -all
        [Alias('FirstOnly')]
        [switch] $withoutAll
    )
    begin {
        [Collections.Generic.List[Object]] $summary = @()
    }
    process {
        $splat = @{
        }
        if( -not $WithoutAll ) { $splat['All'] = $True }
        if( $null -ne $FilterCommandType ) { $splat.CommandType = $FilterCommandType}

        foreach( $curName in $CommandName ) {
            [int] $orderId = 0
            $cmdInfo = @( Get-Command @splat -Name $curName )

            # for now, only capture version of the first item
            $maybeVer = & $cmdInfo[0] @('--version')
            foreach( $item in $cmdInfo ) {
                $psco = [pscustomobject]@{
                    PSTypeName    = 'Mintils.AppCommand.Info'
                    Name          = $curName
                    Version       = $maybeVer
                    Path          = $Item.Source
                    CommandType   = $item.GetType().Name
                    CommandInfo   = $Item
                    GroupOrder    = $orderId++
                    LastWriteTime = (Get-Item $Item.Source).LastWriteTime
                }
                # signify version is duplicate on the rest
                $maybeVer = ''
                $summary.Add( $psco )
            }
        }
    }
    end {
        switch( $AsOutputType ) {
            'json' {
                $summary
                    | Select-Object -ExcludeProp 'CommandInfo'
                    | ConvertTo-Json -depth 2
                break
             }
            'yaml' {
                $summary
                    | Select-Object -ExcludeProp 'CommandInfo'
                    | YaYaml\ConvertTo-Yaml
                break
             }
            default { $summary }
        }

    }
}

function Find-MintilsSpecialPath {
    <#
    .synopsis
        Sugar that converts paths relative a base dir
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.environment.specialfolderoption
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.environment.getfolderpath
    #>
    [Alias('Mint.Find-SpecialPath')]
    [OutputType( 'Mintils.SpecialPath.Item' )]
    [CmdletBinding()]
    param(
        # [Alias('BasePath')]
        # [Parameter(Mandatory, Position = 0)]
        # $RelativeTo,

        # # Strings / paths to convert
        # [Alias('PSPath', 'FullName', 'InObj')]
        # [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        # [string[]] $Path,

        # [ValidateSet('EnvVar', 'SpecialFolder')]
        # [string[]] $Sources
    )
    process {
        $specialFolderKeys = [enum]::GetValues( [System.Environment+SpecialFolder] )

        foreach ($specialKey in $specialFolderKeys ) {
            <#
                > [enum]::GetNames( [System.Environment+SpecialFolderOption] ) -join ', '
                # out: None, DoNotVerify, Create
            #>
            $resolveSpecial = [Environment]::GetFolderPath( <# SpecialFolder folder #> $specialKey )
            # $resolveSpecial2 = [Environment]::GetFolderPath(
            #     <# SpecialFolder folder #> $specialKey,
            #     <# SpecialFolderOption option; Default: 'None' #> 'None'
            # )
            [pscustomobject]@{
                PSTypeName = 'Mintils.SpecialPath.Item'
                Name       = $specialKey
                Exists     = Test-Path $resolveSpecial
                Type       = 'SpecialFolder'
                Path       = $ResolveSpecial
            }
        }
        $envVarPaths = @( Get-ChildItem env: | Where-Object { Test-Path $_.Value } )

        foreach ( $item in $EnvVarPaths ) {
            [pscustomobject]@{
                PSTypeName = 'Mintils.SpecialPath.Item'
                Name       = $item.Name
                Exists     = Test-Path $Item.Value
                Type       = 'EnvVar'
                Path       = $item.Value
            }
        }
    }

}

# was: requires -Module ClassExplorer

function Find-MintilsTypeName {
    <#
    .SYNOPSIS
        Get [Type] info from the names of types
    .NOTES
    .link
        Mintils\Find-MintilsTypeName
    .link
        Mintils\Get-MintilsTypeHelp
    #>
    [CmdletBinding()]
    [Alias('Mint.Find-TypeName')]
    [OutputType( 'System.Reflection.TypeInfo', 'System.RuntimeType' )]
    param(
        # ex: 'System.TimeZoneInfo'
        [Alias('FromName')]
        [Parameter(Mandatory, ValueFromPipeline )]
            [string] $TypeName,

        # Ignore exceptions thrown by [Type]
            [switch] $WithoutError
    )
    process {

        $maybeType = [Type]::GetType( $TypeName,
            <# bool: throwOnError #> (! $WithoutError ),
            <# bool: ignoreCase #>   $true )

        if( -not $MaybeType ) { # Fallback: exact FullName
            $maybeType = Find-Type -fullname 'TimeZoneInfo' # ex: 'System.TimeZoneInfo'
        }
        if( -not $MaybeType ) { # Fallback: exact Name
            $maybeType = Find-Type -Name $TypeName  # ex: 'TimeZoneInfo'
        }
        if( -not $MaybeType ) { # Fallback: Super wild card
            $maybeType = Find-Type -Fullname "*${TypeName}*"
        }
        if( $MaybeType.count -gt 1 ) {
            'Multiple types found for name: "{0}"' -f $TypeName | Write-Warning
        }
        $maybeType
    }
}

function Format-MintilsRelativePath {
    <#
    .synopsis
        Sugar that converts paths relative a base dir
    #>
    [Alias('Mint.Format-RelativePath')]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        [Alias('BasePath')]
        [Parameter(Mandatory, Position = 0)]
        $RelativeTo,

        # Strings / paths to convert
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]] $Path,

        # Emit an object with path properties, including the raw original path
        [Alias('PassThru')]
        [switch] $AsObject
    )
    process {
        foreach( $item in $Path ) {
            $relPath = [System.IO.Path]::GetRelativePath(
                <# string: relativeTo #> $RelativeTo,
                <# string: path  #>  $Item )

            if( -not $AsObject ) {
                $relPath
                continue
            } else {
                [pscustomobject]@{
                    PSTypeName = 'Mintils.RelativePath'
                    Path       = $relPath
                    Original   = $Item
                    RelativeTo = $RelativeTo
                }
                continue
            }

        }
    }

}



function Get-MintilsTypeHelp {
    <#
    .SYNOPSIS
        Find dotnet docs for a type
    .NOTES
    .link
        Mintils\Find-MintilsTypeName
    .link
        Mintils\Get-MintilsTypeHelp
    #>
    [Alias('Mint.Get-TypeHelp')]
    [Cmdletbinding( DefaultParameterSetName='FromString' )]
    param(
        # [Alias('InObj')]
        # [Parameter( Mandatory, ParameterSetName='FromObject', Position = 0, ValueFromPipeline )]
        # [object] $FromObject,
        # # [type] $FromTypeData

        [Parameter( Mandatory, ParameterSetName='FromString', Position = 0, ValueFromPipeline )]
        [Alias('Name')]
        [string] $TypeName,

        # Open url
        [Alias('Online')]
        [switch] $Open
    )

    begin {
        $PSCmdlet.ParameterSetName | Join-String -f 'using ParamSet: {0}' | Write-Verbose

        function _UrlFromName {
            param( [string] $Name )


            [uri] $url = 'https://learn.microsoft.com/en-us/dotnet/api/{0}?view=net-10.0' -f $Name

            return $Url
        }
    }
    process {

        [string] $shortName = ''
        switch( $PSCmdlet.ParameterSetName ) {
            # 'FromObject' {
            #     # $type = $FromObject.GetType()
            #     break
            # }
            'FromString' {
                $shortName = $TypeName
                break
            }
            default {
                throw "Unhandled ParameterSet: $( $PSCmdlet.ParameterSetName )"
            }
        }

        $shortName | Join-String -op 'Shortname: ' | Write-Verbose

        $url  = _urlFromName -Name $shortName
        $info = [pscustomobject]@{
            PSTypeName = 'Mintils.TypeName.Url'
            Type       = $shortName
            Url        = $Url
        }
        if( $Open ) {
            Start-Process -FilePath ( $Info.Url.ToString() )
        }
        return $Info
    }
}

