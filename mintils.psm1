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
        [string] $Scope
    )

    $splat = @{}
    if( $PSBoundParameters.ContainsKey('Force') ) { $splat.Force = $Force }
    if( $PSBoundParameters.ContainsKey('Scope') ) { $splat.Scope = $Scope }

    $splat = @{ PassThru = $true }
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



