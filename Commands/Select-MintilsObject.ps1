function Select-MintilsObject {
    <#
    .synopsis
        Select first, last, some, etc...
    #>
    [Alias('Mint.Select-Some')]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline for speed
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object[]] $InputObject,

        [int] $MaxCount = 5
    )
    begin {
        $found_count = 0
        $PSCmdlet.MyInvocation.MyCommand.Name | Write-Debug
        write-warning 'WIP: Not executing as expected for smart alias! 🐘'
        if( $PSCmdlet.MyInvocation.MyCommand.Name -in @('one', 'first' ) ) {
            $found_count = 1
        }
        # wait-debugger
        # if( $PSCmdlet.MyInvocation. )
    }
    process {
        foreach( $Item in $InputOBject ) {
            if( $found_count -ge $MaxCount ) { return }
            $found_count += 1
            $InputObject
        }
    }
}
