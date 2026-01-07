function Select-MintilsObjectDropBlankProperty {
    <#
    .SYNOPSIS
        Take an object, simplify by skipping Blank values
    .notes
    .example
        > $user = [pscustomobject]@{ Name = 'bob'; Last = "`t  "; NullIsh = $Null }
        > $user | ConvertTo-Json -Compress
            {"Name":"bob","Last":"\t  ","NullIsh":null}

        > $user | Mint.Select-DropBlankProperty | ConvertTo-Json -Compress
            {"Name":"bob"}
    #>
    [CmdletBinding()]
    # [OutputType( [Management.Automation.ApplicationInfo] )]
    [Alias(
        'Mint.Select-DropBlankProperty',
        # 'Mint.Object.FilterBlankProp',
        # 'Mint.Filter-IsBlankProperty',
        'Mint.Object.DropBlankProps' )]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [object] $InputObject
    )
    process {
        if ( [string]::IsNullOrEmpty( $InputObject ) ) { return }

        $info = [ordered]@{}
        # todo: future improvement: preserve PSTypeNames and other meta datab by cloning obj, then dropping props on the original
        #     $info.PSTypeNames = $InputObject.PSTypeNames
        # }
        foreach( $Prop in ( $InputObject.PSObject.Properties | Sort-Object Name  ) ) {
            if(  _Is.Blank -InputObject $Prop.Value ) { continue }
            $info[ $Prop.Name ] = $Prop.Value
        }
        [pscustomobject] $info
    }
}
