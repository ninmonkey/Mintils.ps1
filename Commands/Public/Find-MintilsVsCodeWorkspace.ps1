function Find-MintilsVsCodeWorkspace {
    <#
    .synopsis
        Fast find vscode workspaces using 'fd' find for speed
    .NOTES
    the original command was:
        fd -d8 -td '\.git' -H | Get-Item -Force | % Parent
        fd -d3 -td '\.git' -H --absolute-path --base-directory 'H:\data\2025' | Get-Item -Force

    else, fallback to
        gci .. -Recurse -Directory '.git' -Hidden | split-path | gi

    clean: #29: refactor by calling wrapper: 'Invoke-FdFind'
    .EXAMPLE
        # Search current dir
        > Mint.Find-VsCodeWorkspace
    .EXAMPLE
        # Search other dir
        > Mint.Find-VsCodeWorkspace -BaseDirectory 'h:\data\2025'
    .link
        Mintils\Find-MintilsWorkspace
    .link
        Mintils\Find-MintilsGitRepository
    .link
        Mint.Find-VsCodeWorkspace -IncludeVsCodeFolders
        # outputs: .vscode' and '.code-workspace'
    #>
    [Alias(
        'Mint.Find-VsCodeWorkspace',
        'Mint.Find-CodeWorkspace'
    )]
    [OutputType( [System.IO.FileInfo] )]
    [CmdletBinding()]
    param(
        # Base directory to search from, else current.
        # for: fd --base-directory
        [Parameter()]
        [Alias('Name', 'RootDir' )]
        [string] $BaseDirectory = '.',

        # for: fd --max-depth <int>
        [Alias('Depth')]
        [int] $MaxDepth = 5,


        # Search includes for '.vscode' folders
        [Alias('IncludeFolders')]
        [switch] $IncludeVsCodeFolders
    )
    begin {}
    process {}
    end {
        $rootDir = Get-Item -ea 'stop' $BaseDirectory
        "Depth: ${MaxDepth}, Extension: 'code-workspace', Root: ${RootDir}" | Write-Verbose
        $pathSeparator = '/'
        fd --max-depth $MaxDepth --type 'file' -e 'code-workspace' --absolute-path --path-separator $pathSeparator --base-directory $rootDir
            | Get-Item -ea 'continue'

        if( $IncludeVscodeFolders ) {
            fd --max-depth $MaxDepth --type 'directory' '\.vscode' --absolute-path --path-separator $pathSeparator --base-directory $rootDir --hidden
                | Get-Item -ea 'continue'
        }
    }
}
