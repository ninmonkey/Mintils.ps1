function Select-MintilsRandomObject {
    <#
    .synopsis
        Select first, last, some, etc...
    .example
        > $ps ??= Get-Process
        > $ps | Mint.Select-Random # 5
        > $ps | Mint.Select-Random 2 # 2
        > $ps | Mint.Select-Random -SetSeed 3 # set seed for a fixed-random value

    .example
        > 'a'..'f' | Mint.Select-Random -Shuffle
        > 'a'..'f' | Mint.Select-Random -Shuffle -SetSeed 4
    .link
        Microsoft.PowerShell.Utility\Get-Random
    #>
    [Alias('Mint.Select-Random')]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline
        [Alias('InObj', 'Obj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object[]] $InputObject,

        [Parameter( Position = 0)]
        [int] $MaxCount = 5,

        # for: Get-Random -Shuffle
        [switch] $Shuffle,

        # for: Get-Random -SetSeed
        [int] $SetSeed
    )
    begin {
        [Collections.Generic.List[Object]] $items = @()
        # $found_count = 0
        # if( $PSCmdlet.MyInvocation.InvocationName -in ('Mint.RandomOne' ) ) {
        #     $MaxCount = 1
        # }
    }
    process {
        $items.AddRange( [object[]] $InputObject )
    }
    end {
        $splat = @{
            InputObject = $Items
            Count = $MaxCount
        }
        if( $Shuffle ) { # can't use -Shuffle and -Count at the same time
            $splat.Shuffle = $Shuffle
            $splat.Remove( 'Count' )
        }

        if( $setSeed ) { $splat.SetSeed = $setSeed }
        Get-Random @splat # -InputObject $items -Count $MaxCount # -SetSeed
    }
}
