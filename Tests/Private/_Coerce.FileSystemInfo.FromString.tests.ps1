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

Describe "Mint._Coerce.FileSystemInfo.FromString" {
    It 'Type Should not Throw' {
        $examples = @(
            'c:\foo\bar'
            (gi .)
            gi $PROFILE
            $PROFILE
            '.\temp.log'
            'fake.log'
        )
        { $examples | _Coerce.FileSystemInfo.FromString }
            | Should -Not -Throw 'Because Examples Should Coerce'
        { _Coerce.FileSystemInfo.FromString -InputObject $examples }
            | Should -Not -Throw 'Because Examples Should Coerce'
    }
    # It "Converts 'String' to 'IO.DirectoryInfo'" {
    #     $true | Should -be $True -because 'empty test'
    # }
    # It "Converts 'String' to 'IO.FileInfo'" {
    #     $true | Should -be $True -because 'empty test'
    # }
    # It "Converts 'String' to 'Get-Item' instance" {
    #     $true | Should -be $True -because 'empty test'
    # }
}
