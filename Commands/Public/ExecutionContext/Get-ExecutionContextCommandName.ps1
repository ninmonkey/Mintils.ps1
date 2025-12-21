function Get-MintilsExecutionContextCommandName {
    <#
    .SYNOPSIS
        sugar that wraps "$ExecutionContext.InvokeCommand.GetCommandName"
    .notes
        Maybe allow returning (Get-Item) as an option
    .example
        > Mint.ExContext.Get-CommandName -Name py
        # py.exe
    .EXAMPLE
        > 'py', 'fd', 'dsf' | Mint.ExContext.Get-CommandName
    .link
        Mintils\Mint.ExecutionContext-Get-CommandName
    .link
        Mintils\Mint.ExecutionContext.Get-CommandNames
    .link
        System.Management.Automation.CommandInvocationIntrinsics
    #>
    [Alias(
        'Mint.ExecutionContext.Get-CommandName',
        'Mint.ExContext.Get-CommandName'
    )]
    [CmdletBinding()]
    # [OutputType( [Collections.Generic.List[String]] )]
    param(
        [Parameter(mandatory, ValueFromPipeline)]
        [string] $Name,
        [switch] $NameIsPattern,

        # output filepath as name only
        [switch] $AsText
    )
    process {
        $query = $ExecutionContext.InvokeCommand.
            GetCommandName( $Name, $NameIsPattern, $true )
        if( $query.count -eq 0 ) { return }

        if( $asText ) { return $query }

        Get-Command ( $Query | Get-Item )
    }
}
