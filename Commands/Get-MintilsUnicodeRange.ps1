function Get-MintilsUnicodeRange {
    <#
    .synopsis
        Get unicode ranges, as integers or ranges tuple
    .EXAMPLE
        # As summary object
        > Get-MintilsUnicodeRange -UnicodeRangeName ControlPictures
    .EXAMPLE
        # As [Int]
        > Get-MintilsUnicodeRange -UnicodeRangeName ControlPictures -As Int | Join-String -sep ', ' -f '0x{0:x}'
        # Output:

            0x2400, 0x2401, 0x2402, ..., 0x243e, 0x243f
    .EXAMPLE
        # As [String]
        > Get-MintilsUnicodeRange -UnicodeRangeName ControlPictures -As String | Join-String -sep ', '

        # Output:

            ␀, ␁, ␂, ␃, ␄, ..., ␅, ␆, ␇, ␈
    #>
    [Alias('Mint.Get-UnicodeRange')]
    [OutputType( [System.Int32[]], [System.String[]], 'Mintils.Text.UnicodeRanges.Info' )]
    [CmdletBinding()]
    param(
        # Name of UnicodeRanges.
        # to generate: [Text.Unicode.UnicodeRanges] | fime -MemberType Property  | % Name
        [Alias('Name')]
        [Parameter(Mandatory, Position = 0 )]
        [ArgumentCompletions(
            'None', 'All', 'BasicLatin', 'Latin1Supplement', 'LatinExtendedA', 'LatinExtendedB', 'IpaExtensions', 'SpacingModifierLetters', 'CombiningDiacriticalMarks', 'GreekandCoptic', 'Cyrillic', 'CyrillicSupplement', 'Armenian', 'Hebrew', 'Arabic', 'Syriac', 'ArabicSupplement', 'Thaana', 'NKo', 'Samaritan', 'Mandaic', 'SyriacSupplement', 'ArabicExtendedB', 'ArabicExtendedA', 'Devanagari', 'Bengali', 'Gurmukhi', 'Gujarati', 'Oriya', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Sinhala', 'Thai', 'Lao', 'Tibetan', 'Myanmar', 'Georgian', 'HangulJamo', 'Ethiopic', 'EthiopicSupplement', 'Cherokee', 'UnifiedCanadianAboriginalSyllabics', 'Ogham', 'Runic', 'Tagalog', 'Hanunoo', 'Buhid', 'Tagbanwa', 'Khmer', 'Mongolian', 'UnifiedCanadianAboriginalSyllabicsExtended', 'Limbu', 'TaiLe', 'NewTaiLue', 'KhmerSymbols', 'Buginese', 'TaiTham', 'CombiningDiacriticalMarksExtended', 'Balinese', 'Sundanese', 'Batak', 'Lepcha', 'OlChiki', 'CyrillicExtendedC', 'GeorgianExtended', 'SundaneseSupplement', 'VedicExtensions', 'PhoneticExtensions', 'PhoneticExtensionsSupplement', 'CombiningDiacriticalMarksSupplement', 'LatinExtendedAdditional', 'GreekExtended', 'GeneralPunctuation', 'SuperscriptsandSubscripts', 'CurrencySymbols', 'CombiningDiacriticalMarksforSymbols', 'LetterlikeSymbols', 'NumberForms', 'Arrows', 'MathematicalOperators', 'MiscellaneousTechnical', 'ControlPictures', 'OpticalCharacterRecognition', 'EnclosedAlphanumerics', 'BoxDrawing', 'BlockElements', 'GeometricShapes', 'MiscellaneousSymbols', 'Dingbats', 'MiscellaneousMathematicalSymbolsA', 'SupplementalArrowsA', 'BraillePatterns', 'SupplementalArrowsB', 'MiscellaneousMathematicalSymbolsB', 'SupplementalMathematicalOperators', 'MiscellaneousSymbolsandArrows', 'Glagolitic', 'LatinExtendedC', 'Coptic', 'GeorgianSupplement', 'Tifinagh', 'EthiopicExtended', 'CyrillicExtendedA', 'SupplementalPunctuation', 'CjkRadicalsSupplement', 'KangxiRadicals', 'IdeographicDescriptionCharacters', 'CjkSymbolsandPunctuation', 'Hiragana', 'Katakana', 'Bopomofo', 'HangulCompatibilityJamo', 'Kanbun', 'BopomofoExtended', 'CjkStrokes', 'KatakanaPhoneticExtensions', 'EnclosedCjkLettersandMonths', 'CjkCompatibility', 'CjkUnifiedIdeographsExtensionA', 'YijingHexagramSymbols', 'CjkUnifiedIdeographs', 'YiSyllables', 'YiRadicals', 'Lisu', 'Vai', 'CyrillicExtendedB', 'Bamum', 'ModifierToneLetters', 'LatinExtendedD', 'SylotiNagri', 'CommonIndicNumberForms', 'Phagspa', 'Saurashtra', 'DevanagariExtended', 'KayahLi', 'Rejang', 'HangulJamoExtendedA', 'Javanese', 'MyanmarExtendedB', 'Cham', 'MyanmarExtendedA', 'TaiViet', 'MeeteiMayekExtensions', 'EthiopicExtendedA', 'LatinExtendedE', 'CherokeeSupplement', 'MeeteiMayek', 'HangulSyllables', 'HangulJamoExtendedB', 'CjkCompatibilityIdeographs', 'AlphabeticPresentationForms', 'ArabicPresentationFormsA', 'VariationSelectors', 'VerticalForms', 'CombiningHalfMarks', 'CjkCompatibilityForms', 'SmallFormVariants', 'ArabicPresentationFormsB', 'HalfwidthandFullwidthForms', 'Specials'
        )]
        [string] $UnicodeRangeName,

        # Object info, codepoints, or strings ? default: object
        [ValidateSet('Object', 'Int', 'String')]
        [Alias('As')]
        [Parameter()]
        [string] $OutputType = 'Object'
        # [Text.Unicode.UnicodeRanges] $UnicodeRanges # this would not not autocomplete members
    )
    begin {}
    process {}
    end {
        $UnicodeRanges = [Text.Unicode.UnicodeRanges]::$UnicodeRangeName
        if( -not $UnicodeRanges ) { throw "Unhandled range name: '${UnicodeRangeName}'"}
#
        [int] $first = $Unicoderanges.FirstCodePoint
        [int] $last_inclusive = $first + ( $UnicodeRanges.Length - 1 )
        [int] $range_length = $UnicodeRanges.Length

        $info = [pscustomobject]@{
            PSTypeName       = 'mintils.Text.UnicodeRanges.Info'
            Name             = $UnicodeRangeName
            First            = $first
            LastInclusive    = $last_inclusive
            RangeLength      = $range_length
            FirstHex         = '0x' + $first.ToString('x6')
            LastInclusiveHex = '0x' + $last_inclusive.ToString('x6')
        }

        switch( $OutputType ) {
            'Int' {
                $info.First..$Info.LastInclusive
                break
            }
            'String' {
                foreach( $i in $info.First..$Info.LastInclusive ) {
                    [Char]::ConvertFromUtf32( $i )
                }
                break
            }
            default { $Info }
        }
    }
}
