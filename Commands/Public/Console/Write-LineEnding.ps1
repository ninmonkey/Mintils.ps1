function Write-MintilsLineEnding {
    <#
    .SYNOPSIS
        emits n-number of newlines as one string. Sugar for scripts to write n-number of line endings. ( Without explicit write-host )
    .example
        > "foo"; Mint.Write-NL; "Foo";
        > Mint.Write-NL 2
        > Mint.Write-H1 'foo'; Mint.Write-NL 4; Mint.Write-H1 'bar';
    #>
    [Alias( 'Mint.Write-ConsoleLineEnding', 'Mint.Write-NL' )]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        # Number of lines. Default: 1
        [Parameter(Position = 0)]
        [uint] $NumberOfLines = 1,

        # Override the default line endings: '\n'
        [Parameter(Position = 1)]
        [ArgumentCompletions( '"`n"', '"`r`n"', "'␊'" )]
        [string] $LineEndingString = "`n"
    )

    if( $NumberOfLines -eq 0 ) { return }
    $render = $LineEndingString * $NumberOfLines -join ''
    $render
}
