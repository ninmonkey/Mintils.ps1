
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

        # New-Item -Force is on by default
        # # By default, New-Item uses -Force
        [switch] $WithoutForce,

        # By default, create file if missing
        [switch] $WithoutCreate,

        # prompt when if creating new files/folders. calls New-Item with -Confirm
        [switch] $Confirm
    )
    $Resolved = Get-Item -ea 'ignore' $Path
    if( $Resolved -is [System.IO.FileInfo] ) {
        return $Resolved
    }
    if( $WithoutCreate -and -not ( Test-Path $Path ) ) {
        throw "Directory does not exist: '${Path}' ! WithoutCreate: ${WithoutCreate}, withoutForce ${WithoutForce}"
    }
    $newItem = New-Item -Path $Path -ItemType File -Confirm:$( $Confirm ) -ea 'stop' -Force:$( -not $WithoutForce ) -ev 'evNewItem'
    if( $newItem -and ( Test-Path $newItem ) ) {
        return $newItem
    }
    throw "File was not created! '${Path}' ! WithoutCreate: ${WithoutCreate}, withoutForce ${WithoutForce}"
}
