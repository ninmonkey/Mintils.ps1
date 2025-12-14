function Select-MintilsObject {
    <#
    .synopsis
        Select first, last, some, etc...
    #>
    [Alias('Mint.Select-Some', 'Mint.One', 'Mint.First' )]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline for speed
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object[]] $InputObject,

        [Parameter( Position = 0)]
        [int] $MaxCount = 5
    )
    begin {
        $found_count = 0
        if( $PSCmdlet.MyInvocation.InvocationName -in ('One', 'First', 'Mint.One', 'Mint.First' ) ) {
            $MaxCount = 1
        }
    }
    process {
        foreach( $Item in $InputObject ) {
            if( $found_count -ge $MaxCount ) { continue }
            $found_count += 1
            $InputObject
        }
    }
}
