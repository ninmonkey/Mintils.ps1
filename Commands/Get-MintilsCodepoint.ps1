function Get-MintilsCodepoint {
    <#
    .synopsis
        Inspect Codepoints/Runes that are in a string
    .EXAMPLE
        > '👨‍👩‍👦' | Get-MintilsCodepoint | ft

        Index      UniCat Hex   Rune
        -----      ------ ---   ----
            0 OtherSymbol 1f468 👨
            1      Format 200d  ‍    ‍
            2 OtherSymbol 1f469 👩
            3      Format 200d  ‍    ‍
            4 OtherSymbol 1f466 👦

    .LINK
        https://learn.microsoft.com/en-us/dotnet/standard/base-types/character-encoding-introduction
    .link
        https://www.aivosto.com/articles/control-characters.html#ENQ
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.stringinfo?view=net-10.0
    .link
        https://unicode.org/versions/Unicode8.0.0
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.charunicodeinfo?view=net-10.0
    .link
        https://learn.microsoft.com/en-us/dotnet/api/system.globalization.unicodecategory?view=net-10.0
    #>
    [Alias('Mint.Show-Codepoint', 'Mint.Inspect-Unicode')]
    [OutputType( 'Mintils.Rune.Info' )]
    [CmdletBinding()]
    param(
        # Text content
        [Alias('InputObject')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $TextContent
    )
    begin {
        function _Get-RuneInfo {
            <#
            .SYNOPSIS
                convert string into runes
            .NOTES
                todo: clean: move to /Commands/Private
                Or could be moved to TypeData and FormatData. Like Hex should be an int
            #>
            param(
                [Parameter(Mandatory, ValueFromPipeline)]
                [string] $Text
            )
            process {
                [int] $Index = 0
                foreach( $rune in $Text.EnumerateRunes() ) {
                    $str = $rune.ToString()
                    [psCustomObject]@{
                        PSTypeName = 'Mintils.Rune.Info'
                        Index   = $Index++
                        UniCat  = [System.Globalization.CharUnicodeInfo]::GetUnicodeCategory( $rune.Value )
                        Hex     = '{0:x}' -f $Rune.Value
                        Rune    = $rune
                        Display = $str # Redundant, at least for formatdata not typedata
                    }
                }
            }
        }
    }
    process {
        foreach( $line in $TextContent ) { _Get-RuneInfo -Text $line }
    }
}
