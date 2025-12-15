function Get-MintilsUriQuery {
    <#
    .synopsis
        Parse a [Uri]'s query string, returning as a hashtable
    .NOTES
        I couldn't think of a good name.

        Check out related types:
            [Web.HttpUtility] -> ParseQueryString, HtmlEncode/Decode, HtmlAttributeEncode/Decode
            [UriParser]
            [UriBuilder]
            [UriComponents]

    .EXAMPLE
    #>
    [OutputType( [object] )]
    [Alias(
        # I need a better name
        'Get-MintilsUrlQuery',
        'Mint.Link.Query',
        'Mint.Link.ParseQuery',
        'Mint.Url.ParseQuery',
        'Get-MintilsUriQueryKeys',
        'Get-MintilsUrlQueryKeys',
        'Mint.Get-UriQueryKeys'
        # 'Mint.Url-KeyNames',
        # 'Mint.Uri-KeyNames'
    )]
    # [OutputType( )]
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('Url', 'Uri', 'Obj', 'Href', 'InputObject' )]
        [object] $InputUri,

        # use [Uri.PathAndQuery] vs the default: [Uri.Query]
        [switch] $IncludePath,

        # Return keys, skip value names
        [switch] $KeysOnly
    )
    begin {}
    process {

        # only emit query key names
        if( $IncludePath ) {
            $parsed = [System.Web.HttpUtility]::ParseQueryString( ([uri] $InputUri).PathAndQuery )
        } else {
            $parsed = [System.Web.HttpUtility]::ParseQueryString( ([uri] $InputUri).Query )
        }
        if( $KeysOnly ) { return $parsed.Keys }

        $info = [ordered]@{}

        foreach( $key in $parsed.Keys ) {
            $info[ $key ] = $parsed[ $Key ]
        }
        [pscustomobject] $Info
        # or: ParseQueryString( ([uri] $InputUri).Query, $Encoding )
    }
    end {

    }
}
