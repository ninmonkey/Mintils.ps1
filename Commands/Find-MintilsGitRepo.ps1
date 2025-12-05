function Find-MintilsGitRepository {
    <#
    .synopsis
        Fast find git repository folders. uses 'fd' find for speed'
    .NOTES
    the original command was:
        fd -d8 -td '\.git' -H | Get-Item -Force | % Parent
        fd -d3 -td '\.git' -H --absolute-path --base-directory 'H:\data\2025' | Get-Item -Force

    else, fallback to
        gci .. -Recurse -Directory '.git' -Hidden | split-path | gi
    .EXAMPLE
        # Search current dir
        > Mint.Find-GitRepo
    .EXAMPLE
        # Search other dir
        > Mint.Find-GitRepo -BaseDirectory 'h:\data\2025'
    #>
    [Alias(
        'Mint.Find-GetRepository',
        'Mint.Find-GitRepo'
    )]
    [OutputType( [System.IO.DirectoryInfo] )]
    [CmdletBinding()]
    param(
        # Base directory to search from, else current.
        # for: fd --base-directory
        [Parameter()]
        [Alias('Name', 'RootDir' )]
        [string] $BaseDirectory = '.',

        # for: fd --max-depth <int>
        [Alias('Depth')]
        [int] $MaxDepth = 5
    )
    begin {}
    process {}
    end {
        $rootDir = Get-Item -ea stop $baseDirectory
        $pattern = '^\.git$'
        "Depth: ${MaxDepth}, Pattern: ${pattern}, Root: ${RootDir}" | Write-Verbose
        $pathSeparator = '/'

        fd --max-depth $MaxDepth --type 'directory' $Pattern --hidden --absolute-path --path-separator $pathSeparator --base-directory $rootDir
            | Get-Item -Force -ea Continue
            | % Parent
    }
}
