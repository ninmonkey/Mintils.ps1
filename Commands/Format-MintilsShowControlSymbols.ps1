function Format-MintilsShowControlSymbols {
   <#
   .synopsis
        Replace ansi escape sequences with safe-to-print control char symbols
    .notes
        Basically map any c0 value by adding 0x2400 to the codepoint: https://www.compart.com/en/unicode/block/U+2400

    .example
        # Inspect what strings pansies/PSStyle are generating safely, by replacing control sequences

        > Pansies\New-text -fg Magenta4 'hi world' | Mint.Format-ControlChars
        > Pansies\New-text -fg Magenta4 'hi world' -bg (Get-Complement 'magenta4') | Mint.Format-ControlChars

            ␛[38;2;139;0;139mhi world␛[39m
            ␛[48;2;0;139;0m␛[38;2;139;0;139mhi world␛[49m␛[39m
    .example
        # 24/n bit syntax

        > [PoshCode.Pansies.RgbColor]::ColorMode = 'ConsoleColor'
        > New-Text -fg 'blue' -Object 'foo' | Mint.Format-ControlChars

        > [PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'
        > New-Text -fg 'blue' -Object 'foo' | Mint.Format-ControlChars

            ␛[94mfoo␛[39m
            ␛[38;2;0;0;255mfoo␛[39m
    .example
        > Mint.Format-ConsoleHyperlink -Name 'offset' -Uri 'https://dax.guide/offset/'
    .example
        > $file = Get-Item 'readme.md'
        > Mint.Format-ConsoleHyperlink -Name $file.Name -Uri ([Uri] $File.FullName )
            # 'readme.md' but LMB opens the full path
    .example
        > $relPath = [IO.Path]::GetRelativePath(
            ( Join-path $file.Directory '..'), $file.FullName )

        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri ([Uri] $File.FullName )
            # 'parentDir\readme.md' that opens full path on click
    .example
        # Open page in your web browser
        > Mint.Format-ConsoleHyperlink -Name 'docs: Offset()' -Uri 'https://dax.guide/offset/'

        # Open windows control panel
        > Mint.Format-ConsoleHyperlink -Name 'control panel: sound' -Uri 'ms-settings:sound'
        > Pansies\New-Hyperlink 'control panel for sound' -Uri 'ms-settings:sound'
    .link
        https://gist.github.com/Jaykul/f46590c0f726dd6a4424ffa614ed1545
    .link
        Pansies\New-Hyperlink
    .link
        Mintils\Format-MintilsConsoleFileUri
    .link
        Mintils\Format-MintilsConsoleHyperlink
    .link
        https://github.com/PoshCode/Pansies/blob/main/Docs/New-Hyperlink.md
   #>
    [Alias(
        'Mint.Format-ControlSymbols',
        'Mint.Format-ControlChars',
        'Mint.ShowControlChars'
    )]
    [CmdletBinding()]
    param(
        [Alias('Content', 'Text')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputText
    )
    process {
        # I'm assuming this isn't super performant, but it's good enough for smallish strings
        foreach( $line in $InputText) {
            ($line).ToString()?.EnumerateRunes() | %{
                if( $_.Value -le 0x1f ) {
                    [Text.Rune]::new( $_.Value + 0x2400 )
                } else { $_ }
            } | Join-String -sep ''
        }
    }
}
