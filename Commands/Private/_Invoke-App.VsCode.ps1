# remove the majority of this implementation from the repo
function _Invoke-App.VsCode {
    <#
    .SYNOPSIS
        [internal] lower level VS Code wrapper. No error handling.
    .description
        Internal version. Minimal error handling,

        for the user-facing version with error handling
            see: Mint.Invoke-App.VsCode

        Not using ParameterSets because of the complexity, and future parameters
    .notes
    --log <level>

        Allowed values are 'critical', 'error', 'warn', 'info', 'debug', 'trace', 'off'.

        You can also configure the log level of an extension by passing
        extension id and log level in the following format:
            '${publisher}.${name}:${logLevel}'.

            For example: 'vscode.csharp:trace'.
    .example
        # quick testing
        > & ( ipmo Mintils -PassThru -Force ) {
            _Invoke-App.VsCode -Version -verbose -LogLevel info -WhatIf
            | Join-String -sep ' ' | write-host -fg salmon }
    .link
        Mint\Mint.Invoke-App.VsCode
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $FileWithLineNumberString,

        # Read piped text instead of a file
        [ValidateScript({throw 'nyi'})]
        [switch] $FromStdIn,

        [Parameter()]
        [object] $GotoFile,

        [Alias('Add')]
        [Parameter()]
        [object] $AddDirectory,

        [Alias('Remove')]
        [Parameter()]
        [object] $RemoveDirectory,

        # Outputs BinArgs commands as [List[object]]
        [Alias('TestOnly')]
        [switch] $WhatIf,

        # writes log to console
        [switch] $VerboseLog,
        [switch] $Version,

        [ValidateScript({throw 'nyi'})]
        [ArgumentCompletions('chat', 'serve-web', 'tunnel')]
        [string] $SubCommand,

        [ArgumentCompletions('bash', 'pwsh', 'zsh', 'fish')]
        [string] $LocateShellIntegrationPath,

        <#
        Log level to use. Default: info.
        Allowed values are 'critical', 'error', 'warn', 'info', 'debug', 'trace', 'off'.

        You can also configure the log level of an extension by passing
        extension id and log level in the following format:
            '${publisher}.${name}:${logLevel}'.

        For example: 'vscode.csharp:trace'.
        #>
        [ArgumentCompletions(
            'critical', 'error', 'warn', 'info', 'debug', 'trace', 'off',
            "'publisher.name:severity'" )]
        [string] $LogLevel,

        [switch] $Status,
        [switch] $Transient,
        [switch] $Telemetry,
        [switch] $DisableGPU,

        [switch] $ProfileStartup,
        [switch] $DisableExtensions,

        # force a new window
        [switch] $NewWindow,

        # Force open a file or folder in an existing window
        [switch] $ReuseWindow,

        [ValidateSet('on', 'off')]
        [string] $Sync,

        # code: 'code --diff <file1> <file2>'
        [ValidateScript({throw 'nyi'})]
        [switch] $Diff,

        # code: 'code --merge <path1> <path2> <base> <result>'
        [ValidateScript({throw 'nyi'})]
        [switch] $Merge,

        # wait for files to be closed
        [switch] $Wait,

        [ArgumentCompletions('en-US', 'de-de')]
        [string] $Locale,

        # cmd: "code --user-data-dir <dir>". Specifies the directory that user data is kept in. Can be used to open multiple distinct instances of Code.
        [string] $UserDataDir,

        # cmd: "code --profile <name>".  Opens the provided folder or workspace with the given profile and associates the profile with the workspace. If the profile does not exist, a new empty one is created.
        [string] $Profile
    )
    begin {}
    end {
        [Collections.Generic.List[Object]] $binArgs = @()
        [Collections.Generic.List[Object]] $OptionsArgs = @()


        $PSBoundParameters | ConvertTo-Json -Depth 2
            | Join-String -op 'PSboundParams: ' | Write-Verbose

         <# options that are composed with the base ones #>
        if( $VerboseLog ) {
            $OptionsArgs.Add( '--verbose' )
        }
        if( $LogLevel ) {
            $OptionsArgs.AddRange(@( '--log', $LogLevel ))
        }
        if( $Telemetry ) {
            $OptionsArgs.Add( '--telemetry' )
        }
        if( $Transient ) {
            $OptionsArgs.Add( '--transient' )
        }
        if( $DisableGPU ) {
            $OptionsArgs.Add( '--disable-gpu' )
        }
        if( $Sync ) {
            $OptionsArgs.Add( '--sync', $Sync )
        }
        if( $ProfileStartup ) {
            $OptionsArgs.Add( '--sync', $Sync )
        }
        if( $DisableExtensions ) {
            $OptionsArgs.Add( '--sync', $Sync )
        }
        if( $NewWindow ) {
            $OptionsArgs.Add( '--new-window' )
        }
        if( $ReuseWindow ) {
            $OptionsArgs.Add( '--reuse-window' )
        }
        if( $Wait ) {
            $optionsArgs.Add( '--wait' )
        }
        if( $Locale ) {
            $optionsArgs.AddRange(@( '--locale', $Locale ))
        }
        if( $UserDataDir ) {
            $optionsArgs.AddRange(@( '--user-data-dir', $UserDataDir ))
        }
        if( $Profile ) {
            $optionsArgs.AddRange(@( '--profile', $Profile ))
        }

        <# modal modes, that requires a clear/reset $BinArgs #>
        if( $FileWithLineNumberString ) {
            $binArgs = @(
                $OptionsArgs
                '--goto'
                $FileWithLineNumberString
            )
        }
        if( $GotoFile ) {
            $binArgs = @(
                $OptionsArgs
                '--goto'
                $GoToFile
            )
        }
        if( $AddDirectory ) {
            $binArgs = @(
                $OptionsArgs
                '--add'
                $AddDirectory
            )
        }
        if( $RemoveDirectory ) {
            $binArgs = @(
                $OptionsArgs
                '--remove'
                $RemoveDirectory
            )
        }
        if( $Version ) {
            $binArgs = @(
                $OptionsArgs
                '--version'
            )
        }
        if( $LocateShellIntegrationPath ) {
            $binArgs = @(
                # $OptionsArgs
                '--locate-shell-integration-path'
                $LocateShellIntegrationPath
            )
        }
        if( $Status ) {
            $binArgs = @(
                # $OptionsArgs
                '--status'
            ) # is this mode exclusive?
        }
        if( $FromStdIn ) {
            $binArgs.add( '-' )
        }

        if( $WhatIf ) {
            $binArgs | Join-String -sep ' ' -op 'invoke "code" => '
                | Write-Host -fg 'gray70' -bg 'gray30'

            return $binArgs
        }

        & ( Mint.Require-App 'code' ) @BinArgs
    }
    process {}

}
