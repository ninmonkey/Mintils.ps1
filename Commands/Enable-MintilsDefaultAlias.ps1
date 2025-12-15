function Enable-MintilsDefaultAlias {
    <#
    .SYNOPSIS
        Load common aliases, only if user opts-in by calling this.
    .NOTES
        Because this is from a module, you might need to use 'Set-alias -Force' and mabye '-Scope Global'
    .example
        # Silently load, ex: for your profile
        > Mint.Enable-Defaultalias -WithoutPSHost
    .example
        # interactively load, and show the summary of new aliases
        Mint.Enable-Defaultalias

        # or as objects
        Mint.Enable-Defaultalias -PassThru
    #>
    [Alias('Mint.Enable-DefaultAlias')]
    [OutputType( [System.Management.Automation.AliasInfo] )]
    [Cmdletbinding()]
    param(
        # required for readonly
        [switch] $Force,

        # Maybe a redundant param
        [ArgumentCompletions('Global', 'Local', 'Script')]
        [string] $Scope = 'Global',

        # Do not write the new names to host
        [Alias('WithoutPSHost')]
        [switch] $Silent,

        # output: [AliasInfo[]]
        [switch] $PassThru
    )

    $splat = @{
        PassThru = $True
    }
    # note: PSBoundParameters does not contain default values
    if( $PSBoundParameters.ContainsKey('Force') ) { $splat.Force = $Force }
    if( $PSBoundParameters.ContainsKey('Scope') -or (-not [string]::IsNullOrWhiteSpace( $Scope ) ) ) {
        $splat.Scope = $Scope
    }
    $items = @(
        # Set-Alias -PassThru -Name 'ls'   -Value Get-ChildItem
        Set-Alias @splat -Name 'Sc'   -Value Set-Content
        Set-Alias @splat -Name 'Cl'   -Value Set-Clipboard # -Force:$true
        Set-Alias @splat -Name 'Gcl'  -Value Get-Clipboard # -Force:$true
        Set-Alias @splat -Name 'impo' -Value Import-Module # -Force:$true
        Set-Alias @splat -Name 'Json' -Value 'Microsoft.PowerShell.Utility\ConvertTo-Json'
        Set-Alias @splat -Name 'Json.From' -Value 'Microsoft.PowerShell.Utility\ConvertFrom-Json'

        # Set-Alias @splat -Name 'Join-String' -Value 'Microsoft.PowerShell.Utility\Join-String' # when you need to prevent clobbering

        # aggressive aliases include aliases that don't have a prefix of 'mint'
        Set-Alias @splat -Name 'RelPath'  -Value 'Mintils\Format-MintilsRelativePath'
        Set-Alias @splat -Name 'Goto'     -Value 'Mintils\Push-MintilsLocation'
        Set-Alias @splat -Name 'Some'     -Value 'Mintils\Select-MintilsObject'
        Set-Alias @splat -Name 'One'      -Value 'Mintils\Select-MintilsObject'
        Set-Alias @splat -Name 'Mint.Fcc' -Value 'Mintils\Format-MintilsShowControlSymbols'
        Set-Alias @splat -Name 'Fcc'      -Value 'Mintils\Format-MintilsShowControlSymbols'
        <#
            # maybe?
            Set-Alias @splat -Name 'Mint.Fcc' -Value 'Mintils\Format-MintilsShow'
            Set-Alias @splat -Name 'fcc'      -Value 'Mintils\Format-MintilsShow'
        #>

    )   | Sort-Object
    if( $PassThru ) {
        $Items
    }
    if( -not $PassThru -and -not $Silent ) {
        $Items
        | Join-String -f "`n - {0}" -op 'Mintils Set-Alias: ' -p {
            $pre, $rest = $_.DisplayName -split ' -> ', 2
            $pre.ToString().padRight(12, ' '), $rest -join ' -> '
        } | Write-Host -fg 'goldenrod'
    }
}
