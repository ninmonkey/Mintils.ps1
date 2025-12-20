function _Resolve-DirectoryFromPathlike {
    <#
    .SYNOPSIS
        [private] get filepath if possible from many object types. Prefer filename with path, fallback to directory if needed.
    .DESCRIPTION
        returns $null if all paths failed, and writes a warning.
    .example
        # Externally test using this:
        & ( ipmo Mintils -PassThru ) { _Resolve-DirectoryFromPathLike ( gcm Add-ExcelName ) -Debug }
    #>
    [CmdletBinding()]
    param(
        # File, Directory, PSModuleInfo, String, Etc
        # Supports Types: ApplicationInfo, DirectoryInfo, FileSystemInfo, FunctionInfo, PSModuleInfo, String,
        [object] $InputObject
    )

    $ResolvedItem = Get-Item -ea ignore $InputObject

    [PSCustomObject]@{
        ResolvedType    = ( $ResolvedPath )?.GetType().FullName
        Resolved        = ( $ResolvedPath )?.ToString()
        InputObjectType = ( $InputObject )?.GetType().FullName
        InputObject     = ( $InputObject )?.ToString()
    } | ConvertTo-Json -Depth 0 | Join-String -f 'Mint.Goto parameters: {0}' | Write-Debug

    if( $InputObject -is [IO.FileSystemInfo] ) {
        return $InputObject
    }
    if( $InputObject -is [System.Management.Automation.PSModuleInfo] ) {
        return ( Get-Item $InputObject.Path )
    }
    if( $InputObject -is [IO.DirectoryInfo] ) {
        return $InputObject
    }
    if( $InputObject -is [Management.Automation.FunctionInfo] ) {
        [Management.Automation.FunctionInfo] $maybeFunc = $InputObject
        $Resolved = Get-Item $maybeFunc.ScriptBlock.Ast.Extent.File
        if( $null -eq $Resolved ) {
            throw "Found [FunctionInfo] but Ast.Extent.File was null. ( Verify the module '$( $InputObject.Source  )' is loaded )"
        }
        return $Resolved
    }
    if( $InputObject -is [Management.Automation.ApplicationInfo] ) {
        [Management.Automation.ApplicationInfo] $maybeApp = $InputObject
        $Resolved = ( Get-Item $maybeApp.Source ) ?? ( Get-Item $maybeApp.Path )
        return $Resolved
    }
    if( $InputObject -is [string] -and $Null -ne $ResolvedItem ) {
        return $ResolvedItem
    }
    "Unhandled input type when converting '${InputObject}' of type $( ( $InputObject)?.GetType() ) to path: {0}" | Write-Warning
    # Maybe always attempt PSPath ? Or leave that to the caller?
}

function Push-MintilsLocation {
    <#
    .synopsis
        go to a path, auto convert-paths, since push/pop doesn't 2025-10-29
    .example
        # test whether types detect the correct properties
        $someFile = $Profile.CurrentUserAllHosts
        $someFile | Mint.Goto -Debug
        $someFile | Get-Item | Mint.Goto -Debug
        $Profile  | Mint.Goto -Debug
        (gmo mintils) | Mint.Goto -Debug -PassThru |% fullname
        (gmo mintils).Path | Mint.Goto -debug -PassThru | % Fullname
    #>
    [CmdletBinding()]
    [Alias( 'Mint.Push-Location', 'Mint.Goto')]
    param(
        # Goto Location of this file. Files and Directories are valid
        [Alias('FullName')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object] $InputObject,

        # Directory or PSPath
        [Alias('PSPath')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object] $Directory,

        # Also output the directory you moved to as an object
        [switch] $PassThru,

        # writes new path to the console as dim text
        [switch] $PSHost
        # [string] $StackName = 'mintils.goto' # might not affect user scope
    )
    begin {}
    end {
        $Resolved = _Resolve-DirectoryFromPathlike $InputObject
        Join-String -f 'Resolved: "{0}"' -InputObject ( $Resolved )?.ToString() | Write-Verbose

        if( $Null -eq $Resolved ){
            $Resolved = _Resolve-DirectoryFromPathlike $Directory
        }
        if( $Null -eq $Resolved ) {
            throw "Unhandled error resolving '${Resolved}' of type: '$( ( $Resolved)?.GetType() )' "
        }

        if( Test-Path -ea 'ignore' $Resolved.Directory ) {
            $null = Microsoft.PowerShell.Management\Push-Location -Path $Resolved.Directory #
        } elseif ( Test-Path -ea 'ignore' $Resolved ) {
            $null = Microsoft.PowerShell.Management\Push-Location -Path $Resolved
        }
        if( $PSHost ) {
            $Resolved | Join-String -f '    Move to => "{0}"'
                | Write-Host -bg 'gray20' -fg 'gray30'
        }

        # $null = Microsoft.PowerShell.Management\Push-Location -Path $Resolved.Directory # -StackName 'mintils.goto'
        if( $PassThru ) { return $Resolved } # emit objects instead of 'Push-Location'. Allowing found filename to be returned.
    }
}
