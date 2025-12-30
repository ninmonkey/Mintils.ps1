

function Invoke-MintilsAppWithConfirm {
    <#
    .SYNOPSIS
        Invokes command line apps: with [1] user prompt to run it, and [2] log CLI args used
    .DESCRIPTION
        If -UseConfirm is set, it will prompt the user before invoking.
        if false, run without requiring prompt. But logs by default.

        - todo: future will support input pipeline, with confirmation
    .example
        # The main short syntax, without requiring parameter names
        # [1] print the CLI args, then run without confirm
        > Mint.Invoke-App gh 'repo', 'list'

        # [2] Same thing but require confirmation
        > Mint.Invoke-AppWithConfirm gh 'repo', 'list'
    .example
        # main use prompt to run a command
        > Mint.Invoke-AppWithConfirm -Name 'code' -Args @( '--goto', $Profile.CurrentUserAllHosts ) -Confirm
    .EXAMPLE
        # Run the command as normal, capture results
        # show command line args on the host
        > $found = Mint.Invoke-AppWithConfirm -Name 'fd'
            # out: Mint.InvokeApp => fd --color=never
    .example
        # Do not log cli args to host
        $found = Mint.Invoke-AppWithConfirm -Name 'fd' -Silent
    #>
    [Alias(
        'Invoke-MintilsApp',
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

        # Default runs the command without prompt, if true then it requires a prompt.
        # Smart aliases change the default if named 'WithConfirm'
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
    begin {
        if( $PSCmdlet.MyInvocation.InvocationName -in @( 'Mint.Invoke-App', 'Invoke-MintilsApp' ) ) {
            $UseConfirm = $false
        }
        if( $PSCmdlet.MyInvocation.InvocationName -match 'WithConfirm' ) {
            $UseConfirm = $True
        }
        'Smart aliases resolved $UseConfirm as {0}' -f $UseConfirm | Write-Debug
        # if( $PSCmdlet.MyInvocation.InvocationName -in @( 'Mint.Invoke-AppConfirm', 'Mint.Invoke-AppWithConfirm' ) ) {
    }
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
