function Format.RelativePath {
    <#
    .synopsis
        (internal) Always attempts to create a relative path, even if either path does not exist.
    .link
        Mintils/Format-MintilsRelativePath
    .link
        Format.RelativePath
    #>
    [outputType('String')]
    param(
        # relative path. does not have to exist
        [Parameter( position = 0 )]
        [string] $RelativeTo = '.',

        # full path to item or folder. does not have to exist
        [Alias('PSPath', 'FullName' )]
        [Parameter(ValueFromPipeline)]
        [object] $Path
    )

    $maybeRealPath = ( Get-Item $RelativeTo -ea Ignore ) ?? $RelativeTo

    [System.IO.Path]::GetRelativePath(
        <# string: relativeTo #> $maybeRealPath,
        <# string: path #> $_ )
}
