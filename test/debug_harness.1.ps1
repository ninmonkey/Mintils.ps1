#requires -PSEdition Core
#requires -Modules pansies, ClassExplorer
'Rebuild...'  | Write-Verbose -Verbose
'Import...' | Write-Verbose -Verbose


. 'H:\data\2025\GitRepos.🐒\Mintils.ps1\Commands\Get-MintilsTypeHelp.ps1'

Mint.Get-TypeHelp 'System.TimeZoneInfo'
Mint.Get-TypeHelp -Name System.Int64 -Verbose

'Find invalid type using -WithoutError' | Write-verbose -verbose
Find-MintilsTypeByName 'TimeZoneInfoffd' -WithoutError

'Find _fromMethod urls' | Write-Verbose -Verbose
function _fromMethod {
    param(
        $TypeInfo,
        [string] $MethodName
    )

    # $tinfo = [timezoneinfo]
    $method_info = $TypeInfo | Fime $MethodName | Select -first 1
    if( -not $Method_info ) {
        throw "Method not found: '$MethodName' for type '${TypeInfo}'"
    }

    $Method_info
        | Join-string { $_.DeclaringType, $_.Name -join '.' }
    #     $fimfo = $tinfo | Fime GetSystemTimeZones | Select -First 1
    # $fimfo
}

( $try1 = _fromMethod -TypeInfo ([System.TimeZoneInfo]) -MethodName 'GetSystemTimeZones' )

Mint.Get-TypeHelp -TypeName $try1

(Mint.Get-TypeHelp -TypeName $try1).Url.tostring()

( _fromMethod -TypeInfo ([System.TimeZoneInfo]) -MethodName 'GetSystemTimeZones' | Mint.Get-TypeHelp ).Url.ToString()
