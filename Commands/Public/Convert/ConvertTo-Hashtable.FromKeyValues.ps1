function Convert-MintilsHashtableFromKeyValues {
    <#
    .synopsis
        [internal] Converts arrays of [Collections.DictionaryEntry] to one hashtable
    .description
        Does not sort keys, Does not return [ordered]@{}
    .example
        > Mint.Write-Dict ( Gci Env:\ | Mint.Convert.Dict.FromKeyValues )
    .example
        > $hash = Mint.Convert.Dict.FromKeyValues -InputObject ( Gci Env:\ )
        > Mint.Write-Dict $hash
    .example
        > Mint.Write-Dict ( Mint.Convert.Dict.FromKeyValues -InputObject ( Gci Env:\ ) )
    .example
        > Mint.Write-Dict ( Mint.ConvertTo_Coerce.HashTable.FromDictionaryEntry -InputObject $sample )
    #>
    [Alias(
        'Mint.ConvertTo-Hashtable.FromKeyValues',
        'Mint.Convert-Dict.FromKeyValues',
        # 'Mint.ConvertTo-Dict.FromKeyValues',
        'Mint.Convert.Dict.FromKeyValues'
        # 'Mint.Convert.Dict.FromPairs'
        # Mint.Convert-Hash.FromDictEntry
    )]
    [OutputType( [System.Collections.Hashtable] )]
    [CmdletBinding()]
    param(
        # hashtable or idictionary or what is best to iterate ?
        [Alias('Pairs', 'KeyValues', 'DictionaryEntry')]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]] $InputObject
    )
    begin {
        [Collections.Generic.List[Object]] $List = @()
    }
    process {
        $List.AddRange(@( $InputObject ))
    }
    end {
        _Coerce.HashTable.FromKeyValuePairs -InputObject $List
    }
}
