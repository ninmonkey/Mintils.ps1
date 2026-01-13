
function _Coerce.FileSystemInfo.FromString {
    <#
    .synopsis
        [internal] Converts string to the best
    .notes
    - [ ] todo: verify '-as' errors emit from module to user scope from "Mint.New-hashset.FileInfo -Collection <string>"
    - [ ] profile whether skipping (Get-Item) is significantly faster when piping large volumes.
        if yes,
            - [ ] Add -FromDirectoryString -FromFileString to explicity set the type
            - [ ] or -SkipGetItemCheck as a parameter
    .example
        > 'c:\foo\bar', $Profile, $Profile.ToString(), (Get-Item '.'), (Get-Item $Profile),
            | _Coerce.FileSystemInfo.FromString
    #>
    [OutputType( [System.IO.FileInfo], [System.IO.DirectoryInfo] )]
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [string[]] $InputObject
    )
    process {
        foreach( $Str in $InputObject ) {
            if( $null -eq $Str ) { continue }

            if( $Item = Get-Item -ea 'ignore' $Str  ) {
                $Item
                continue
            }

            if( Test-Path $Str -PathType Leaf ) {
                $Item = $Str -as [IO.FileInfo]
                if( $null -ne $Item ) {
                    $item
                    continue
                }
            }

            $item = $Str -as [IO.DirectoryInfo]
            if( $null -ne $Item ) {
                $item
                continue
            }

            if( $null -eq $item ) {
                "Failed Coercing string to [IO.DirectoryInfo] or [IO.FileInfo]! From Input = '{0}'" -f $Str
                    | Write-Error
            }
        }
    }
}
