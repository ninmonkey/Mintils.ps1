function Format-MintilsSubStr {
    <#
    .SYNOPSIS
        Always returns a string, empty if missing.
    #>
    [Alias(
        'Mint.Format-SubStr',
        'Mint.Text.SubStr'
    )]
    [OutputType([String])]
    [CmdletBinding()]
    param(
        [Alias('Text', 'Content', 'Str')]
        [Parameter( ValueFromPipeline, Position = 0 )]
        [string] $InputObject,

        [Alias('Length')]
        [Parameter( Position = 1 )]
        [int] $MaxLength = 80,

        [ValidateScript({throw 'nyi. add to bounds checking when added'})]
        [Alias('Index', 'Offset')]
        [int] $StartIndex = 0
    )
    begin {
        [string] $Suffix = '…'
    }
    process {
        [string] $Str = $InputObject
        if( [string]::IsNullOrEmpty( $InputObject ) ) { return '' }

        $StrLen = $Str.Length
        $TruncLen = [math]::Min( $StrLen, $MaxLength )

        # if( $MaxLength -gt $truncLen ) { $suffix = '…' }
        # else { $Suffix = '' }


        $render = $Str.Substring( <# startIndex: #> $startIndex, <# length: #> $TruncLen )
        if( $render.Length -le $StrLen ) { $Render }
        else { $Render + $Suffix }
    }
    end {
        'left off: logic needs to take start index' | Write-Verbose -verbose
        'left off: logic needs to take start index' | Write-Host -bg 'salmon'

    }
}
