<#

tests
    - exclude whjitespcace
    - exclude null
    -case sensitive
    no sort
#>


<#
    Simple Pester template
#>
BeforeAll {

    $Module = Join-path $PSScriptRoot '../../Mintils.psd1'
    @(
        Import-Module $Module -Force -PassThru
    )
        | Join-String -p { $_.Name, $_.Version -join ': ' } -op "importing:...`n" -f "`n - {0}"
        | Pansies\Write-Host -fore 'goldenrod'

     # Get-Emoji.Tests.ps1 - .Tests.ps1 + .ps1 = Get-Emoji.ps1
    # . $PSScriptRoot/Get-Emoji.ps1 # or
    # . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Get-UniquePropertyValue" {
    Context "Get Examples" {
        BeforeAll {
            $data = [Ordered]@{}
            $data.all = Get-Alias
            $data.withoutSource = $data.all | ? -Not Source
            $data.onlySource    = $data.all | ? Source
        }
        It "WIP" {
            $count_all      = ( Get-Alias | % Source ).count
            $without_source = Get-alias | ? -not Source | Select -first 2

        }
    }
}
