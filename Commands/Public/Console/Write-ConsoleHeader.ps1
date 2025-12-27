function Write-MintilsConsoleHeader {
    <#
    .synopsis
        Write a markdown header, or a <h1> with color
    .description
        Writes a console header like markdown. Or returns so that you can pipe it elsewhere.
    .EXAMPLE
        > 'hi world' | Mint.Write-H1 # Default writes to Host
        > 'hi world' | Mint.Write-H1 -fg 'gray40' -bg 'gray30'
    .example
        # Write Colors to another stream: Verbose/ Write-Information, etc.
        # without Write-Host
        > $msg = 'Log Start: {0}' -f (Get-Date) | Mint.Write-H1 -PassThru
        > $msg | Write-Verbose -Verbose
        > $msg | Write-Information -infa Continue
    #>
    [Alias('Mint.Write-ConsoleHeader', 'Mint.Write-H1')]
    # OutputType: always [Void], except when using -PassThru: output is [PoshCode.Pansies.Text]
    [CmdletBinding()]
    param(
        [Alias('Name', 'Label')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Text,

        # Text before your header text, or ' ## '
        [string] $PrefixText = ' ## ',

        # Text after your header text, or ' ## '
        [string] $SuffixText = ' ## ',

        # Returns the (New-Text) result instead of writing to the console/Host
        [switch] $PassThru,

        # accepts [RgbColor] or Null, otherwise the default color
        [Alias('Fg')]
        [RgbColor] $ForegroundColor = 'PaleVioletRed2',

        # accepts [RgbColor] or Null, otherwise the default color
        [Alias('Bg')]
        [RgbColor] $BackgroundColor = 'SlateBlue4',

        # number of newlines to prefix, and suffix the header with. otherwise none. ( when -not $PassThru ). Default is 0.
        [int] $PadBothLines = 0
    )
    process {

        $render = "${PrefixText}${Text}${SuffixText}"
        $obj = $render | Pansies\New-Text -fg $ForegroundColor -bg $BackgroundColor
        if( $PassThru ) { return $obj }

        if( -not $PadBothLines ) {
            $obj | Pansies\Write-Host
        } else {
            $Pad = "`n" * $PadBothLines -join ''
            $Obj| Join-String -f "${Pad}{0}${Pad}"
                | Pansies\Write-Host
        }
    }
}
