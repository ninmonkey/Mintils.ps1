
function New-MintilsSafeFilename {
    <#
    .SYNOPSIS
        Generate a "safe" filename using a template with the current time. ( Default is to the level of seconds )
    .NOTES
        Uses universal sortable, aka: 'u'
    .example
        > mint.New-SafeFilename
            # 2025-08-25_08-31-57Z

        > mint.New-SafeFilename -TemplateString 'screenshot-{0}.png'
            # screenshot-2025-08-25_08-31-57Z.png

        > mint.New-SafeFilename '{0}-main.log'
            # 2025-08-25_08-31-57Z-main.log

        > mint.New-SafeFilename 'AutoExport-{0}.xlsx'
            # AutoExport-2025-08-25_08-31-57Z.xlsx
    .link
        https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings#table-of-format-specifiers
    #>
    [Alias(
        'Mint.New-SafeFilename' )]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # Set format string used by "-f" format
        [Parameter(Position = 0)]
        [ArgumentCompletions(
            "'{0}.log'",
            "'{0}'",
            "'AutoExport-{0}.xlsx'",
            "'main-{0}.log'",
            "'{0}-main.log'",
            "'screenshot-{0}.png'"
        )]
        [string] $TemplateString = '{0}',

        [Alias('AsResolution')]
        [ValidateSet( 'Seconds', 'Milliseconds', 'Nanoseconds', 'Microseconds' )]
        [string] $Resolution = 'Seconds'
    )
    $fStr = switch( $Resolution ) {
        'Seconds' { 'u' }
        default { throw "Missing Template defintion for: ${Resolution}"}
    }
    $render = $TemplateString -f @(
        [datetime]::Now.ToString( $fStr ) -replace '[ ]+', '_' -replace ':', '-' )

    "Generated: '${render}' from template: ${TemplateString}" | Write-Verbose
    $render
}
