function Get-MintilsUniquePropertyValue {
    <#
    .synopsis
        From a list of objects: Get the Unique list of all values for a property name
    .DESCRIPTION
        Output is case-sensitive
    .EXAMPLE
        Get-Command | Mint.Get-UniquePropValues -Name Source
    .EXAMPLE
        Get-Alias   | Mint.Get-UniquePropValues -Name Source
    #>
    [Alias( 'Mint.Get-UniquePropValue', 'Get-MintilsUniquePropertyValues' )]
    [OutputType( [string[]] )]
    [CmdletBinding()]
    param(
        # Which property to inspect
        [Alias('Name')]
        [Parameter(Mandatory)]
        [string] $PropertyName,

        # objects to inspect
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]] $InputObject,

        # Keep or ignore a [String]::Empty
        [switch] $KeepEmptyValue = $true,

        # keep or ignore whitespace-only strings
        [switch] $KeepWhitespaceOnlyValue,

        # The default mode will sort. You can choose to preserve the order each was visited
        [Alias('NoSort')]
        [switch] $WithoutSort,

        # uses casesenstive compare by default
        [Alias('UsingCaseInsensitive')]
        [ValidateScript({throw 'nyi'})]
        [switch]$CaseInsensitive
    )
    begin {
        [Collections.Generic.HashSet[string]] $hset = @()

        # [Collections.Generic.List[Object]] $Items = @() # allow sort-object unique on object types ?? or just strings
    }
    process {
        foreach($Obj in $InputObject) {
            $value = $Obj.$Propertyname
            if( $Null -eq $Value ) { continue }
            $isEmptyStr = [string]::Empty -eq $value

            if( $isEmptyStr -and $KeepEmptyValue ) {
                $null = $hset.Add( $value )
                continue
            }
            if(
                -not $isEmptyStr -and
                     $KeepWhitespaceOnlyValue -and
                     [string]::IsNullOrWhiteSpace( $value )
            ) {
                $null = $hset.Add( $value )
                continue
            }
            $null = $hset.Add( $value )
            # if( -not $KeepEmptyValue          -and [string]::IsNullOrEmpty( $value ) )      { continue }
            # if( -not $KeepWhitespaceOnlyValue -and [string]::IsNullOrWhiteSpace( $value ) ) { continue }

            # $null = $hset.Add( $value )
        }
    }
    end {
        if( $WithoutSort ) { return $hset }
        $hset | Sort-Object
    }
}
