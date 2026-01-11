
# or? Where-MintilsAnyMatch?, Find-MintilsAnyRegexMatch
function Where-MintilsAnyMatch {
    <#
    .SYNOPSIS
        Filter objects that match any of a list of patterns
    .description
        Sugar for multiple matches using logical ORs like:

            $obj.Name -match 'require' -or $Obj.Name -match 'file'
    .NOTES
        For rule breaking names, which best matches the intent ?
            Find-, Where-, Filter-, Get-, ...
    .example
        # Short parameter syntax ( implicit strings list )
        > Get-Module | Mint.Where-AnyMatch Name microsoft, readline
    .example
    #>
    [CmdletBinding()]
    # [OutputType( [object] )]
    [Alias(
        'Mint.Where-AnyMatch',
        'Mint.Find-AnyMatch',
        'Mint.AnyMatch', # vs 'AllMatch
        'Mint.MatchAny'
        # 'Mint.Where-AnyRegexMatch',
    )]
    param(
        # [ValidateNotNullOrEmpty()]
        [ArgumentCompletions('Name', 'FullName', 'Source', 'Module' )]
        [Parameter(Mandatory, Position = 0)]
        [string] $PropertyName,

        # Property must match at least one of the patterns
        [Alias(
            'Pattern', 'Regex',
            'MatchesAny',
            'MatchAny', 'RequireAny',
            'AnyOf', 'AnyRegex'
        )]
        [Parameter(Mandatory, Position = 1 )]
        [string[]] $AnyPatterns,

        [AllowNull()]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]] $InputObject
    )
    begin {
        Write-Warning 'WIP: Not all edge cases are resolved for: "Mint.Where-AnyMatch"'
        if( [string]::IsNullOrEmpty( $PropertyName) ) {
            "PropertyName was empty!" | Write-error
        }
    }
    process {
        'AnyMatch Proc: => ' | Write-Debug
        foreach( $Obj in $InputObject ) {
            '   Parent => {0}' -f ( $InputObject )?.GetType().Name ?? '<null>' | Write-Debug
            '   ForItem => {0}' -f ( $Obj )?.GetType().Name ?? '<null>' | Write-Debug
            if( $null -eq $Obj.$PropertyName ) {
                $msg = "   Object.PropertyName is null for Name: '${PropertyName}'! . Type: $( ( $Obj )?.GetType() ?? '<null>' ) "
                    | write-verbose
                continue
            } elseif ( @( $Obj.PSObject.Properties.Name ) -notcontains $PropertyName  ) {
                $msg = "   Obj is missing property: '${PropertyName}'! . Type: $( ( $Obj )?.GetType() ?? '<null>' ) "
                $msg | Write-Verbose
                # $msg | Write-Warning
                continue
            }
            if( _Regex.AnyMatch -Inp $Obj.$PropertyName -AnyRegex $AnyPatterns ) {
                $Obj
            }
        }
    }
}
