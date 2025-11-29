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
