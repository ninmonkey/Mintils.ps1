<#

#>

Describe 'Aggressive Aliases only import if requested' {
    it 'RelPath should not exist by default' {

        # $ModPath = 'mintils'
        $ModPath = Join-Path $PSScriptRoot '../mintils'

        remove-module mintils -Force -ea ignore
        remove-alias 'RelPath' -ea Ignore
        ## (Import-Module $ModPath -Force -Verbose -PassThru).ExportedCommands.Values
        (Import-Module $ModPath -Force <# -Verbose #> -PassThru).Name | Write-host
        # Get-alias 'RelPath' -ea ignore
        # Get-alias 'RelPath' -ea ignore
        {
            # Mint.Enable-DefaultAlias
            Get-alias 'RelPath'
            Get-Item . | relPath -RelativeTo (gi '.')
        } | Should -Throw -Because 'Alias should not automatically import'

    }
    it 'RelPath exists after Enable-DefaultAlias' {

        # $ModPath = 'mintils'
        $ModPath = Join-Path $PSScriptRoot '../mintils'

        remove-module mintils -Force -ea ignore
        remove-alias 'RelPath' -ea Ignore
        ## (Import-Module $ModPath -Force -Verbose -PassThru).ExportedCommands.Values
        (Import-Module $ModPath -Force <# -Verbose #> -PassThru).Name | Write-host
        {
            Mint.Enable-DefaultAlias
            Get-alias 'RelPath'
            Get-Item . | relPath -RelativeTo (gi '.')
        } | Should -Not -Throw -Because 'Alias should not automatically import'

    }
}
