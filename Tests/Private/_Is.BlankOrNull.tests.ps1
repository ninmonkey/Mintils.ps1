BeforeAll {
    $error.clear()
    $PSStyle.OutputRendering = 'ansi'

    $Module = Join-path $PSScriptRoot '../../Mintils.psd1'
    @(
        Import-Module $Module -Force -PassThru
    )
        | Join-String -p { $_.Name, $_.Version -join ': ' } -op "importing:...`n" -f "`n - {0}"
        | Pansies\Write-Host -fore 'goldenrod'
}

# This is verbose, but the edge cases should be defined
Describe "Test: IsBlank" -tag 'internal' {
    Context 'Is.Null' {
        It 'from Param: <value> is <expected>' -ForEach @(
            @{ Value = $null ; Expected = $true }
            @{ Value = ''    ; Expected = $false }
            @{ Value = ' '   ; Expected = $false }
        ) {
            InModuleScope 'Mintils' -Parameters $_ {
                _Is.Null $Value   | Should -BeExactly $Expected
            }
        }
        It 'from Pipeline: <value> is <expected>' -ForEach @(
            @{ Value = $null ; Expected = $true }
            @{ Value = ''    ; Expected = $false }
            @{ Value = ' '   ; Expected = $false }
        ) {
            InModuleScope 'Mintils' -Parameters $_ {
                $value | _Is.Null | Should -BeExactly $Expected
            }
        }
    }
    Context 'Is.Blank' {
        It 'from Param: <value> is <expected>' -ForEach @(
            @{ Value = $null   ; Expected = $true }
            @{ Value = ''      ; Expected = $true }
            @{ Value = ' '     ; Expected = $true }
            @{ Value = ' foo'  ; Expected = $false }
        ) {
            InModuleScope 'Mintils' -Parameters $_  -ea continue {
                # $ErrorActionPreference = 'break'
                _Is.Blank $Value   | Should -BeExactly $Expected -ea continue
            }
        }
        It 'from Pipeline: <value> is <expected>' -ForEach @(
            @{ Value = $null   ; Expected = $true }
            @{ Value = ''      ; Expected = $true }
            @{ Value = ' '     ; Expected = $true }
            @{ Value = ' foo'  ; Expected = $false }
        ) {
            InModuleScope 'Mintils' -Parameters $_ {
                $value | _Is.Blank | Should -BeExactly $Expected
            }
        }
    }
    Context 'Is.Empty' {
        It 'from Param: <value> is <expected>' -ForEach @(
            @{ Value = $null   ; Expected = $true }
            @{ Value = ''      ; Expected = $true }
            @{ Value = ' '     ; Expected = $false }
            @{ Value = ' foo'  ; Expected = $false }
            @{ Value = @()     ; Expected = $true }
        ) {
            InModuleScope 'Mintils' -Parameters $_  -ea continue {
                # $ErrorActionPreference = 'break'
                _Is.Empty $Value   | Should -BeExactly $Expected -ea continue
            }
        }
        It 'from Pipeline: <value> is <expected>' -ForEach @(
            @{ Value = $null   ; Expected = $true }
            @{ Value = ''      ; Expected = $true }
            @{ Value = ' '     ; Expected = $false }
            @{ Value = ' foo'  ; Expected = $false }
            # @{ Value = ,@()     ; Expected = $true }
        ) {
            InModuleScope 'Mintils' -Parameters $_ {
                # $ErrorActionPreference = 'break'
                $value | _Is.Empty | Should -BeExactly $Expected
            }
        }
    }
}
