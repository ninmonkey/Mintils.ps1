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

    switch( $PSCmdlet.ParameterSetName ) {
        'ByNameLookup' {
            $splat = @{
                ByName    = $StyleName
                OneOrNone = $OneOrNone
                AsSplatableHash = [bool] $AsSplatableHash
            }
            _Get-TextStyle @splat
        }
        'ByListAll' {
            _Get-TextStyle -ListAll
        }
        default {
            throw "Unhandled ParameterSetName: '$( $PSCmdlet.ParameterSetName )' !"
        }
    }
}
