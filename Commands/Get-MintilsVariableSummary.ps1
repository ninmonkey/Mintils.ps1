function Get-MintilsVariableSummary {
    <#
    .SYNOPSIS
        summarize and search for variables in scope, without errors when missing
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -HasPrefix 'PS'
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -HasPrefix host -HasSuffix 'preference'
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -PartialNames style
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -BeginsWith '_'  -PartialNames 'editorservices', 'vscode'
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -PartialNames 'last' -Scope script # nothing
        Pwsh> Mint.Get-VariableSummary -PartialNames 'last' -Scope global # returns $LASTEXITCODE
    #>
    [CmdletBinding()]
    [Alias('Mint.Get-VariableSummary')]
    [OutputType( 'Mintils.Variable.Summary' )]
    param(
        # exact match
        [ArgumentCompletions(
            'GitLogger', 'Logs', 'CurMetric' )]
        [string[]] $ExactNames, # ( 'curMetric', 'logs', 'GitLogger' ),

        # wildcard match
        [ArgumentCompletions(
            'Git', 'GitLogger', '__', 'PS' )]
        [string[]] $PartialNames,

        # wildcard prefix at the start, ex: 'dunder'
        [Alias('BeginsWith')]
        [ArgumentCompletions(
            '__', 'PS' )]
        [string[]] $HasPrefix,

        # wildcard prefix # dunder?
        [Alias('EndsWith')]
        [ArgumentCompletions(
            'preference', 'culture', 'Parameters' )]
        [string[]] $HasSuffix,

        # By name or depth as [int]. Or implicit default.
        [ArgumentCompletions(
            'script', 'global', 0, 1, 2, 3, 4, 5
        )]
        [string] $Scope,

        # Future: Instead of scope 0, you can say -FromTop 0 to get the top most
        # scope. ( cmdlet handles iterating each until an exception is thrown. silently for you.)
        [ValidateScript({throw 'nyi: Relative offset for scope fromTop'})]
        [ArgumentCompletions( 0, 1, 2, 3)]
        [uint] $DepthFromTop,

        [Alias('DebugQuery')]
        [switch] $ShowQuery
    )

    [System.Collections.Generic.List[Object]] $names = @()
    $getVars = @{
        ErrorAction = 'ignore'
    }

    if( $MyInvocation.BoundParameters.ContainsKey('Scope') ) {
        $getVars['Scope'] = $Scope
    }
    if( $MyInvocation.BoundParameters.ContainsKey('ExactNames') ) {
        $names.addRange( @( $ExactNames ))
    }
    if( $MyInvocation.BoundParameters.ContainsKey('PartialNames') ) {
        $names.addRange( @(
            $PartialNames.forEach({ "*${_}*"  })
        ))
    }
    if( $MyInvocation.BoundParameters.ContainsKey('HasPrefix') ) {
        $names.addRange( @(
            $HasPrefix.forEach({ "${_}*"  })
        ))
    }
    if( $MyInvocation.BoundParameters.ContainsKey('HasSuffix') ) {
        $names.addRange( @(
            $HasSuffix.forEach({ "*${_}"  })
        ))
    }

    if( $Names.count -gt 0 ) {
        $getVars['Name'] = $names
    }

    if( $ShowQuery ) {
        ( $getVars
            | ConvertTo-Json -Depth 4 ) -split '\r?\n'
            | Join-String -f "`n    {0}" -os "`n"
            | Join-String -op "call Get-Variable => "
            | Write-Host -fg $Color.InfoDark -bg 'gray25'
    }

    $found =
        try {
            Get-Variable -ea ignore @getVars # Test whether I must use stop to catch
        } catch {
            if($_.Exception.Message -match 'scope.*exceeds.*number' ) {
                'Scope exceeds max depth: -Scope {0}' -f $getVars['Scope']
                return
            }
            # the rest is unexpected
            throw
        }
    if( $found.count -eq 0 ) {
        '0 matches found!' | Write-Host -fg 'gray60'
        return
    }
    $found <# todo: convert to a type data instead #>
        | %{
            $tinfo      = ( $_.Value)?.GetType()
            $abbrName   = ($tinfo).Name
            $abbrBounds = @(
                if($_.Value -is [Array]) { 'IsArray' }
                'Count: {0}' -f $_.Value.Count
                'Len: {0}'   -f $_.Value.Length
            ) -join ', '

            [pscustomobject]@{
                PSTypeName = 'Get-Variable.SummaryResult'
                Name     = $_.Name
                TypeAbbr = $abbrName   # ( $_.Value)?.GetType().Name
                Bounds   = $abbrBounds
                Instance = $_.Value
            }
        }
        | Sort-Object -Property Name
}
