function Select-MintilsObject {
    <#
    .synopsis
        Select first, last, some, etc...
    .EXAMPLE
        # when you want a few items
        > Get-Module | Mint.One            # first only
        > Get-Module | Mint.Select-Some    # up to 5
        > Get-Module | Mint.Select-Some 20 # up to 20
    .example
        > 'a'..'f' | Mint.Select-Random -Shuffle | Mint.One
    .example
        # optional: enable aggressive aliases
        > Mint.Enable-DefaultAlias

        # like
        > Get-Process | One
        > Get-Process | Some # returns 5

        > Get-Module | One
    .link
        Mintils\Select-MintilsRandomObject
    .link
        Mintils\Mint.Some
    .link
        Mintils\Mint.One
    .link
        Mintils\Mint.Select-Random
    #>
    [Alias('Mint.Select-Some', 'Mint.One', 'Mint.First' )]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline for speed
        [Alias('InObj', 'Obj')]
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
