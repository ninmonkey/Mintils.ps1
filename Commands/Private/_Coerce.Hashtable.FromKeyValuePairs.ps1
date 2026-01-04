function _Coerce.HashTable.FromKeyValuePairs { # or FromDictionaryEntry
    <#
    .synopsis
        [internal] Converts arrays of [Collections.DictionaryEntry] to one hashtable
    .description
        Does not sort keys, Does not return [ordered]@{}
    .example
        > $hash = Gci Env:\ | _Coerce.HashTable.FromDictionaryEntry
        > Mint.Write-Dict $Hash
    .example
        > Mint.Write-Dict ( _Coerce.HashTable.FromDictionaryEntry -InputObject $sample )
    .LINK
        Mintils\Mint.ConvertTo-Hashtable.FromKeyValues
    #>
    [OutputType( [System.Collections.Hashtable] )] # [System.Collections.Specialized.OrderedDictionary],
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]] $InputObject
    )
    begin {
        $hash = @{}
    }
    process {
        foreach( $Item in $InputObject ) {
            if( $Item -is [Collections.DictionaryEntry] ) {
                [Collections.DictionaryEntry] $Obj = $Item
                $hash[ $Obj.Key ] = $Obj.Value
                continue
            }
            if( $Item -is [System.Collections.IDictionary] ) {
                $Item.GetEnumerator() | ForEach-Object {
                    $hash[ $_.Key ] = $_.Value
                }
                continue
            }

            if( $null -ne $Item.Key -and $null -ne $Item.Value ) {
                $hash[ $Item.Key  ] = $Item.Value
                continue
            }
            "Unhandled Item type: {0}" -f @(
                ( $Item )?.GetType() ?? '<null>'
            )  | Write-Error
            continue
        }
    }
    end {
        $hash
    }
}
