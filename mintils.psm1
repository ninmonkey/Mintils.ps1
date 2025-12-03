function Enable-MintilsDefaultAlias {
    <#
    .SYNOPSIS
        Load common aliases, only if user opts-in by calling this.
    .NOTES
        Because this is from a module, you might need to use 'Set-alias -Force' and mabye '-Scope Global'
    #>
    [Alias('Mint.Enable-DefaultAlias')]
    [Cmdletbinding()]
    param(
        # required for readonly
        [switch] $Force,

        [ArgumentCompletions('Global', 'Local', 'Script')]
        [string] $Scope = 'Global'
    )

    $splat = @{
        PassThru = $True
    }
    # note: PSBoundParameters does not contain default values
    if( $PSBoundParameters.ContainsKey('Force') ) { $splat.Force = $Force }
    if( $PSBoundParameters.ContainsKey('Scope') -or (-not [string]::IsNullOrWhiteSpace( $Scope ) ) ) {
        $splat.Scope = $Scope
    }
    @(
        # Set-Alias -PassThru -Name 'ls'   -Value Get-ChildItem
        Set-Alias @splat -Name 'sc'   -Value Set-Content
        Set-Alias @splat -Name 'cl'   -Value Set-Clipboard # -Force:$true
        Set-Alias @splat -Name 'gcl'  -Value Get-Clipboard # -Force:$true
        Set-Alias @splat -Name 'impo' -Value Import-Module # -Force:$true
        Set-Alias @splat -Name 'Json.From' -Value 'ConvertFrom-Json'
        Set-Alias @splat -Name 'Json'      -Value 'ConvertTo-Json'

        # aggressive aliases include aliases that don't have a prefix of 'mint'
        Set-Alias @splat -Name 'RelPath' -Value 'Mintils\Format-MintilsRelativePath'
        Set-Alias @splat -Name 'Goto' -Value 'Mintils\Push-MintilsLocation'
        Set-Alias @splat -Name 'Some' -Value 'Mintils\Select-MintilsObject'
        Set-Alias @splat -Name 'One'  -Value 'Mintils\Select-MintilsObject'

    )   | Sort-Object
        | Join-String -f "`n - {0}" -op 'Mintils Set-Alias: ' -p {
            $pre, $rest = $_.DisplayName -split ' -> ', 2
            $pre.ToString().padRight(12, ' '), $rest -join ' -> '
        } | Write-Host -fg 'goldenrod'
}

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

function Find-MintilsFunctionDefinition {
    <#
    .synopsis
        Find a function, then open vscode to that exact line number
    .NOTES
        .
    .example
        # Open in vs code
        gcm EditFunc | EditFunc -PassThru -AsCommand
    .EXAMPLE
        # Get path to your prompt
        > gcm prompt | EditFunc -PassThru
    .EXAMPLE
        # edit the file with your prompt defined
        > gcm prompt | EditFunc
    .Example
        # Converts alias/etc into command info .
        gcm goto | EditFunc -PassThru -AsCommand
        gcm goto | EditFunc -AsCommand
    #>
    [Alias('Mint.Find-FunctionDefinition', 'EditFunc')]
    [OutputType( 'System.IO.FileInfo', 'System.Management.Automation.CommandInfo' )]
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [Object] $InputObject,

        # output paths found, else, run in vs code. OutputType: [FileInfo]
        [Alias('WithoutAutoOpen')]
        [switch] $PassThru,

        # output command rather than filepath. OutputType: [CommandInfo], [FunctionInfo]
        [switch] $AsCommand
    )
    begin {
        function CoerceCommand {
            # Get filepath from command, scriptblock, alias, etc.
            param(
                [Parameter(Mandatory)] $Obj
            )
            if( $Obj -is [Management.Automation.AliasInfo] )  {
                $resolve = Get-Command $Obj.Definition
                $msg = '    => start: {0} of "{1}"' -f @(
                    $resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    $resolve.ScriptBlock.File
                )

                $msg | New-Text -fg 'gray80' -bg 'gray30'
                    # | Write-information # for now just write host, to simplify passing InfaAction or not
                    | Write-Host

                if( $AsCommand ) { return $Resolve }
                return Get-Item $resolve.ScriptBlock.File
            }
            if( $Obj -is [Management.Automation.FunctionInfo] )  {
                $Resolve = $Obj
                $msg = '    => start: {0} of "{1}"' -f @(
                    $resolve.ScriptBlock.Ast.Extent.StartLineNumber
                    $resolve.ScriptBlock.File
                )
                $msg | New-Text -fg 'gray80' -bg 'gray30'
                    # | Write-information # for now just write host, to simplify passing InfaAction or not
                    | Write-Host

                if( $AsCommand ) { return $Resolve }
                return Get-Item $resolve.ScriptBlock.File
            }
            'Unhandled converting command path from type: {0}' -f $Obj.GetType().Name  | Write-Warning
            return $Null
        }
    }

    process {
        $query = CoerceCommand -Obj $InputObject
        foreach($Item in $query) {
            if( $PassThru ) { return $item }
            code --goto ( Get-Item -ea 'stop' $item.FullName )
        }

    }
}

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

# was: requires -Module ClassExplorer

function Find-MintilsTypeName {
    <#
    .SYNOPSIS
        Get [Type] info from the names of types
    .NOTES
    .link
        Mintils\Find-MintilsTypeName
    .link
        Mintils\Get-MintilsTypeHelp
    #>
    [CmdletBinding()]
    [Alias('Mint.Find-TypeName')]
    [OutputType( 'System.Reflection.TypeInfo', 'System.RuntimeType' )]
    param(
        # ex: 'System.TimeZoneInfo'
        [Alias('FromName')]
        [Parameter(Mandatory, ValueFromPipeline )]
            [string] $TypeName,

        # Ignore exceptions thrown by [Type]
            [switch] $WithoutError
    )
    process {

        $maybeType = [Type]::GetType( $TypeName,
            <# bool: throwOnError #> (! $WithoutError ),
            <# bool: ignoreCase #>   $true )

        if( -not $MaybeType ) { # Fallback: exact FullName
            $maybeType = Find-Type -fullname 'TimeZoneInfo' # ex: 'System.TimeZoneInfo'
        }
        if( -not $MaybeType ) { # Fallback: exact Name
            $maybeType = Find-Type -Name $TypeName  # ex: 'TimeZoneInfo'
        }
        if( -not $MaybeType ) { # Fallback: Super wild card
            $maybeType = Find-Type -Fullname "*${TypeName}*"
        }
        if( $MaybeType.count -gt 1 ) {
            'Multiple types found for name: "{0}"' -f $TypeName | Write-Warning
        }
        $maybeType
    }
}

function Format-MintilsRelativePath {
    <#
    .synopsis
        Sugar that converts paths relative a base dir
    #>
    [Alias('Mint.Format-RelativePath')]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        [Alias('BasePath')]
        [Parameter(Mandatory, Position = 0)]
        $RelativeTo,

        # Strings / paths to convert
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]] $Path,

        # Emit an object with path properties, including the raw original path
        [Alias('PassThru')]
        [switch] $AsObject
    )
    process {
        foreach( $item in $Path ) {
            $relPath = [System.IO.Path]::GetRelativePath(
                <# string: relativeTo #> $RelativeTo,
                <# string: path  #>  $Item )

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

function Select-MintilsObject {
    <#
    .synopsis
        Select first, last, some, etc...
    #>
    [Alias('Mint.Select-Some')]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline for speed
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object[]] $InputObject,

        [int] $MaxCount = 5
    )
    begin {
        $found_count = 0
        $PSCmdlet.MyInvocation.MyCommand.Name | Write-Debug
        write-warning 'WIP: Not executing as expected for smart alias! 🐘'
        if( $PSCmdlet.MyInvocation.MyCommand.Name -in @('one', 'first' ) ) {
            $found_count = 1
        }
        # wait-debugger
        # if( $PSCmdlet.MyInvocation. )
    }
    process {
        foreach( $Item in $InputOBject ) {
            if( $found_count -ge $MaxCount ) { continue }
            $found_count += 1
            $InputObject
        }
    }
}

