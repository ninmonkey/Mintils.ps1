function Format-MintilsRelativePath {
    <#
    .synopsis
        Sugar that converts paths relative a base dir
    .example
        # Print paths relative the current Directory
        gci . -Depth 2 | Mint.Format-RelativePath
    .example
        > Get-Item 'H:\github_fork\Pwsh\SeeminglyScience👨\EditorServicesProcess', 'H:\github_fork\Pwsh\Trackd👨'
            | Mint.Format-RelativePath 'H:\github_fork\Pwsh'

        SeeminglyScience👨\EditorServicesProcess
        Trackd👨
    #>
    [Alias('Mint.Format-RelativePath')]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        [Alias('BasePath')]
        [Parameter(Position = 0)]
        $RelativeTo = '.',

        # Strings / paths to convert
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]] $Path,

        # Emit an object with path properties, including the raw original path
        [Alias('PassThru')]
        [switch] $AsObject
    )
    process {
        $RelativeTo = Get-Item $RelativeTo
        foreach( $item in ( $Path | Convert-Path ) ) {
            $relPath = [System.IO.Path]::GetRelativePath(
                <# string: relativeTo #> $RelativeTo,
                <# string: path #>  $Item )

            if( -not $AsObject ) {
                $relPath
                continue
            } else {
                [pscustomobject]@{
                    PSTypeName = 'Mintils.RelativePath'
                    Path       = $relPath
                    Original   = $Item
                    RelativeTo = $RelativeTo
                }
                continue
            }
        }
    }
}
