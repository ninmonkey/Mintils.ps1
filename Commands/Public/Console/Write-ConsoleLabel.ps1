function Write-MintilsConsoleLabel {
    <#
    .synopsis
        Write output with a label
    .description
        For collections the Key names are the same for each item.
        When key names should change, see:
            Mint.Write-ConsoleDict
    .EXAMPLE
        # The basic invoke works positionally
        > Mint.Write-Label 'user' 'bob'
        > Mint.Write-Label 'PSVersion' $PSVersionTable.PSVersion
        # out: PSVersion: 7.5.4

    .link
        Mintils\Write-MintilsConsoleDict
    .link
        Mintils\Write-MintilsConsoleLabel
    #>
    [Alias('Mint.Write-ConsoleLabel', 'Mint.Write-Label')]
    # OutputType: always [Void], except when using -PassThru: output is [PoshCode.Pansies.Text]
    [CmdletBinding()]
    param(
        # Key Name
        [Parameter( Mandatory, Position = 0 )]
        [Alias('Key', 'Name')]
        [string] $LabelName,

        # Values
        [Alias('Object', 'InObj', 'Value')]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, ValueFromPipeline, Position = 1 )]
        [object[]] $InputObject,

        # string (or none) between: <key><delim><value>
        [Alias('TemplateDelim')]
        [string] $Delim = ':',

        # space/value (or none) between: <delim> and <value>
        [Alias('TemplateValuePrefix')]
        [string] $ValuePrefix = ' ',

        # Returns the (New-Text) result instead of writing to the console/Host
        [Alias( 'WithoutWriteHost')]
        [switch] $PassThru
    )
    begin {
        $KeyColor    = Mint.Get-TextStyle -Style Dict.Key -AsSplatableHash
        $ValueColor  = Mint.Get-TextStyle -Style Dict.Value -AsSplatableHash
        $ResetColor = $PSStyle.Reset
        $Prefix     = "${ResetColor}" # or '  ', "${ResetColor}  "
    }
    process {
        $out = foreach( $Obj in $InputObject ) {
            "${Prefix}{0}${Delim}${ResetColor}${ValuePrefix}{1}" -f @(
                New-Text @KeyColor -Obj $LabelName
                New-Text @valueColor -Obj $Obj
            )
        }
        if( $PassThru ) { return $out } # is the preferred default to return as an array, or enumerate it?
        $out | Pansies\Write-Host
    }
}
