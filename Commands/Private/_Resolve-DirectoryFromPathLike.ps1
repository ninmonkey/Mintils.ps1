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
