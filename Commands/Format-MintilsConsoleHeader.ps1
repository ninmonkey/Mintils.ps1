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

        [string] $PrefixText = ' ## ',
        [string] $SuffixText = ' ## ',

        # returns the (New-Text) result instead of writing to the console
        [switch] $PassThru,

        [Alias('Fg')]
        [RgbColor] $ForegroundColor = 'PaleVioletRed2',

        [Alias('Bg')]
        [RgbColor] $BackgroundColor = 'SlateBlue4'
    )
    process {

        $render = "${PrefixText}${Text}${SuffixText}"
        $obj = $render | Pansies\New-Text -fg $ForegroundColor -bg $BackgroundColor
        if( $PassThru ) { return $obj }
        $obj | Pansies\Write-Host
    }
}
