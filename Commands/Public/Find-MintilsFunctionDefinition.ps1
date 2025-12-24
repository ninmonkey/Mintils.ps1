function Find-MintilsFunctionDefinition {
    <#verbo
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
                [Management.Automation.AliasInfo] $Cur = $Obj

                if( $Cur.ResolvedCommand ) {
                    $Cur.ResolvedCommand.Name
                        '    => resolved: "{0}" -> {1}' -f @(
                            $obj.Name,
                            $Obj.ResolvedCommandName
                        )
                        | Write-Verbose
                    return ( CoerceCommand -Obj $Cur.ResolvedCommand )
                } else {
                    '    => "{0}.ResolvedCommand" was falsy ' -f $Obj.Name
                        | Write-Verbose
                }
                # CoerceCommand -Obj $Obj.ReferencedCommand

                # $Resolve = Get-Command $Cur.Definition
                # [System.Management.Automation.CommandInfo] $

                $msg = '    => start: {0} of "{1}"' -f @(
                    $Resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    $Resolve.ScriptBlock.File
                )

                if( -not $PassThru ) {
                    $msg | New-Text -fg 'gray80' -bg 'gray30' | Write-Host
                }

                # throw 'nyi'

                if( $AsCommand ) { return $Resolve }
                return Get-Item $Resolve.ScriptBlock.File
            }
            if( $Obj -is [Management.Automation.FunctionInfo] )  {
                [Management.Automation.FunctionInfo] $Resolve = $Obj

                $msg = '    => start: {0} of "{1}"' -f @(
                    $Resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    $Resolve.ScriptBlock.File
                )
                if( -not $PassThru ) {
                    $msg | New-Text -fg 'gray80' -bg 'gray30' | Write-Host
                }
                if( $AsCommand ) { return $Resolve }

                $file = Get-Item $resolve.ScriptBlock.File
                $info = [ordered]@{
                    PSTypeName        = 'mintils.FunctionInfo.withExtent'
                    FileName          = $file.Name
                    Path              = $File
                    FullName          = $File.FullName
                    StartLineNumber   = $Resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    EndLineNumber     = $Resolve.ScriptBlock.Ast.Extent.EndLineNumber
                    StartColumnNumber = $Resolve.ScriptBlock.Ast.Extent.StartColumnNumber
                    EndColumnNumber   = $Resolve.ScriptBlock.Ast.Extent.EndColumnNumber
                    FromObject        = $Resolve
                }
                return [pscustomobject] $Info
            }
            'Unhandled converting command path from type: {0}' -f $Obj.GetType().Name
                | Write-Warning
            return $Null
        }
        $binCode = Mint.Require-AppInfo -Name 'code'
    }
    process {
        $query = CoerceCommand -Obj $InputObject
        foreach($Item in $query) {
            if( $PassThru ) { $item; continue; }
            if( -not (Test-Path $Item.FullName ) ) {
                $msg = '.FullName not found on Item: {0}' -f $Item
                $msg | Write-Warning
                $msg | write-error
                continue
            }
            $binArgs = @(
                '--goto'
                ( Get-Item -ea 'stop' $item.FullName )
            )

            if( $item.StartLineNumber -and $item.Path ) {
                $binArgs = @(
                    '--goto'
                    '{0}:{1}' -f @(
                        Get-Item -ea 'stop' $Item.Path.FullName
                        $item.StartLineNumber
                    )
                )
            }
            if( -not $PassThru ) {
                $binArgs
                    | Join-String -sep ' ' -op '    invoke code => '
                    | Write-Host -fg 'gray80' -bg 'gray30'
            }

            & $binCode @binArgs
        }

    }
}
