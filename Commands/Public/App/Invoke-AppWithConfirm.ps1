

function Invoke-MintilsAppWithConfirm {
    <#
    .SYNOPSIS
        Invokes command line apps: with [1] user prompt to run it, and [2] log CLI args used
    .DESCRIPTION
        If -UseConfirm is set, it will prompt the user before invoking.
        if false, run without requiring prompt. But logs by default.

        - todo: future will support input pipeline, with confirmation
    .example
        # main use prompt to run a command
        > Mint.Invoke-AppWithConfirm -Name 'code' -Args @( '--goto', $Profile.CurrentUserAllHosts ) -Confirm
    .example
        # Short syntax
        > Mint.Invoke-App -Confirm gh 'repo', 'list'
    .EXAMPLE
        # Run the command as normal, capture results
        # show command line args on the host
        > $found = Mint.Invoke-AppWithConfirm -Name 'fd'
            # out: Mint.InvokeApp => fd --color=never
    .example
        # Do not log to host
        $found = Mint.Invoke-AppWithConfirm -Name 'fd' -Silent
    #>
    [Alias(
        'Mint.Invoke-App',
        'Mint.Invoke-AppWithConfirm' )]
    [CmdletBinding()]
    param(
        [Alias('Name')]
        [string] $CommandName,

        [Alias('Args', 'ArgList')]
        [object[]] $CommandLineArgs,

        # never run the final command
        [Alias('TestOnly', 'EchoWithoutRun')]
        [switch] $WhatIf,

        # Default runs the command without prompt, if true then it requires a prompt
        [Alias('Confirm')]
        [switch] $UseConfirm,

        # The default action is to write text to the console or verbos
        [Alias('WithoutPSHost', 'WithoutArgsEcho' )]
        [switch] $Silent,

        # Auto complete frequently used
        [ArgumentCompletions(
            "'--color=always'", "'--color=never'" )]
        [string[]] $TemplateArgs
    )
    end {
        $CommandLineArgs = @( $CommandLineArgs; $TemplateArgs; )
        [string] $RenderArgs = $CommandLineArgs | Join-String -sep ' ' -op "${CommandName} "

        if( -Not $Silent ) {
            $RenderArgs
                | Join-String -op 'Mint.InvokeApp => '
                | Mint.Format-TextPredent -Depth 1 -TabSize 2 | Write-Host -fg SteelBlue # -fg SlateGray -bg 'gray20'
        }

        if( $UseConfirm ) {
            $HasConfirmed = $PSCmdlet.ShouldContinue(
                "Execute command?: ${RenderArgs}",
                "Invoke App: ${CommandName}" )
            if( -not $HasConfirmed ) {
                return
            }
        }

        $RenderArgs | Join-String -op "Invoking => " | Write-Verbose
        if( $WhatIf ) { return }
        & ( Mint.Require-App $CommandName ) @CommandLineArgs
    }
}
