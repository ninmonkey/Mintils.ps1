function _Regex.AnyMatch {
    <#
    .synopsis
        [internal] regex tests return a single bool
    .DESCRIPTION
        related: _Is.Null, _Is.Empty, _Is.Blank
    .EXAMPLE
        > _Regex.AnyMatch 'cat 324' -AnyOf 'dog', '\d'
            # true
    #>
    # or? _Regex.Match-Any
    [OutputType( [bool] )]
    [CmdletBinding()]
    param(
        # Target to match against, coerces to a string
        [Alias( 'Text', 'Content', 'Obj', 'Target' )]
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, Position = 0 )] # ValueFromPipeline )]
        [object] $InputObject,

        # List of regexes
        [Parameter( Mandatory , Position = 1 )]
        [Alias('Regex', 'Pattern', 'AnyMatch', 'AnyOf' )]
        [string[]] $AnyRegex
    )
    process {
        foreach ( $regex in $AnyRegex ) {
            if ( $InputObject -match $regex ) { return $true }
        }
        return $false
    }
}
