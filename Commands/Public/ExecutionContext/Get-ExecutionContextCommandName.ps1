function Get-MintilsExecutionContextCommandName {
    <#
    .SYNOPSIS
        sugar that wraps "$ExecutionContext.InvokeCommand.GetCommandName"
    .notes
        Maybe allow returning (Get-Item) as an option
    .link
        System.Management.Automation.CommandInvocationIntrinsics
    #>
    [Alias(
        'Mint.ExecutionContext.Get-CommandName',
        'Mint.ExContext.Get-CommandName'
        # 'Mint.Get-ExContextCommandName'
    )]
    [CmdletBinding()]
    # [OutputType( [Collections.Generic.List[String]] )]
    param(
        [Parameter(mandatory, ValueFromPipeline)]
        [string] $Name,
        [bool] $NameIsPattern,

        # output filepath as name only
        [switch] $AsText
    )
    process {
        $query = $ExecutionContext.InvokeCommand.
            GetCommandName( $Name, $NameIsPattern, $true )
        if( $asText ) { return $query }

        Get-Command ( $Query | Get-Item )
    }
}
