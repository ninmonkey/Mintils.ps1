function Get-MintilsTypeFormatData {
    <#
    .synopsis
        Get TypeData and Formatdata with some sugar
    .NOTES
    .EXAMPLE
    #>
    [Alias(
        'Mint.Get-TypeFormatData'
    )]
    # [OutputType( [System.IO.FileInfo] )]
    [CmdletBinding()]
    param(
        # type, or object to get the type of
        [Parameter(Mandatory)]
        [Alias('Name', 'Type', 'InObj' )]
        [object] $InputType
    )
    begin {}
    process {}
    end {
        $name  = $InputType -is [string] ? $InputType : $InputType.GetType()
        $fdata = Get-FormatData -TypeName $name
        $tdata = Get-TypeData -TypeName $name

        "Query: $name" | Write-Verbose
        $data = [ordered]@{
            PSTypeName = 'Mintils.TypeAndFormatData.Info'
            FormatData = $fdata
            TypeData   = $tdata
        }
        [pscustomobject]$data
    }
}
