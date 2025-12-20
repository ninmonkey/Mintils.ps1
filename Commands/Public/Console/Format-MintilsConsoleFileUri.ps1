function Format-MintilsConsoleFileUri {
    <#
    .synopsis
        Converts paths into a console clickable file uris ( Try ctrl+LMB )
    .description
        Writes filepath to terminal using escape sequances for clickable filepath uris

        renders as relativepath, but resolves as full path

        example output:
            ␛]8;;c:\temp\readme.md␛\readme.md␛]8;;␛\

        an OSC Sequence starts with:
            '␛]'
        and ends with
            '␛\'
    .notes
        Check how support varies using the '␇' vs '␛\' syntax
    .example
        # If you have 'c:\pwsh\examples\example.ps1'

        > pushd 'c:\pwsh\examples'
        > Mint.Format-ConsoleFileUri -InObj ( gci . *.ps1 )
            # out: 'example.ps1'

        > Mint.Format-ConsoleFileUri -InObj ( gci . *.ps1 ) -RelativeTo (gi ..)
            # out: 'examples\example.ps1'
    .example
        > Mint.Format-ConsoleHyperlink -Name 'readme' -Uri ([uri] 'c:\temp\readme.md' ) | Mint.Format-ControlSymbols
        # out:

            ␛]8;;file:///c:/temp/readme.md␇readme␛]8;;␇
    .example
        > $relPath = [IO.Path]::GetRelativePath( ( Join-path $file.Directory '..'),  $file.FullName )
        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri $File.FullName

            readme.md

        > Mint.Format-ConsoleHyperlink -name 'readme' -Uri 'c:\foo\readme.md' | Mint.Format-ControlChars

            ␛]8;;c:\foo\readme.md␇readme␛]8;;␇

        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri $File.FullName | Mint.Format-ControlChars
   .link
        Mintils\Format-MintilsConsoleHyperlink
   .link
        Mintils\Format-MintilsConsoleFileUri
    .link
        Pansies\New-Hyperlink
    .link
        https://en.wikipedia.org/wiki/ANSI_escape_code
    #>
    [Alias('Mint.Format-ConsoleFileUri', 'Mint.ConsoleFileUri')]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        [Alias('BasePath')]
        [Parameter(Position = 0)]
        $RelativeTo = '.',

        # Strings / paths to convert
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]] $Path
    )
    begin {
        $relativeRoot = Get-Item -ea 'stop' $RelativeTo
    }
    process {
        foreach( $item in $Path ) {
            $item = Get-Item $item -ea 'stop'
            $relPath = [IO.Path]::GetRelativePath( <# relativeTo #> $relativeRoot, <# path #> $item.FullName )
            [uri] $uri = $item.FullName

            # original gist had used: "`e]8;;${uri}`e\${relPath}`e]8;;`e\"
            Format-MintilsConsoleHyperlink -InputObject $relPath -Uri $Uri
        }
    }
}
