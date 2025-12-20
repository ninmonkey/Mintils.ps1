

function Get-MintilsTypeHelp {
    <#
    .SYNOPSIS
        Find dotnet docs for a type
    .NOTES
    .link
        Mintils\Find-MintilsTypeName
    .link
        Mintils\Get-MintilsTypeHelp
    #>
    [Alias('Mint.Get-TypeHelp')]
    [Cmdletbinding( DefaultParameterSetName='FromString' )]
    param(
        # [Alias('InObj')]
        # [Parameter( Mandatory, ParameterSetName='FromObject', Position = 0, ValueFromPipeline )]
        # [object] $FromObject,
        # # [type] $FromTypeData

        [Parameter( Mandatory, ParameterSetName='FromString', Position = 0, ValueFromPipeline )]
        [Alias('Name')]
        [string] $TypeName,

        # Open url
        [Alias('Online')]
        [switch] $Open
    )

    begin {
        $PSCmdlet.ParameterSetName | Join-String -f 'using ParamSet: {0}' | Write-Verbose

        function _UrlFromName {
            param( [string] $Name )


            [uri] $url = 'https://learn.microsoft.com/en-us/dotnet/api/{0}?view=net-10.0' -f $Name

            return $Url
        }
    }
    process {

        [string] $shortName = ''
        switch( $PSCmdlet.ParameterSetName ) {
            # 'FromObject' {
            #     # $type = $FromObject.GetType()
            #     break
            # }
            'FromString' {
                $shortName = $TypeName
                break
            }
            default {
                throw "Unhandled ParameterSet: $( $PSCmdlet.ParameterSetName )"
            }
        }

        $shortName | Join-String -op 'Shortname: ' | Write-Verbose

        $url  = _urlFromName -Name $shortName
        $info = [pscustomobject]@{
            PSTypeName = 'Mintils.TypeName.Url'
            Type       = $shortName
            Url        = $Url
        }
        if( $Open ) {
            Start-Process -FilePath ( $Info.Url.ToString() )
        }
        return $Info
    }
}
