
function Require-MintilsAppExists {
    <#
    .SYNOPSIS
        Require [ApplicationInfo] exists. Returns one match. They can come from many extension types / *.exe, *.cmd, *.py, .sh, etc...
    .notes
        If you want an *.exe or *.cmd from Get-Command,
        [ApplicationInfo] works best, It's cross platform. And isn't hardcoded to a specific extension.
    .example
        > $binPy = Mint.Require-AppInfo py
        > & $binPy '--version'
        # 'If the command is missing, it quits before this line'
    .example
        # Silly, but it works
        > & ( Mint.Require-AppInfo py ) '--version'
        > & ( Mint.Require-AppInfo fd ) @( '-e', 'ps1', '--newer', '2days' )
    .link
        Mintils\Find-MintilsAppCommand
    .link
        Mintils\Require-MintilsFileExists
    .link
        Mintils\Require-MintilsAppExists
    #>
    [CmdletBinding()]
    [OutputType( [Management.Automation.ApplicationInfo] )]
    [Alias(
        'Mint.Require-App',
        'Mint.Require-AppInfo' )]
    param(
        [Parameter(Mandatory)]
        [object] $Name
    )
    [Management.Automation.ApplicationInfo] $App = Mint.ExecutionContext.Get-Commands -Name $Name | Select-Object -First 1
    if ( -not $App ) {
        $msg = "Application '$Name' not found in PATH."
        $err =
            [Management.Automation.ErrorRecord]::new(
                [System.Exception]::new( $msg ),
                'Mintils.Require-AppExists.AppNotFound',
                [Management.Automation.ErrorCategory]::ObjectNotFound,
                $Name
            )
        throw $err # $PSCmdlet.ThrowTerminatingError( $err )
    }
    $App
}
