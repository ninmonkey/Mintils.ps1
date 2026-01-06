function _Is.Null {
    <#
    .synopsis
        [internal] compare IsBlank, IsNull, IsEmpty, etc.
    .DESCRIPTION
        related: _Is.Null, _Is.Empty, _Is.Blank
    #>
    [OutputType( [bool] )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object] $InputObject
    )
    process {
        return $Null -eq $InputObject
    }
}

function _Is.Empty {
    <#
    .synopsis
        [internal] compare IsBlank, IsNull, IsEmpty, etc.
    .DESCRIPTION
        related: _Is.Null, _Is.Empty, _Is.Blank
    #>
    [OutputType( [bool] )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object] $InputObject
    )
    process {
        return [string]::IsNullOrEmpty( $InputObject )
    }
}

function _Is.Blank {
    <#
    .synopsis
        [internal] compare IsBlank, IsNull, IsEmpty, etc.
    .DESCRIPTION
        related: _Is.Null, _Is.Empty, _Is.Blank
    #>
    [OutputType( [bool] )]
    [CmdletBinding()]
    param(
        [AllowNull()]
        [AllowEmptyString()]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object] $InputObject
    )
    process {
        return [string]::IsNullOrWhiteSpace( $InputObject )
    }
}
