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

    @(
        # Set-Alias -PassThru -Name 'ls'   -Value Get-ChildItem
        Set-Alias -PassThru -Name 'sc'   -Value Set-Content
        Set-Alias -PassThru -Name 'cl'   -Value Set-Clipboard # -Force:$true
        Set-Alias -PassThru -Name 'gcl'  -Value Get-Clipboard # -Force:$true
        Set-Alias -PassThru -Name 'impo' -Value Import-Module # -Force:$true
        Set-Alias -PassThru -Name 'Json.From' -Value 'ConvertFrom-Json'
        Set-Alias -PassThru -Name 'Json'      -Value 'ConvertTo-Json'
    )   | Sort-Object
        | Join-String -f "`n - {0}" -op 'Mintils Set-Alias: ' -p {
            $pre, $rest = $_.DisplayName -split ' -> ', 2
            $pre.ToString().padRight(12, ' '), $rest -join ' -> '
        } | Write-Host -fg 'goldenrod'
}
