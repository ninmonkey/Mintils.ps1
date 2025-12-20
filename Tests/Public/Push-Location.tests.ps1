<#

#>
BeforeAll {
    $Module = Join-path $PSScriptRoot '../../Mintils.psd1'
    @(
        Import-Module $Module -Force -PassThru
    )
        | Join-String -p { $_.Name, $_.Version -join ': ' } -op "importing:..." -f "`n - {0}"
        | Pansies\Write-Host -fore 'goldenrod'

     # Get-Emoji.Tests.ps1 - .Tests.ps1 + .ps1 = Get-Emoji.ps1
    # . $PSScriptRoot/Get-Emoji.ps1 # or
    # . $PSCommandPath.Replace('.Tests.ps1','.ps1')
}

Describe "Mint.Push-Location" {
    Context "Resolves From Type" {
        BeforeAll {
            $OriginalPath = Get-Location # will this test mutate user's scope? will this path be in scope on afterAll ? Or move to each test?
            # $null = Push-Location $PSScriptRoot
            # Pushd -StackName 'pester.push-location' -Path
        }
        It "String" {
            $expected = $Profile.CurrentUserAllHosts | Get-Item | % FullName
            $found    = $Profile.CurrentUserAllHosts | Push-MintilsLocation -PassThru

            $found.FullName
                | Should -be $Expected -Because 'Expected path resolution'

            $found
                | Should -BeOfType ([System.IO.FileInfo]) -because 'Script.ps1 has a filepath'
        }
        It "FunctionInfo" {
            $expected = (Get-Module mintils).Path | Get-Item | ForEach-Object FullName
            $found    = Get-Command Push-MintilsLocation | Push-MintilsLocation -PassThru

            $found
                | Should -be $Expected

            $found
                | Should -BeOfType ([System.IO.FileInfo]) -because 'Functions have filepaths'
        }
        AfterAll {
            $Null = Push-Location $OriginalPath
        }
    }
}
