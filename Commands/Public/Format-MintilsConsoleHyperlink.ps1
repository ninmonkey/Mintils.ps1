function Format-MintilsConsoleHyperlink {
   <#
   .synopsis
        A more generic Format-MintilsConsoleFileUri, without requiring it to be a filepath
    .notes

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
    .example
        > Mint.Format-ConsoleHyperlink -Name 'control panel: sound' -Uri 'ms-settings:sound' | Mint.ShowControlChars

            ␛]8;;ms-settings:sound␇control panel: sound␛]8;;␇
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
    [Alias( 'Mint.Format-ConsoleHyperlink', 'Mint.ConsoleHyperlink')]
    [CmdletBinding()]
    param(
        # The Uri the hyperlink should point to
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Uri,

        # The text of the hyperlink (if not specified, defaults to the URI)
        [ValidateNotNullOrEmpty()]
        [Alias('Text', 'Name' )]
        [Parameter(ValueFromRemainingArguments)]
        [String] $InputObject = $Uri
    )
    $8 = [char] 27 + "]8;;"
    "${8}{0}`a{1}${8}`a" -f ( $Uri, $InputObject )
}
