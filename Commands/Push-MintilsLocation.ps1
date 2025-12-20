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
        [switch] $PassThru

        # [string] $StackName = 'mintils.goto' # might not affect user scope
    )
    begin {}
    end {
        $ResolvedPath = Get-Item -ea ignore $InputObject
        $Return = $null

        [PSCustomObject]@{
            ResolvedType           = ( $ResolvedPath )?.GetType().FullName
            Resolved               = ( $ResolvedPath )?.ToString()
            ParamObjectType    = ( $InputObject )?.GetType().FullName
            ParamObject        = ( $InputObject )?.ToString()
            ParamDirectoryType = ( $Directory )?.GetType().FullName
            ParamDirectory     = ( $Directory )?.ToString()
        } | ConvertTo-Json -Depth 0 | Join-String -f 'Mint.Goto parameters: {0}' | Write-Debug

        switch( $ResolvedPath ) { # refactor as private
            { $_ -is [IO.DirectoryInfo] } {
                $null = Microsoft.PowerShell.Management\Push-Location -Path $ResolvedPath # -StackName $StackName
                $Return = $ResolvedPath
            }
            { $_ -is [IO.FileSystemInfo] } {
                Microsoft.PowerShell.Management\Push-Location -Path $ResolvedPath.Directory # -StackName $StackName
                $Return = $ResolvedPath.Directory
            }
            default {
                'Unhandled input type when converting to path: {0}' -f $InputObject.GetType().Name | Write-Warning
            }
        }

        if( $PassThru ) { $return }


        <#
        other properties that include full filenames in path
            [PSModuleInfo].Path

            [ApplicationInfo].Source

        #>
    }
}
