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

Describe "Mint.New-HashSet.FileSystemInfo" {
    Context "Duplicates in Env:PATH" {
        It 'Parameter Removes Duplicates' {
            $collection  = @( $Env:PATH -split [IO.Path]::PathSeparator  -as [IO.DirectoryInfo[]] )
            $with_dupes = @(
                $collection
                $collection | Get-Random -Count 6
            ) # original has dupes: ( $with_dupes | group | ? count -gt 1  ).count -gt 0
            $set = Mint.New-hashset.FileInfo -Collection $with_dupes

            ( $set | Group-Object fullname | ? count -gt 1  ).count
                | Should -Be 0 -Because 'Failure means duplicates still exist'
        }
        It 'All Caps Duplicate is not added' {
            $mixed_case = 'c:\FOO\BAR','c:\foo\bar' -as [IO.DirectoryInfo[]]
            ( $mix_set = Mint.New-HashSet.FileInfo -Collection $mixed_case )
            $mix_set.count | Should -BeExactly 1 -Because 'Same path with alternate case'
            $mix_set.Add( $mixed_case[0] ) | should -be $false -Because 'Already exists with a different case'
            $mix_set.Add( $mixed_case[1] ) | should -be $false -Because 'Already exists with a different case'
        }
    }
    Context "Returns Instance" {
        It "With Collection" {
            $collection = @( Get-Item '.' )
            $hset = Mint.New-HashSet.FileInfo -Collection $Collection

            $null -eq $hset
            | Should -be $false -because 'Instance should always be created'
        }
        It "Empty Collection" {
            $hset = Mint.New-HashSet.FileInfo

            $null -eq $hset
            | Should -be $false -because 'Instance should always be created'
        }
    }
    Context "Ctor Types" {
        Context "From 'IO.FileInfo'" {
            it '"FileInfo" Does not Throw' {
                # future: clean: refactor as datadriven tests
                $collection = 'c:\data.log', 'c:\foo\file.ps1' -as  [IO.FileInfo[]]
                { Mint.New-HashSet.FileInfo -Collection $collection }
                    | Should -Not -Throw -because 'valid FileInfo'
            }
            it '"FileInfo" Returns Correct Count' {
                # future: clean: refactor as datadriven tests
                $collection = 'c:\data.log', 'c:\foo\file.ps1' -as  [IO.FileInfo[]]

                $set = Mint.New-HashSet.FileInfo -Collection $collection
                $set.count
                    | Should -BeExactly 2 -Because 'Manual example with distinct names'
            }
        }
        Context "From 'IO.DirectoryInfo'" {
            it '"DirectoryInfo" Does not Throw' {
                # future: clean: refactor as datadriven tests
                $collection = 'c:\logs', 'c:\logs\2' -as  [IO.DirectoryInfo[]]
                { Mint.New-HashSet.FileInfo -Collection $collection }
                    | Should -Not -Throw -because 'valid [DirectoryInfo]'
            }
            it '"DirectoryInfo" Returns Correct Count' {
                # future: clean: refactor as datadriven tests
                $collection = 'c:\logs', 'c:\logs\2' -as  [IO.DirectoryInfo[]]

                $set = Mint.New-HashSet.FileInfo -Collection $collection
                $set.count
                    | Should -BeExactly 2 -Because 'Manual example with distinct names'
            }
        }
        It "From 'String'" {
            it '"String" Does not Throw' {
                # future: clean: refactor as datadriven tests
                $collection = 'c:\logs', 'c:\foo\logs', 'c:\FOO\LOGS'
                { Mint.New-HashSet.FileInfo -Collection $collection }
                    | Should -Not -Throw -because 'valid [String]'
            }
            it '"String" Returns Correct Count' {
                # future: clean: refactor as datadriven tests
                $collection = 'c:\logs', 'c:\foo\logs', 'c:\FOO\LOGS'

                $set = Mint.New-HashSet.FileInfo -Collection $collection
                $set.count
                    | Should -BeExactly 2 -Because 'Manual example of 2 distinct case-insensitive names'
            }
        }
    }
}
