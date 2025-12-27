function Invoke-MintilsAppVsCode {
    <#
    .synopsis
        Opens VS Code
    .description
    .example
        > $Profile | Get-Item | Mint.Invoke-App.VsCode
        > $Profile | Get-Item | Mint.VsCode
    .link
        https://code.visualstudio.com/docs/configure/command-line
    #>
    [CmdletBinding()]
    [Alias(
        'Mint.Invoke-App.VsCode',
        'Mint.VsCode'
    )]
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Alias('PSPath', 'Path', 'File', 'Goto')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'FromInput' )]
        [object] $InputObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $FileWithLineNumberString = '',

        # show dynamic help
        [Parameter(Mandatory, ParameterSetName = 'HelpOnly' )]
        [Alias('Help')]
        [switch] $ShowHelp,

        # Log what would be opened, but does not run 'code'
        [Alias('TestOnly')]
        [switch] $WhatIf,

        # write file names to console
        [switch] $PSHost,

        # Jump to the last line using relative line number instead
        [ValidateScript({throw 'nyi'})]
        [switch] $GotoEnd
    )
    begin {
        if( $ShowHelp ) {
            & ( Mint.Require-App 'code' ) @( '--help' )
            New-HyperLink -Text 'docs: vscode commandline' -Uri 'https://code.visualstudio.com/docs/configure/command-line'
        }
    }
    process {
        if( $ShowHelp -or $PSCmdlet.ParameterSetName -eq 'HelpOnly' ) { return }
        [Collections.Generic.List[Object]] $binArgs = @()

        # Attempt to convert input to filepath
        $file = Get-Item -ea 'ignore' $InputObject.File
        if( -not $File ) {
            $file = Get-Item -ea 'ignore' $InputObject
        }
        # or, grab filepath from a command type
        if( -not $File ) {
            $maybe_funcDef = Mint.Find-FunctionDefinition -PassThru -InputObject $InputObject
            if( Test-Path -ea Ignore $maybe_funcDef.File ) {
                $file = Get-Item -ea ignore $maybe_funcDef.File
             }
        }

        if( -not $File ) {
            'File did not exist for type: ' -f ( ( $InputObject )?.GetType() )
                | Write-Error
            return
        }

        # try to use Mint.Find-FuncDef's output
        $binArgs = @(
            '--goto'
            if( $FileWithLineNumberString ) { $FileWithLineNumberString }
            else { $File.Fullname }
            # if( $File.FileWithLineNumberString ) { $File.FileWithLineNumberString }
            # else { $File.Fullname }
        )

        $render_args = $binArgs | Join-String -sep ' ' -op 'invoke "code" => '
        $render_args | Write-Verbose
        if( $WhatIf -or $PSHost ) {
            $render_args | Write-Host -fg 'gray70' -bg 'gray30'
        }

        if( $WhatIf ) { return }
        if( Test-Path $File ) {
            & ( Mint.Require-App 'code' ) @BinArgs
        } else {
            'File did not exist for type: ' -f ( ( $InputObject )?.GetType() ) | Write-Error
            return
        }
    }
    end { }
}
