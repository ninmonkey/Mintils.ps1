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
    [Alias('Mint.Find-FunctionDefinition', 'EditFunc', 'Mint.Find-FuncDef' )]
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
    }
    process {
        $found = _Resolve-CommandFileLocation -InputObject $InputObject
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
    }
}
