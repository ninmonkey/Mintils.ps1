
$script:__cache_Get_TextStyle = @{}

function Get-MintilsTextStyle {
    <#
    .SYNOPSIS
        Get text colors by style name
    .example
        # Show all defined styles
        > Mint.Get-TextStyle -ListAll | ft
    .example
        # Get matching <Name> or first match using -like <Name>
        > Mint.Get-TextStyle Gray
    .example
        # Get strict matches only
        > Mint.Get-TextStyle Gray -ExactOnly -Verbose

        VERBOSE: ambigous styles found!: Gray.Bright.BoldContrast, Gray.Dark.LowContrast
        Exception: Strict match Name: 'Gray' failed, found 2 matches!
    #>
    [Alias(
        'Mint.Get-TextStyle'
        # 'Mint.TextStyle'
    )]
    [CmdletBinding()]
    param(
        # Select first matching pattern
        [ArgumentCompleter({ _Completer.Get-TextStyle @args })]
        [Parameter(Mandatory, ParameterSetName='ByNameLookup', Position = 0 )]
        [Alias('Name', 'ByName', 'Theme')]
        [string] $StyleName,

        # only select one exact match
        [Parameter(ParameterSetName='ByNameLookup')]
        [Alias('Strict', 'ExactOnly')]
        [switch] $OneOrNone,

        [Parameter(Mandatory, ParameterSetName='ByListAll')]
        [Alias('All', 'List')]
        [switch] $ListAll,

         # output contains only Fg and Bg to make splatting simpler
        [Parameter( ParameterSetName = 'ByNameLookup' )]
        [Alias('OutputAsHash','AsHash' )]
        [switch] $AsSplatableHash
    )
    $CacheLookup = $script:__cache_Get_TextStyle

    switch( $PSCmdlet.ParameterSetName ) {
        'ByNameLookup' {
            $splat = @{
                ByName    = $StyleName
                OneOrNone = $OneOrNone
                AsSplatableHash = [bool] $AsSplatableHash
            }

            if( $AsSplatableHash -and $CacheLookup.Contains( $StyleName ) ) {
                return $CacheLookup[ $StyleName ]
            }
            $found = _Get-TextStyle @splat
            $cacheLookup[ $StyleName ] = $found

            return $found
        }
        'ByListAll' {
            _Get-TextStyle -ListAll
        }
        default {
            throw "Unhandled ParameterSetName: '$( $PSCmdlet.ParameterSetName )' !"
        }
    }
}
