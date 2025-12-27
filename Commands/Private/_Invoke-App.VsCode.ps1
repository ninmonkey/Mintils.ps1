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

        [Parameter()]
        [object] $AddDirectory,

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

        [ValidateSet('on', 'off')]
        [string] $Sync
    )
    begin {}
    end {
        [Collections.Generic.List[Object]] $binArgs = @()

        $PSBoundParameters | ConvertTo-Json -Depth 2
            | Join-String -op 'PSboundParams: ' | Write-Verbose

        <# modal modes, that requires a clear/reset $BinArgs #>
        if( $FileWithLineNumberString ) {
            $binArgs = @(
                '--goto'
                $FileWithLineNumberString
            )
        }
        if( $GotoFile ) {
            $binArgs = @(
                '--goto'
                $GoToFile
            )
        }
        if( $AddDirectory ) {
            $binArgs = @(
                '--add'
                $AddDirectory
            )
        }
        if( $Version ) {
            $binArgs = @(
                '--version'
            )
        }
        if( $LocateShellIntegrationPath ) {
            $binArgs = @(
                '--locate-shell-integration-path'
                $LocateShellIntegrationPath
            )
        }
        if( $Status ) {
            $binArgs = @( '--status' ) # is this mode exclusive?
        }

        <# options that are composed with the base ones #>
        if( $VerboseLog ) {
            $binArgs.Add( '--verbose' )
        }
        if( $LogLevel ) {
            $binArgs.AddRange(@( '--log', $LogLevel ))
        }
        if( $Telemetry ) {
            $binArgs.Add( '--telemetry' )
        }
        if( $Transient ) {
            $binArgs.Add( '--transient' )
        }
        if( $DisableGPU ) {
            $binArgs.Add( '--disable-gpu' )
        }
        if( $Sync ) {
            $binArgs.Add( '--sync', $Sync )
        }
        if( $ProfileStartup ) {
            $binArgs.Add( '--sync', $Sync )
        }
        if( $DisableExtensions ) {
            $binArgs.Add( '--sync', $Sync )
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
