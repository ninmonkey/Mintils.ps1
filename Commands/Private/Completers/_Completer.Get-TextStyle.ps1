function _Completer.Get-TextStyle {
    <#
    .SYNOPSIS
        [internal] Build Tab Completions for "Mint.Get-TextStyle -Style "
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

        [object[]] $Completions = _Get-TextStyle -ListAll | Sort-Object -Unique Name | %{
            $cur = $_
            [string] $ListName = '{0} {1} {2}' -f @(
                $cur.Name
                $cur.SemanticName
                $cur.Category
            )

            $ListName = @( # example: "DimGood [Good.NoBg]""
                    New-Text -fg blue $_.Name
                    New-Text -fg red ('[{0}]' -f $_.SemanticName  )
                ) | Join-String -sep ' '

            [string] $example = New-Text -fg $cur.Fg -bg $cur.bg -Object $cur.Name | Join-String
            [string] $tooltip = @(
                @{
                    # Name = $cur.Name
                    Kind        = $cur.SemanticName
                    Category    = $cur.Category
                    Description = $cur.Description
                    Example     = $Example
                }
                    | Mint.Write-Dict -PassThru -Delim ''
                    | Join-String -sep "`n"

            ) | Join-String -sep ''

            [System.Management.Automation.CompletionResult]::new(
                <# completionText: #> $cur.Name,
                <# listItemText: #> $ListName,
                <# resultType: #> [System.Management.Automation.CompletionResultType]::ParameterValue,
                <# toolTip: #> $tooltip )

        }
        return $Completions
}
