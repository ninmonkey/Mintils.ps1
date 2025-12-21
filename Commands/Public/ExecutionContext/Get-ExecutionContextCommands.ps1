function Get-MintilsExecutionContextCommands {
    <#
    .SYNOPSIS
        sugar that wraps "$ExecutionContext.InvokeCommand.GetCommands"
    .notes
        Maybe allow returning (Get-Item) as an option
    .example
        # default is all types
        > 'git' | Mint.ExContext.Get-Commands

        # limit to applications / not functions
        > 'git' | Mint.ExContext.Get-Commands -CommandTypes Application
    .example
        # wildcard search
        > Mint.ExContext.Get-Commands -Name '*git*' -NameIsPattern |ft
    .link
        Mintils\Mint.ExecutionContext-Get-CommandName
    .link
        Mintils\Mint.ExecutionContext.Get-Commands
    .link
        System.Management.Automation.CommandInvocationIntrinsics
    #>
    [Alias(
        'Mint.ExecutionContext.Get-Commands',
        'Mint.ExContext.Get-Commands'
    )]
    [OutputType( [Management.Automation.CommandInfo] )]
    [CmdletBinding()]
    # [OutputType( [Collections.Generic.List[String]] )]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Name,

        [Management.Automation.CommandTypes] $CommandTypes = 'All', # all

        # name uses wildcard pattern, otherwise exact match
        [switch] $NameIsPattern
    )
    process {
        $ExecutionContext.InvokeCommand.GetCommands(
            <# string #> $Name,
            <# CommandTypes #> $CommandTypes,
            <# bool #> $NameIsPattern )
    }
}
