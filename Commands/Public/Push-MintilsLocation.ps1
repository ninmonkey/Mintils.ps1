function Push-MintilsLocation {
    <#
    .synopsis
        go to a path, auto convert-paths, since push/pop doesn't 2025-10-29
    .example
        # jump to module
        > Get-Module Pansies | Goto
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
