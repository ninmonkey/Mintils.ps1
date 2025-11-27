<#
.EXAMPLE
    . .\Build\mintils.Build.Module.ps1; $commands_summary ;
#>
$myFile       = $MyInvocation.MyCommand.ScriptBlock.File
$myModuleName = 'mintils'
$myRoot       = $myFile | Split-Path | Split-Path
Push-Location -Stack 'mintils.build' $myRoot
$commands_public   = @(
    # to recurse or not ?
    @( foreach ($potentialDirectory in 'Commands') {
        Join-Path $myRoot $potentialDirectory | Get-ChildItem -ea ignore
    })
    | Where-Object name -NotMatch '^Scrap'
    | ? Extension -in '.ps1' #, '.psm1', '.psd1'
)

[Collections.Generic.List[object]] $commands_summary = @()
$commands_summary.AddRange(
    @(
        $commands_public
        | %{
            $item = $_
            [pscustomobject]@{
                PSTypeName   = 'build.mintils.command.public'
                Public        = $true
                Name          = $Item.Name
                Size          = '{0:n2} kb' -f ( $Item.Length / 1kb )
                LastWriteTime = $Item.LastWriteTime
                # Documentation = ''
                # HasRequiresStatment        = $false
                # HasUsingNamespaceStatement = $false
            }
        }
    )
)

$destinationRoot = $myRoot

$commands_public
    | Join-String -f "`n {0}" -op 'Commands' -p {
        [System.IO.Path]::GetRelativePath( $myRoot, $_.FullName )
    }
    | Write-Host -fg 'magenta'

Pop-Location -Stack 'mintils.build'

write-warning 'WIP: Now drop files

  - [0] are not ps1 types
  - [1] that are prefixed "scrap"

'
return
if ($commands_public) {
    $myFormatFile = Join-Path $destinationRoot "$myModuleName.format.ps1xml"
    $commands_public
        | Out-FormatData -Module $MyModuleName
        | Set-Content $myFormatFile -Encoding UTF8 -Confirm
    Get-Item $myFormatFile
}

$types = @(
    # Add your own Write-TypeView statements here
    # or declare them in the 'Types' directory
    Join-Path $myRoot Types
        | Get-Item -ea ignore
        | Import-TypeView

)

if ($types) {
    $myTypesFile = Join-Path $destinationRoot "$myModuleName.types.ps1xml"
    $types
        | Out-TypeData
        | Set-Content $myTypesFile -Encoding UTF8 -Confirm

    Get-Item $myTypesFile
}
Pop-Location
