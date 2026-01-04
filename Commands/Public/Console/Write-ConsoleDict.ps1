function Write-MintilsConsoleDict {
    <#
    .synopsis
        Write dictionaries to the console as key -> value pairs with color
    .EXAMPLE
        # The basic invoke works positionally
        > Mint.Write-Dict @{ id = 123; color = 'blue' ; }
        # output with colors:

            color: blue
            id: 123
    .link
        Mintils\Write-MintilsConsoleDict
    .link
        Mintils\Write-MintilsConsoleLabel
    #>
    [Alias('Mint.Write-ConsoleDict', 'Mint.Write-ConsoleHashtable', 'Mint.Write-Dict')]
    # OutputType: always [Void], except when using -PassThru: output is [PoshCode.Pansies.Text]
    [CmdletBinding()]
    param(
        # hashtable or idictionary or what is best to iterate ?
        [Alias('Dict', 'Hashtable')]
        [Collections.IDictionary]
        $InputObject,

        # for: "Mint.Write-Label -Delim"
        # string (or none) between: <key><delim><value>
        [Alias('TemplateDelim')]
        [string] $Delim, # was ':',

        # for: "Mint.Write-Label -ValuePrefix"
        # space/value (or none) between: <delim> and <value>
        [Alias('TemplateValuePrefix')]
        [string] $ValuePrefix, # was ' ',


        # for: "Mint.Write-Label -PassThru"
        # Returns the (New-Text) result instead of writing to the console/Host
        [Alias( 'WithoutWriteHost')]
        [switch] $PassThru
    )
    begin {}
    process {
        # foreach( $Key in $InputObject.Keys)
        [string[]] $AllKeys = $InputObject.Keys.Clone() | Sort-Object -Unique

        $out = foreach( $KeyName in $AllKeys ) {
            $label_splat = @{
                LabelName   = $KeyName
                InputObject = $InputObject[ $KeyName ] | Join-String -sep ', '
            }
            # Emit keys only when declared to preserve inner default fallback values
            if ( $PSBoundParameters.ContainsKey( 'Delim' ) ) { $label_splat.Delim = $Delim }
            if ( $PSBoundParameters.ContainsKey( 'ValuePrefix' ) ) { $label_splat.ValuePrefix = $ValuePrefix }
            if ( $PSBoundParameters.ContainsKey( 'PassThru' ) ) { $label_splat.PassThru = $PassThru }

            Mint.Write-Label @label_splat
        }

        if( $PassThru ) { return $out }
        $out | Pansies\Write-Host
    }
}
