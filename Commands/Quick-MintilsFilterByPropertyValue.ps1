function Quick-MintilsFilterByPropertyValue {
    <#
    .synopsis
        Takes a list of objects, prompts user with Fzf to select distinct values in that column, then filters to require those items
    .description
        Saves
            selected values to:      $LastMintFzfProps
            results after filtering: $LastMintFzf
    .EXAMPLE
        > Get-Alias | Mint.Quick-FilterByProperty -PropertyName Source
    .EXAMPLE
        > Find-Type | Mint.Quick-FilterByProperty Namespace
    #>
    [Alias('Mint.Quick-FilterByProperty')]
    # [OutputType( )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0 )]
        [Alias('Name')]
        [string] $PropertyName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]] $InputObject,

        [switch] $KeepEmptyValue,
        [switch] $KeepWhitespaceOnlyValue
    )
    begin {
        [Collections.Generic.List[Object]] $items = @()
    }
    process {
        foreach( $Obj in $InputOBject ) {
            $items.Add( $Obj )
        }
    }
    end {
        $lastUniquePropValues = @(
            $Items
            # $GetAlias
                | Mint.Get-UniquePropValue -Name $PropertyName -KeepEmptyValue:$( $KeepEmptyValue ) -KeepWhitespaceOnlyValue:$( $KeepWhitespaceOnlyValue )
        )

        # todo: clean: Should use Invoke-Fzf/Select instead of hard coded
        $lastFzfProps = $lastUniquePropValues
            | fzf -m <# --tac #> --cycle <# --footer foot #> --layout=reverse --header "Property '${PropertyName}' Values to keep: " --header-first --input-border rounded  --gap=1 --gap-line="$(New-Text '-' -fg gray30)"
            # extra params '--no-input' ; and no escap[e for exit]


        $found = $Items | ? $Propertyname -in @( $lastFzfProps )
        $found

        if( $true ) {
            $global:LastMintFzfProps = $LastFzfProps
            $global:LastMintFzf      = $found

            $lastFzfProps
                | Join-String -sep ', ' -op '$LastMintFzf = '
                | Write-Host -fg 'gray60' -bg 'gray30'

            $found.count
                | Join-String "`$Found = {0} items"
                | Write-Host -f 'goldenrod' -bg 'gray20'
        }
    }
}
