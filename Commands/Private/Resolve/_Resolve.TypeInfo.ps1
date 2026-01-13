function _Resolve.TypeInfo {
    <#
    .synopsis
        [internal] Get Type information
    .Notes
        Warning, you should not pipe, (or enumerate) because some cases like
            <System.Collections.Generic.HashSet[string]>

        cause issues because it allows [ienumerable[string]]

            giving [string[]] or [object[]]
            instead of [hashset[string]]

        Could confirm whether it's a list, then enumerate. However that should occur in a parent function to prevent
        indirect magic from happening. That's why I removed the pipeline
    .DESCRIPTION
    #>
    [OutputType( [type] )]
    [CmdletBinding()]
    param(
        [Alias('Target')]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter( Mandatory )]
        [object] $InputObject
    )
    begin {
    }
    process {
        $Target = $InputObject
        "  => InputObject: $( ( $Target)?.GetType().Name ?? '<null>' ) " | Write-Verbose

        if( $Null -eq $InputObject ) { return }
        if( $Target -is [type] ) { return $Target }
        if( $Target -is [type[]] ) {
            Write-Warning '_Resolve.TypeInfo: $InputObject Is A <type[]> array. Returning as-is' # most  cases normally wouldn't expect to reach here
            return $Target
        } else { return $Target.GetType() }
    }
}
