
function Require-MintilsFileExists {
    <#
    .SYNOPSIS
        Create file if not existing, and return (get-Item) of it. Throw on read/write errors
    #>
    [OutputType( [System.IO.FileInfo] )]
    [Alias(
        'Mint.Require-File' )]
    param(
        [Parameter(Mandatory)]
        [object] $Path,

        # calls New-Item with -Confirm
        [switch] $Confirm
    )

    throw "NYI"
}
