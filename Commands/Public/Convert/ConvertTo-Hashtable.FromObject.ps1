function Convert-MintilsHashtableFromObject {
    <#
    .synopsis
        Converts Objects into a hashtable
    .description
        Does not sort keys, Does not return [ordered]@{}
    .example
        > Mint.Write-Dict ( $Profile | Select All*, Current* | Mint.Convert.Dict.FromObject )
    .example
        > Get-Item . | Mint.Convert.Dict.FromObject
    .example
        > Mint.Write-Dict ( Get-Item '.' | Mint.Convert.Dict.FromObject  )
    .example
        > Get-Item '.' | Select Last*time, PSPath | Mint.Convert.Dict.FromObject | Ft -AutoSize

            Name           Value
            ----           -----
            PSPath         Microsoft.PowerShell.Core\FileSystem::H:\data\2025\pwsh
            LastWriteTime  2025-12-16 5:51:27 PM
            LastAccessTime 2026-01-04 4:08:47 PM
    #>
    [Alias(
        'Mint.ConvertTo-Hashtable.FromObject',
        'Mint.Convert.Dict.FromObject'
    )]
    [OutputType( [System.Collections.Hashtable] )]
    [CmdletBinding()]
    param(
        # hashtable or idictionary or what is best to iterate ?
        [Alias('InObj', 'Obj', 'Target' )]
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
        foreach( $CurObj in $List ) {
            $hash = @{}
            foreach( $Prop in $CurObj.PSObject.Properties ) {
                $hash[ $Prop.Name ] = $Prop.Value
            }
            $hash
        }
    }
}
