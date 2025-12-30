function _Format-FullNameWithLineNumbers {
    <#
    .SYNOPSIS
        formats optional numbers in the format: path[:lineNumber[:columnNumber]]
    .description
        Future could extend this to use the relative/reverse path syntax too
    .example
        > _Format-FulLNameWithLineNumber -Path 'foo.ps1'
        > _Format-FulLNameWithLineNumber -Path 'foo.ps1' -Line 234
        > _Format-FulLNameWithLineNumber -Path 'foo.ps1' -Line 234 -Col 23

        # outputs:
            foo.ps1
            foo.ps1:234
            foo.ps1:234:23
    #>
    [OutputType( [string] )]
    param(
        [Alias('FullName', 'File', 'PSPath' )]
        [object] $Path,

        [Alias('LineNumber')]
        [int] $StartLineNumber,

        [Alias('ColNumber')]
        [int] $StartColumnNumber

        # [ValidateScript({throw 'nyi'})]
            # [switch] $JustToLastLine,

        # [ValidateScript({throw 'nyi'})]
            # [switch] $UseReverseIndex
    )
    $Item = Get-Item $Path -ea ignore
    if( $null -eq $Path -or -not $Item ) {
        return
    }

    # allows it to render for not-yet-existing-paths
    $fullName = $Item.FullName ? $Item.FullName : $Path

    [string] $renderText = @(
        $fullName
        if( $StartLineNumber ) { ':{0}' -f $StartLineNumber }
        if( $StartLineNumber -and $StartColumnNumber ) { ':{0}' -f $StartColumnNumber }
    ) -join ''

    if( -not (Test-Path $Path )) { }
    return $renderText
}
