function Find-MintilsAppCommand {
    <#
    .synopsis
        Find the location and versions of Application/CommandInfo/native commands
    .notes
        When using "Gcm -All", this only tests "--version" for the first of each group
    .example
        Mint.Find-AppCommand 'npm', 'node', 'pnpm'
    .example
        # Syntax highlight /w bat
        Find-MintilsAppCommand 'npm', 'node', 'pwsh' -AsOutputType yaml -withoutAll | bat -l yml
    .example
        # basic, with extra sources
        Find-MintilsAppCommand 'npm', 'node', 'pwsh' | ft
    .example
        Find-MintilsAppCommand 'npm', 'node', 'pwsh' -FilterCommandType Application, ExternalScript
    .link
        Mintils\Find-MintilsAppCommand
    .link
        Mintils\Require-MintilsFileExists
    .link
        Mintils\Require-MintilsAppExists
    #>
    [Alias('Mint.Find-AppCommand')]
    [OutputType( 'Mintils.AppCommand.Info' )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]] $CommandName,

        # Filter by "Get-Command -CommandTypes"
        [Management.Automation.CommandTypes[]] $FilterCommandType,

        # Also Convert to yaml/json before output. Drops properties that don't serialize cleanly by default.
        # object and default are equal to using -PassThru
        [ArgumentCompletions('yaml', 'json', 'object')]
        [string] $AsOutputType,

        # skips -all
        [Alias('FirstOnly')]
        [switch] $withoutAll
    )
    begin {
        [Collections.Generic.List[Object]] $summary = @()
    }
    process {
        $splat = @{
        }
        if( -not $WithoutAll ) { $splat['All'] = $True }
        if( $null -ne $FilterCommandType ) { $splat.CommandType = $FilterCommandType}

        foreach( $curName in $CommandName ) {
            [int] $orderId = 0
            $cmdInfo = @( Get-Command @splat -Name $curName )

            # for now, only capture version of the first item
            $maybeVer = & $cmdInfo[0] @('--version')
            foreach( $item in $cmdInfo ) {
                $psco = [pscustomobject]@{
                    PSTypeName    = 'Mintils.AppCommand.Info'
                    Name          = $curName
                    Version       = $maybeVer
                    Path          = $Item.Source
                    CommandType   = $item.GetType().Name
                    CommandInfo   = $Item
                    GroupOrder    = $orderId++
                    LastWriteTime = (Get-Item $Item.Source).LastWriteTime
                }
                # signify version is duplicate on the rest
                $maybeVer = ''
                $summary.Add( $psco )
            }
        }
    }
    end {
        switch( $AsOutputType ) {
            'json' {
                $summary
                    | Select-Object -ExcludeProp 'CommandInfo'
                    | ConvertTo-Json -depth 2
                break
             }
            'yaml' {
                $summary
                    | Select-Object -ExcludeProp 'CommandInfo'
                    | YaYaml\ConvertTo-Yaml
                break
             }
            default { $summary }
        }

    }
}
