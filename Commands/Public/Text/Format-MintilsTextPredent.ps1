function Format-MintilsTextPredent {
    <#
    .synopsis
        Indent lines using depth, or number of characters
    .example
        # To Visualize the padding added
        Pwsh> 0..2 | Mint.Format-TextPredent -PrefixString ␠ -Depth 2 -TabSize 2

        ␠␠␠␠0
        ␠␠␠␠1
        ␠␠␠␠2

        Pwsh> 0..2 | Mint.Format-TextPredent -PrefixString ␠ -Depth

        ␠␠␠␠␠␠␠␠0
        ␠␠␠␠␠␠␠␠1
        ␠␠␠␠␠␠␠␠2

    .EXAMPLE
    # Summarizing using depth

    'Datetime'

    'Properties' | Mint.Format-TextPredent
    (Get-Date | Fime -MemberType Property).Name
        | Sort-Object -Unique
        | Mint.Format-TextPredent -Depth 2

    'Methods' | Mint.Format-TextPredent
    (Get-Date | Fime -MemberType Method).Name
        | Sort-object -Unique
        | Mint.Format-TextPredent -Depth 2
    #>
    [Alias(
        'Mint.Format-TextPredent',
        'Mint.Text-Predent' )]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        # lines of input
        [Alias('Content', 'Text', 'Lines')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputText,

        # What level to indent as. The Default is 1 = 4 spaces, 2 = 8 spaces, etc.

        [Parameter( Position = 0 )]
        [ArgumentCompletions( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]
        [Alias('Level')]
        [int] $Depth = 1,

        # One $Depth is ( $Str * $TabSize ). ie: 2, 4, etc.
        [ArgumentCompletions( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]
        [int] $TabSize = 4,

        # what gets multiplied. The default is a ' '
        [ArgumentCompletions( "' '", "`u{2420}", '"`t"', "' - '")]
        [string] $PrefixString = ' ',

        # When multiple are passed
        [string] $Separator = "`n"

    )
    begin {
        $Prefix = $PrefixString * ($Depth * $TabSize) -join ''
        [Collections.Generic.List[string]] $lines = @()
        # $found_count = 0
        # if( $PSCmdlet.MyInvocation.InvocationName -in ('Mint.RandomOne' ) ) {
        #     $MaxCount = 1
        # }
    }
    process {
        $lines.AddRange( [string[]] $InputText )
    }
    end {
        $lines | Join-String -f "${Prefix}{0}" -Sep $Separator
    }
}
