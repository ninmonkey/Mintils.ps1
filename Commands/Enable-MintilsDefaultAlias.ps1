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
