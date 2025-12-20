function Find-MintilsFunctionDefinition {
    <#
    .synopsis
        Find a function, then open vscode to that exact line number
    .NOTES
        .
    .example
        # Open in vs code
        gcm EditFunc | EditFunc -PassThru -AsCommand
    .EXAMPLE
        # Get path to your prompt
        > gcm prompt | EditFunc -PassThru
    .EXAMPLE
        # edit the file with your prompt defined
        > gcm prompt | EditFunc
    .Example
        # Converts alias/etc into command info .
        gcm goto | EditFunc -PassThru -AsCommand
        gcm goto | EditFunc -AsCommand
    #>
    [Alias('Mint.Find-FunctionDefinition', 'EditFunc')]
    [OutputType( 'System.IO.FileInfo', 'System.Management.Automation.CommandInfo' )]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [Object] $InputObject,

        # output paths found, else, run in vs code. OutputType: [FileInfo]
        [Alias('WithoutAutoOpen')]
        [switch] $PassThru,

        # output command rather than filepath. OutputType: [CommandInfo], [FunctionInfo]
        [switch] $AsCommand
    )
    begin {
        function CoerceCommand {
            # Get filepath from command, scriptblock, alias, etc.
            param(
                [Parameter(Mandatory)] $Obj
            )
            if( $Obj -is [Management.Automation.AliasInfo] )  {
                $resolve = Get-Command $Obj.Definition
                $msg = '    => start: {0} of "{1}"' -f @(
                    $resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    $resolve.ScriptBlock.File
                )

                $msg | New-Text -fg 'gray80' -bg 'gray30'
                    # | Write-information # for now just write host, to simplify passing InfaAction or not
                    | Write-Host

                if( $AsCommand ) { return $Resolve }
                return Get-Item $resolve.ScriptBlock.File
            }
            if( $Obj -is [Management.Automation.FunctionInfo] )  {
                $Resolve = $Obj
                $msg = '    => start: {0} of "{1}"' -f @(
                    $resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    $resolve.ScriptBlock.File
                )
                $msg | New-Text -fg 'gray80' -bg 'gray30'
                    # | Write-information # for now just write host, to simplify passing InfaAction or not
                    | Write-Host

                if( $AsCommand ) { return $Resolve }
                return Get-Item $resolve.ScriptBlock.File
            }
            'Unhandled converting command path from type: {0}' -f $Obj.GetType().Name  | Write-Warning
            return $Null
        }
    }

    process {
        $query = CoerceCommand -Obj $InputObject
        foreach($Item in $query) {
            if( $PassThru ) { return $item }
            code --goto ( Get-Item -ea 'stop' $item.FullName )
        }

    }
}
