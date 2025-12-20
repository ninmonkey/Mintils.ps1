
function Require-MintilsDirectoryExists {
    <#
    .SYNOPSIS
        Create a folder if not existing, and return (get-Item) of it. Throw on read/write errors
    .DESCRIPTION
        - If a folder exists, return it using (Get-Item)
        - If missing, attempt to create it.
    .example
        $AppConf = @{
            AppRoot = ( $AppRoot = Get-Item $PSScriptRoot )
            Export  = Mint.Require-Directory -Confirm -Path (Join-Path $AppRoot 'export')
        }
    #>
    [OutputType( [System.IO.DirectoryInfo] )]
    [Alias(
        'Mint.Require-Directory' )]
    param(
        [Alias('PSPath', 'Directory')]
        [Parameter(Mandatory)]
        [object] $Path,

        # prompt for creating new files/folders. calls New-Item with -Confirm
        [switch] $Confirm,

        # By default, create directory if missing
        [switch] $WithoutCreate,

        # By default, New-Item uses -Force
        [switch] $WithoutForce
    )
    $Resolved = Get-Item -ea 'ignore' $Path
    if( $Resolved -is [System.IO.DirectoryInfo] ) {
        return $Resolved
    }
    if( $Resolved.PSIsContainer ) {
        return $Resolved
    }

    if( $WithoutCreate -and -not ( Test-Path $Resolved ) ) {
        throw "Directory does not exist: '${Path}' ! WithoutCreate: ${WithoutCreate}, withoutForce ${WithoughtForce}"
    }

    try {
        $newPath = mkdir -Path $Path -Confirm:$( $Confirm ) -ev 'evMkdir' -ea 'stop'
        if( Test-Path $newPath ) {
            return $newPath
        }
    } catch {
        if( $_.Exception.Message -match 'item with the.*name.*exists' ) {
            "Item already exists: '${Path}'" | Write-Verbose
        } else {
            throw
        }
    }
    throw "Failed resolving diretory: '${Path}' !"
}
