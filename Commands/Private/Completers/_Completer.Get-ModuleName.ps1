function _Completer.Get-ModuleName {
    <#
    .SYNOPSIS
        [internal] Build Tab Completions for "Get-Module <name>" or "Remove-Module <name>" etc
    .EXAMPLE
        # verify external
        > $str = 'Mint.Get-TextStyle -StyleName '
        > ( $tab2 = TabExpansion2 -inputScript $str -cursorColumn ($str.Length - 0) ).CompletionMatches
    #>
    param ( $commandName,
            $parameterName,
            $wordToComplete,
            $commandAst,
            $fakeBoundParameters )

    # if ($fakeBoundParameters.ContainsKey('Type')) {
    # ( Get-Module | Group-Object Name -NoElement -AsHashTable ).Keys | Sort-Object
    [System.Management.Automation.PSModuleInfo[]] $modules = Get-Module | Sort-Object Name -Unique

    function _render.Tooltip {
        [OutputType( [string] )]
        param(
            [System.Management.Automation.PSModuleInfo] $PSModuleInfo,
            [switch] $WithoutColor
        )
        if( -not $PSmoduleInfo ) { return '' }

        $q = $PSmoduleInfo | Select-Object *name*, *url*, *auth*, *mod*type*, *type*, *auth*, *repo*, *source*, *uri* -ea Ignore
        [string] $Render = ''
        if( -Not $WithoutColor ) {
            $Render = $q
                # | Mint.Object.DropBlank
                | Mint.Select-DropBlankProperty
                | Mint.Convert.Dict.FromObject
                | Mint.Write-Dict -PassThru
                | Join-String -sep "`n"
        } else {
            $Render = $q | Format-List | Out-String | Join-String -sep "`n"
        }
        return $Render
    }

    foreach( $mod in $modules ) {
        # [string] $tooltip = $mod.Version, $mod.Description -join '. '
        [System.Management.Automation.CompletionResult]::new(
            $mod.Name,
            $mod.Name,
            [System.Management.Automation.CompletionResultType]::ParameterValue,
            ( _render.Tooltip $mod )
        )
    }
}
