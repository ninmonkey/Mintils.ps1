function Find-MintilsSpecialPath {
    <#
    .synopsis
        Sugar that converts paths relative a base dir
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.environment.specialfolderoption
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.environment.getfolderpath
    #>
    [Alias('Mint.Find-SpecialPath')]
    [OutputType( 'Mintils.SpecialPath.Item' )]
    [CmdletBinding()]
    param(
        # [Alias('BasePath')]
        # [Parameter(Mandatory, Position = 0)]
        # $RelativeTo,

        # # Strings / paths to convert
        # [Alias('PSPath', 'FullName', 'InObj')]
        # [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        # [string[]] $Path,

        # [ValidateSet('EnvVar', 'SpecialFolder')]
        # [string[]] $Sources
    )
    process {
        $specialFolderKeys = [enum]::GetValues( [System.Environment+SpecialFolder] )

        foreach ($specialKey in $specialFolderKeys ) {
            <#
                > [enum]::GetNames( [System.Environment+SpecialFolderOption] ) -join ', '
                # out: None, DoNotVerify, Create
            #>
            $resolveSpecial = [Environment]::GetFolderPath( <# SpecialFolder folder #> $specialKey )
            # $resolveSpecial2 = [Environment]::GetFolderPath(
            #     <# SpecialFolder folder #> $specialKey,
            #     <# SpecialFolderOption option; Default: 'None' #> 'None'
            # )
            [pscustomobject]@{
                PSTypeName = 'Mintils.SpecialPath.Item'
                Name       = $specialKey
                Exists     = Test-Path $resolveSpecial
                Type       = 'SpecialFolder'
                Path       = $ResolveSpecial
            }
        }
        $envVarPaths = @( Get-ChildItem env: | Where-Object { Test-Path $_.Value } )

        foreach ( $item in $EnvVarPaths ) {
            [pscustomobject]@{
                PSTypeName = 'Mintils.SpecialPath.Item'
                Name       = $item.Name
                Exists     = Test-Path $Item.Value
                Type       = 'EnvVar'
                Path       = $item.Value
            }
        }
    }

}
