function _Get-TextStyle {
    <#
    .SYNOPSIS
        [internal] lookup text colors by semantic names
    .example
    #>
    [CmdletBinding()]
    param(
        # Select first matching pattern
        [Parameter(Mandatory, ParameterSetName='ByNameLookup', Position = 0)]
        [Alias('Name')]
        [string] $ByName,

        # only select one exact match
        [Parameter(ParameterSetName='ByNameLookup')]
        [Alias('Strict', 'ExactOnly')]
        [switch] $OneOrNone,

        [Parameter(Mandatory, ParameterSetName='ByListAll')]
        [Alias('All', 'List')]
        [switch] $ListAll
    )

    $styles = @(
        <# core basic colors #>
        @{
            Name = 'DimDark'
            SemanticName = 'GeneralText.LowContrast'
            Description = @(
                'Dim general text. Grayish.',
                'Fg: Gray, Bg: dark gray/black.',
                'Dark but is not bold / lower contrast' ) -join ' '
            Fg = 'gray40'
            Bg = 'gray15'
            Category = 'Core'
        }
        @{
            Name = 'Dim'
            SemanticName = 'GeneralText'
            Description = @(
                'Dim general text. Grayish.',
                'Default style for "Write-Information"'
                'Fg: Gray, Bg: Gray.',
                'Not bold / lower contrast' ) -join ' '
            Fg = 'gray70'
            Bg = 'gray30'
            Category = 'Core'
        }
        @{
            Name = 'DimInfo'
            SemanticName = 'DimInfo.NoBg'
            Description = 'Dim Information text. Ex: light pink/purple. Low contrast'
            Fg = '#e9addc'
            Bg = $null
            Category = 'Core'
        }
        @{
            Name = 'DimWarning'
            SemanticName = 'Warning.NoBg'
            Description = @( 'Dim warning text.', 'Low severity warnings.', 'Fg: yellow, Bg: null.' ) -join ' '
            Fg = '#ebcb8b'
            Bg = $Null
            Category = 'Core'
        }
        @{
            Name = 'DimGood'
            SemanticName = 'Good.NoBg'
            Description = @( 'Good text.', 'Fg: Light Green, Bg: null.' ) -join ' '
            Fg = '#a2bb91'
            Bg = $Null
            Category = 'Core'
        }
        <# superfluous section #>

        @{
            Name = 'Gray.Dark.LowContrast'
            SemanticName = 'Gray.Dim.Dark.LowContrast'
            Description = @(
                'Dim gray text with BG',
                'Fg: Gray, Bg: Gray.',
                'Low contrast.' ) -join ' '
            Fg = 'gray30'
            Bg = 'gray20'
            Category = 'Extra'
        }
        @{
            Name = 'Gray.Bright.BoldContrast'
            SemanticName = 'Gray.Bright.BoldContrast'
            Description = @(
                'Bold Light Gray text with BG',
                'Fg: BrightGray, Bg: Gray.',
                'High contrast.' ) -join ' '
            Fg = 'gray80'
            Bg = 'gray30'
            Category = 'Extra'
        }
    ).forEach( [pscustomobject] )
        | Sort-Object -Prop Category, Name, SemanticName, Description # or: Name, Description
        | Select-Object -Prop 'Name', 'SemanticName', 'Fg', 'Bg', 'Category', 'Description' # View / FormatData order

    switch( $PSCmdlet.ParameterSetName ) {
        'ByNameLookup' {
            # if strict, find exact or throw
            if( $OneOrNone ) {
                $found = $styles | ? -Prop Name -eq $ByName
                if( $found.count -eq 0 ) {
                    $found = $styles | ? -Prop Name -like "*${ByName}*"
                }
                if( $found.Count -eq 1 ) { return $found }
                else {
                    $found | Join-String -p Name -sep ', ' -op 'ambigous styles found!: ' | Write-Verbose
                    throw ("Strict match Name: '${ByName}' failed, found $( $found.count ) matches! ")
                }
            }
            # else match on first
            $found = $styles
                | Where-Object { $_.Name -like "*${ByName}*" }
                | Select-Object -First 1

            if( -not $found ) {
                throw "Style name '$ByName' not found. Available styles: " +
                    ( $styles.Name -join ', ' )
            }
            $found | Join-String -f 'TextStyle found: "{0}"' -p Name | Write-Verbose
            return $found
        }
        'ByListAll' {
            return $styles
            break
        }
        default {
            throw "Unhandled ParameterSetName: '$( $PSCmdlet.ParameterSetName )' !"
        }
    }
}
