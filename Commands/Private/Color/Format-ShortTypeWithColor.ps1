function _Format.Type.RenderTypeColor {
    <#
    .SYNOPSIS
        Main entry point for short names, at least for [internal] uses
    .EXAMPLE
        > _Format.Type.RenderTypeColor (gi .)
        > _Format.Type.RenderTypeColor (gi $PROFILE)
    .EXAMPLE
        > $fileSet = Mint.New-HashSet.FileInfo -InputCollection @( gi $PROFILE; gi . )
        > _Format.Type.RenderTypeColor $fileSet
        > _Format.Type.RenderTypeColor $fileSet -NoColor
    #>
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [object] $InputObject,

        [Alias('NoColor', 'Simple' )]
        [switch] $WithoutColor
    )
    process {
        'refactor to Mintils: {0}' -f $PSCommandPath | Write-Warning
        if($Null -eq $InputObject) { return "`u{2400}" }
        _Render.Type.RenderSingleType -Target $InputObject -WithoutColor:$( $WithoutColor )
    }
}
function _Render.Type.RenderSingleType {
    <#
    .SYNOPSIS
        [internal] func to render
    .link
        _Format.Type.RenderTypeColor
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [AllowNull()]
        [AllowEmptyCollection()]
        [Parameter(Mandatory, ValueFromPipeline )]
        [Alias('InObj')] [object] $Target,

        [Alias('NoColor', 'Simple' )]
        [switch] $WithoutColor
    )
    begin {
        $NullSymbol = "`n{2400}"
        'refactor to Mintils: {0}' -f $PSCommandPath | Write-Warning
    }
    process {
        if( $Null -eq $Target ) { return $NullSymbol }
        $Tinfo = $Target -is [type] ? $Target : $Target.GetType()

        [string] $Base = $Tinfo.Name -replace '`\d+', ''
        [string] $Render = ''

        if( [string]::IsNullOrWhiteSpace( $base ) ) {
            throw "Summarizing type failed for: '$( $Target.GetType )'"
        }
        if( $Tinfo.GenericTypeArguments.Count -eq 0 ) {
            $render = "${Base}"
            return $Render
        }
        # warning: does not limit max depth, potential explosion when params are generics too
        $SummarizedGenericArgs = $Tinfo.GenericTypeArguments | %{
            _Render.Type.RenderSingleType -Target $_
                # | Join-String -sep ' ' -op '[ ' -os ' ]'
                | Join-String -sep ' '
        } | Join-String -f '{0}'

        $render = "${Base}<| ${SummarizedGenericArgs} |>" # or
        $render = "${Base}< ${SummarizedGenericArgs} >"

        $FgDim = "${fg:gray70}"
        $FgDim = "${fg:gray60}"
        $FgOp = "${fg:gray80}"
        $fgInnerType = "${fg:skyblue}"

        $render_fancy = "${fgDim}${Base}${fg:clear}${fgOp}<${fg:clear} ${fgInnerType}${SummarizedGenericArgs}${fg:clear} ${fgOP}>${fg:Clear}"
        <# old format:
            $SummarizedGenericArgs = $Tinfo.GenericTypeArguments | %{
                _Render.Type.RenderSingleType -Target $_ | Join-String -sep ' ' -op '[ ' -os ' ]'
            } | Join-String -f '< {0} >'

            $render = "${Base} ${SummarizedGenericArgs}"
        #>
        return $WithoutColor ? $Render : $Render_fancy # ( $_)?.GetType().Name ?? "`u{2400}"
    }

}
