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
        $binCode = Mint.Require-AppInfo -Name 'code'
        write-warning 'WIP: New Find-Func implementation'
    }
    process {
        $found = _ResolveCommandFileLocation -InputObject $InputObject -Verbose
        if( $PassThru ) { $found ; return ; }

        $binArgs = @(
            '--goto', $Found.FileWithLineNumberString
        )

        if( -not $PassThru ) {
            $binArgs
                | Join-String -sep ' ' -op '    invoke code => '
                | Write-Host -fg 'gray80' -bg 'gray30'
        }

        if( -not (Test-Path $found.File )) {
            throw "Filepath not found for: $( $InputObject.GetType() )"
        }

        & $binCode @( '--goto', $Found.FileWithLineNumberString )
        # throw "old logic starts here"
        # $query = _Resolve-CommandFileLocation -InputObject $InputObject
        # foreach($Item in $query) {
        #     if( $PassThru ) { $item; continue; }
        #     if( -not (Test-Path $Item.FullName ) ) {
        #         $msg = '.FullName not found on Item: {0}' -f $Item
        #         $msg | Write-Warning
        #         $msg | write-error
        #         continue
        #     }
        #     $binArgs = @(
        #         '--goto'
        #         ( Get-Item -ea 'stop' $item.FullName )
        #     )

        #     if( $item.StartLineNumber -and $item.Path ) {
        #         $binArgs = @(
        #             '--goto'
        #             '{0}:{1}' -f @(
        #                 Get-Item -ea 'stop' $Item.Path.FullName
        #                 $item.StartLineNumber
        #             )
        #         )
        #     }
        #     if( -not $PassThru ) {
        #         $binArgs
        #             | Join-String -sep ' ' -op '    invoke code => '
        #             | Write-Host -fg 'gray80' -bg 'gray30'
        #     }

        #     & $binCode @binArgs
        # }

    }
}
