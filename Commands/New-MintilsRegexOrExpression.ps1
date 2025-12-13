function New-MintilsRegexOrExpression {
   <#
   .synopsis
        Create a regex that combines a list into an OR. As patterns or as literals.
    .example
        > Mint.New-RegexOr -InputObject ('a'..'c' + 3.14 + 0..2 )
            (a|b|c|3.14|0|1|2)

        > Mint.New-RegexOr -InputObject ('a'..'c' + 3.14 + 0..2 ) -EscapeRegex
            (a|b|c|3\.14|0|1|2)
    .example
    > '[3', 'z' | Mint.New-RegexOr
    > '[3', 'z' | Mint.New-RegexOr -AsRegexLiteral
        ([3|z)
        (\[3|z)
    .example
    # Build a pattern for file extensions:
    > gci . -Recurse -File
        | % Extension | Sort-Object -Unique
        | Mint.New-RegexOr -AsRegexLiteral -FullMatch

    # out:
        ^(\.json|\.pbip|\.pbir|\.pbism|\.pbix|\.ps1)$
   #>
    [Alias( 'Mint.New-RegexOr')]
    [CmdletBinding()]
    param(
        [Alias('Pattern', 'Regex')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputObject,

        # Escape all patterns before joining them
        [Alias('AsRegexLiteral', 'AsLiteral')]
        [switch] $EscapeRegex,

        # Default allows partial matches. This forces the full string to match the or codintion
        [Parameter()]
        [switch] $FullMatch
    )
    begin {
        [Collections.Generic.List[string]] $segments = @()

        $final_fstr = -not $FullMatch ? '({0})' : '^({0})$'
    }
    process {
        $segments.AddRange( $InputObject )
    }
    end {

        $segments
            | Join-String -sep '|' -Prop {
                $EscapeRegex ? ([Regex]::Escape( $_ )) : $_ }
            | Join-String -f $final_fstr
            # or for a full match

        # foreach( $text in $Segments ) {
        #     [regex]::Escape( $text )
        # }
        # if( $EscapeRegex ) {
        # }
        # if( $InputObject.count -gt 0 ) {
        #     if( )
        # }
        # foreach( $item in $InputObject ) {
        #     $EscapeRegex ? ([Regex]::Escape( $item )) : $Item
        # }
        # if($EscapeRegex) {

        # }

        # @(foreach( $item in $InputObject ) {
        # $false ? ([Regex]::Escape( $item )) : $Item
        # }) | Join-String -sep '|'
        # | Join-String -f '^({0})$'

        # $InputObject
        # | Join-String -p {

        # }

    }
}
