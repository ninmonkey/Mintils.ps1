
function _Coerce.FileSystemInfo.FromString {
    <#
    .synopsis
        [internal] Converts string to the best
    .notes
    - [ ] todo: verify '-as' errors emit from module to user scope from "Mint.New-hashset.FileInfo -Collection <string>"
    - [ ] profile whether skipping (Get-Item) is significantly faster when piping large volumes.
        if yes,
            - [ ] Add -FromDirectoryString -FromFileString to explicity set the type
            - [ ] or -SkipGetItemCheck as a parameter
    .example
        > 'c:\foo\bar', $Profile, $Profile.ToString(), (Get-Item '.'), (Get-Item $Profile),
            | _Coerce.FileSystemInfo.FromString
    #>
    [OutputType( [System.IO.FileInfo], [System.IO.DirectoryInfo] )]
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [string[]] $InputObject
    )
    process {
        foreach( $Str in $InputObject ) {
            if( $null -eq $Str ) { continue }

            if( $Item = Get-Item -ea 'ignore' $Str  ) {
                $Item
                continue
            }

            if( Test-Path $Str -PathType Leaf ) {
                $Item = $Str -as [IO.FileInfo]
                if( $null -ne $Item ) {
                    $item
                    continue
                }
            }

            $item = $Str -as [IO.DirectoryInfo]
            if( $null -ne $Item ) {
                $item
                continue
            }

            if( $null -eq $item ) {
                "Failed Coercing string to [IO.DirectoryInfo] or [IO.FileInfo]! From Input = '{0}'" -f $Str
                    | Write-Error
            }
        }
    }
}

function _Coerce.HashTable.FromKeyValuePairs { # or FromDictionaryEntry
    <#
    .synopsis
        [internal] Converts arrays of [Collections.DictionaryEntry] to one hashtable
    .description
        Does not sort keys, Does not return [ordered]@{}
    .example
        > $hash = Gci Env:\ | _Coerce.HashTable.FromDictionaryEntry
        > Mint.Write-Dict $Hash
    .example
        > Mint.Write-Dict ( _Coerce.HashTable.FromDictionaryEntry -InputObject $sample )
    .LINK
        Mintils\Mint.ConvertTo-Hashtable.FromKeyValues
    #>
    [OutputType( [System.Collections.Hashtable] )] # [System.Collections.Specialized.OrderedDictionary],
    [CmdletBinding()]
    param(
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]] $InputObject
    )
    begin {
        $hash = @{}
    }
    process {
        foreach( $Item in $InputObject ) {
            if( $Item -is [Collections.DictionaryEntry] ) {
                [Collections.DictionaryEntry] $Obj = $Item
                $hash[ $Obj.Key ] = $Obj.Value
                continue
            }
            if( $null -ne $Item.Key -and $null -ne $Item.Value ) {
                $hash[ $Item.Key  ] = $Item.Value
                continue
            }
            "Unhandled Item type: {0}" -f @(
                ( $Item )?.GetType() ?? '<null>'
            )  | Write-Error
            continue
        }
    }
    end {
        $hash
    }
}

function _Get-TextStyle {
    <#
    .SYNOPSIS
        [internal] lookup text colors by semantic names
    .example
    #>
    [CmdletBinding()]
    param(
        # Select first matching pattern
        [Parameter(Mandatory, ParameterSetName='ByNameLookup', Position = 0)]
        [Alias('Name')]
        [string] $ByName,

        # only select one exact match
        [Parameter(ParameterSetName='ByNameLookup')]
        [Alias('Strict', 'ExactOnly')]
        [switch] $OneOrNone,

        [Parameter(Mandatory, ParameterSetName='ByListAll')]
        [Alias('All', 'List')]
        [switch] $ListAll,

        # output contains only Fg and Bg to make splatting simpler
        [Parameter( ParameterSetName = 'ByNameLookup' )]
        [Alias('OutputAsHash','AsHash' )]
        [switch] $AsSplatableHash
    )

    $styles = @(
        <# core basic colors #>
        @{
            Name = 'DimDark'
            SemanticName = 'GeneralText.LowContrast'
            Description = @(
                'Dim general text. Grayish.',
                'Fg: Gray, Bg: dark gray/black.',
                'Dark but is not bold / lower contrast' ) -join ' '
            Fg = 'gray40'
            Bg = 'gray15'
            Category = 'Core'
        }
        @{
            Name = 'Dim'
            SemanticName = 'GeneralText'
            Description = @(
                'Dim general text. Grayish.',
                'Default style for "Write-Information"'
                'Fg: Gray, Bg: Gray.',
                'Not bold / lower contrast' ) -join ' '
            Fg = 'gray70'
            Bg = 'gray30'
            Category = 'Core'
        }
        @{
            Name = 'DimInfo'
            SemanticName = 'DimInfo.NoBg'
            Description = 'Dim Information text. Ex: light pink/purple. Low contrast'
            Fg = '#e9addc'
            Bg = $null
            Category = 'Core'
        }
        @{
            Name = 'DimWarning'
            SemanticName = 'Warning.NoBg'
            Description = @( 'Dim warning text.', 'Low severity warnings.', 'Fg: yellow, Bg: null.' ) -join ' '
            Fg = '#ebcb8b'
            Bg = $Null
            Category = 'Core'
        }
        @{
            Name = 'DimGood'
            SemanticName = 'Good.NoBg'
            Description = @( 'Good text.', 'Fg: Light Green, Bg: null.' ) -join ' '
            Fg = '#a2bb91'
            Bg = $Null
            Category = 'Core'
        }
        @{
            Name = 'Dict.Key'
            SemanticName = 'Dict.Key'
            Description = @('Dictionary keys are emphasized' ) -join ' '
            fg = '#f4a460'
            bg =  '#2e3440'
            Category = 'Module.Command'
        }
        @{
            Name = 'Dict.Value'
            SemanticName = 'Dict.Value'
            Description = @('Dictionary values are less emphasized' ) -join ' '
            fg = 'gray70'
            bg =  $null
            Category = 'Module.Command'
        }
        <# superfluous section #>

        @{
            Name = 'Gray.Dark.LowContrast'
            SemanticName = 'Gray.Dim.Dark.LowContrast'
            Description = @(
                'Dim gray text with BG',
                'Fg: Gray, Bg: Gray.',
                'Low contrast.' ) -join ' '
            Fg = 'gray30'
            Bg = 'gray20'
            Category = 'Extra'
        }
        @{
            Name = 'Gray.Bright.BoldContrast'
            SemanticName = 'Gray.Bright.BoldContrast'
            Description = @(
                'Bold Light Gray text with BG',
                'Fg: BrightGray, Bg: Gray.',
                'High contrast.' ) -join ' '
            Fg = 'gray80'
            Bg = 'gray30'
            Category = 'Extra'
        }
    ).forEach( [pscustomobject] )
        | Sort-Object -Prop Category, Name, SemanticName, Description # or: Name, Description
        | Select-Object -Prop 'Name', 'SemanticName', 'Fg', 'Bg', 'Category', 'Description' # View / FormatData order

    switch( $PSCmdlet.ParameterSetName ) {
        'ByNameLookup' {
            # if strict, find exact or throw
            if( $OneOrNone ) {
                $found = $styles | ? -Prop Name -eq $ByName
                if( $found.count -eq 0 ) {
                    $found = $styles | ? -Prop Name -like "*${ByName}*"
                }
                if( $found.Count -eq 1 ) { return $found }
                else {
                    $found | Join-String -p Name -sep ', ' -op 'ambigous styles found!: ' | Write-Verbose
                    throw ("Strict match Name: '${ByName}' failed, found $( $found.count ) matches! ")
                }
            }
            # else match on first
            $found = $styles
                | Where-Object { $_.Name -like "*${ByName}*" }
                | Select-Object -First 1

            if( -not $found ) {
                throw "Style name '$ByName' not found. Available styles: " +
                    ( $styles.Name -join ', ' )
            }
            $found | Join-String -f 'TextStyle found: "{0}"' -p Name | Write-Verbose
            if( -not $AsSplatableHash ) { return $found }

            $hash = @{ Fg = $Found.Fg; Bg = $Found.Bg }
            return $hash
        }
        'ByListAll' {
            return $styles
            break
        }
        default {
            throw "Unhandled ParameterSetName: '$( $PSCmdlet.ParameterSetName )' !"
        }
    }
}

# remove the majority of this implementation from the repo
function _Invoke-App.VsCode {
    <#
    .SYNOPSIS
        [internal] lower level VS Code wrapper. No error handling.
    .description
        Internal version. Minimal error handling,

        for the user-facing version with error handling
            see: Mint.Invoke-App.VsCode

        Not using ParameterSets because of the complexity, and future parameters
    .notes
    --log <level>

        Allowed values are 'critical', 'error', 'warn', 'info', 'debug', 'trace', 'off'.

        You can also configure the log level of an extension by passing
        extension id and log level in the following format:
            '${publisher}.${name}:${logLevel}'.

            For example: 'vscode.csharp:trace'.
    .example
        # quick testing
        > & ( ipmo Mintils -PassThru -Force ) {
            _Invoke-App.VsCode -Version -verbose -LogLevel info -WhatIf
            | Join-String -sep ' ' | write-host -fg salmon }
    .link
        Mint\Mint.Invoke-App.VsCode
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $FileWithLineNumberString,

        # Read piped text instead of a file
        [ValidateScript({throw 'nyi: to simplify impl without pipeline'})]
        [switch] $FromStdIn,

        # is => code --goto <file:line[:character]>
        [Parameter()]
        [object] $GotoFile,

        # is => code --add <folder>
        [Alias('Add')]
        [Parameter()]
        [object] $AddDirectory,

        # is => code --add <folder>
        [Alias('Remove')]
        [Parameter()]
        [object] $RemoveDirectory,

        # Outputs BinArgs commands as [List[object]]
        [Alias('TestOnly')]
        [switch] $WhatIf,

        # writes log to console
        [switch] $VerboseLog,
        [switch] $Version,

        [ValidateScript({throw 'nyi'})]
        [ArgumentCompletions('chat', 'serve-web', 'tunnel')]
        [string] $SubCommand,

        [ArgumentCompletions('bash', 'pwsh', 'zsh', 'fish')]
        [string] $LocateShellIntegrationPath,

        <#
        Log level to use. Default: info.
        Allowed values are 'critical', 'error', 'warn', 'info', 'debug', 'trace', 'off'.

        You can also configure the log level of an extension by passing
        extension id and log level in the following format:
            '${publisher}.${name}:${logLevel}'.

        For example: 'vscode.csharp:trace'.
        #>
        [ArgumentCompletions(
            'critical', 'error', 'warn', 'info', 'debug', 'trace', 'off',
            "'publisher.name:severity'" )]
        [string] $LogLevel,

        [switch] $Status,
        [switch] $Transient,
        [switch] $Telemetry,
        [switch] $DisableGPU,

        [switch] $ProfileStartup,
        [switch] $DisableExtensions,

        # force a new window
        [switch] $NewWindow,

        # Force open a file or folder in an existing window
        [switch] $ReuseWindow,

        [ValidateSet('on', 'off')]
        [string] $Sync,

        # code: 'code --diff <file1> <file2>'
        [ValidateScript({throw 'nyi'})]
        [switch] $Diff,

        # code: 'code --merge <path1> <path2> <base> <result>'
        [ValidateScript({throw 'nyi'})]
        [switch] $Merge,

        # wait for files to be closed
        [switch] $Wait,

        [ArgumentCompletions('en-US', 'de-de')]
        [string] $Locale,

        # cmd: "code --user-data-dir <dir>". Specifies the directory that user data is kept in. Can be used to open multiple distinct instances of Code.
        [string] $UserDataDir,

        # is => code --install-extension <id | path>.
        # Installs or updates an extension. The argument is either an extension id or a path to a VSIX. The identifier of an extension is '${publisher}.${name}'. Use '--force' argument to update to latest version. To install a specific version provide '@${version}'. For example: 'vscode.csharp@1.2.3'.
        # use with: --force, --profile
        [ArgumentCompletions(
            "'c:\foo\bar.vsix'",
            "'publisher.name'", "'publisher.name@1.2.3'" )]
        [string] $InstallExtension,

        # is => code --uninstall-extension <id>
        [ArgumentCompletions( "'publisher.name'", "'publisher.name@1.2.3'" )]
        [string] $UninstallExtension,

        # install pre-release extensions
        # is => code --pre-release
        [switch] $EnablePreReleaseExtension,

        # skip prompts. install extensions, etc.
        # is => code --force <extension>; ex: vscode.csharp@1.2.3;
        # use with: --list-extensions;
        [switch] $UsingForce,

        # is => code --extensions-dir <dir>
        [string] $ExtensionsDir,

        # is => code --list-extensions
        [switch] $ListExtensions,

        # use with: --list-extensions; is => code --list-extensions --category <category>
        # blank means show them. But only if explicitly passed
        [ArgumentCompletions("''")]
        [string] $FilterListExensionsCategory,

        # is => code --list-extensions --show-versions
        [switch] $ShowVersions,

        # cmd: "code --profile <name>".  Opens the provided folder or workspace with the given profile and associates the profile with the workspace. If the profile does not exist, a new empty one is created.
        [string] $Profile,

        [ArgumentCompletions("'publisher.extension'")]
        [string] $EnableProposedAPI,

        # is => code --inspect-extensions <port>
        [int] $InspectExtensionsPort,

        # Allow debugging and profiling of extensions with the extension host being paused after start. Check the developer tools for the connection URI.
        # is => code --inspect-brk-extensions <port>
        [int] $InspectExtensionsBreakpointPort,

        # Add a ShouldProcess -Confirm after showing built cli args
        [ValidateScript({throw 'nyi'})]
        [switch] $Confirm
    )
    begin {}
    end {
        [Collections.Generic.List[Object]] $binArgs = @()
        [Collections.Generic.List[Object]] $OptionsArgs = @()


        $PSBoundParameters | ConvertTo-Json -Depth 2
            | Join-String -op 'PSboundParams: ' | Write-Verbose

         <# options that are composed with the base ones #>
        if( $VerboseLog ) {
            $OptionsArgs.Add( '--verbose' )
        }
        if( $LogLevel ) {
            $OptionsArgs.AddRange(@( '--log', $LogLevel ))
        }
        if( $Telemetry ) {
            $OptionsArgs.Add( '--telemetry' )
        }
        if( $Transient ) {
            $OptionsArgs.Add( '--transient' )
        }
        if( $DisableGPU ) {
            $OptionsArgs.Add( '--disable-gpu' )
        }
        if( $Sync ) {
            $OptionsArgs.AddRange(@( '--sync', $Sync ))
        }
        if( $ProfileStartup ) {
            $OptionsArgs.Add( '--prof-startup' )
        }
        if( $DisableExtensions ) {
            $OptionsArgs.Add( '--disable-extensions' )
        }
        if( $NewWindow ) {
            $OptionsArgs.Add( '--new-window' )
        }
        if( $ReuseWindow ) {
            $OptionsArgs.Add( '--reuse-window' )
        }
        if( $Wait ) {
            $optionsArgs.Add( '--wait' )
        }
        if( $EnablePreReleaseExtension ) {
            $optionsArgs.Add( '--pre-release' )
        }
        if( $Locale ) {
            $optionsArgs.AddRange(@( '--locale', $Locale ))
        }
        if( $UserDataDir ) {
            $optionsArgs.AddRange(@( '--user-data-dir', $UserDataDir ))
        }
        if( $Profile ) {
            $optionsArgs.AddRange(@( '--profile', $Profile ))
        }
        if( $ExtensionsDir ) {
            $optionsArgs.AddRange(@( '--extensions-dir', $ExtensionsDir ))
        }
        if( $InspectExtensionsPort ) {
            $optionsArgs.AddRange(@( '--inspect-extensions', $InspectExtensionsPort ))
        }
        if( $InspectExtensionsBreakpointPort ) {
            $optionsArgs.AddRange(@( '--inspect-brk-extensions', $InspectExtensionsBreakpointPort ))
        }
        if( $EnableProposedAPI ) {
            $optionsArgs.AddRange(@(
                '--enable-proposed-api'
                $EnableProposedAPI
            ))
        }

        <# modal modes, that requires a clear/reset $BinArgs #>
        if( $ListExtensions ) {
            $binArgs = @(
                $OptionsArgs
                '--list-extensions'
                if( $ShowVersions ) { '--show-versions' }

                # if blank, list possible extension categories
                if( $FilterListExensionsCategory -or
                    $PSBoundParameters.ContainsKey('FilterListExensionsCategory')
                ) {
                    "--category={0}" -f @(  $FilterListExensionsCategory )
                }
            )
        }
        if( $UpdateExtensions )  {
            $binArgs = @(
                $OptionsArgs
                '--update-extensions'
            )
        }
        if( $InstallExtension )  {
            $binArgs = @(
                $OptionsArgs
                '--install-extension'
                $InstallExtension
            )
        }
        if( $UninstallExtension )  {
            $binArgs = @(
                $OptionsArgs
                '--uninstall-extension'
                $InstallExtension
            )
        }
        if( $FileWithLineNumberString ) {
            $binArgs = @(
                $OptionsArgs
                '--goto'
                $FileWithLineNumberString
            )
        }
        if( $GotoFile ) {
            $binArgs = @(
                $OptionsArgs
                '--goto'
                $GoToFile
            )
        }
        if( $AddDirectory ) {
            $binArgs = @(
                $OptionsArgs
                '--add'
                $AddDirectory
            )
        }
        if( $RemoveDirectory ) {
            $binArgs = @(
                $OptionsArgs
                '--remove'
                $RemoveDirectory
            )
        }
        if( $Version ) {
            $binArgs = @(
                $OptionsArgs
                '--version'
            )
        }
        if( $LocateShellIntegrationPath ) {
            $binArgs = @(
                # $OptionsArgs
                '--locate-shell-integration-path'
                $LocateShellIntegrationPath
            )
        }
        if( $Status ) {
            $binArgs = @(
                # $OptionsArgs
                '--status'
            ) # is this mode exclusive?
        }
        if( $FromStdIn ) {
            $binArgs.add( '-' )
        }

        if( $WhatIf ) {
            $binArgs | Join-String -sep ' ' -op 'invoke "code" => '
                | Write-Host -fg 'gray70' -bg 'gray30'

            return $binArgs
        }

        & ( Mint.Require-App 'code' ) @BinArgs
    }
    process {}

}

function _Resolve-CommandFileLocation {
    <#
    .SYNOPSIS
        resolve many kinds into Filename and line numbers, if possible. [private/internal]
    .NOTES
        Some related types:
        > Find-Type -namespace System.Management.Automation -Name '*Info'

    expected 'Get-Command' output types:

        (gcm gcm).OutputType | % Type | Join-String -p { $_.ToString() } -sep "`n" -f '[{0}]' | Sort-Object -Unique

        [System.Management.Automation.AliasInfo]
        [System.Management.Automation.ApplicationInfo]
        [System.Management.Automation.FunctionInfo]
        [System.Management.Automation.CmdletInfo]
        [System.Management.Automation.ExternalScriptInfo]
        [System.Management.Automation.FilterInfo]
        [System.String]
        [System.Management.Automation.PSObject]
    .example
        # Externally test using this:
        & ( ipmo Mintils -PassThru ) { _Resolve-DirectoryFromPathLike ( gcm Add-ExcelName ) -Debug }
    #>
    [CmdletBinding()]
    param(
        # File, Directory, PSModuleInfo, String, Etc
        # Supports Types like: ErrorRecord, InvocationInfo, AliasInfo, ApplicationInfo, CmdletInfo, DirectoryInfo, ExternalScriptInfo, FileSystemInfo, FunctionInfo, PSModuleInfo, FilterInfo, String, etc...
        [Alias('Object', 'InObj')]
        [ValidateNotNull()]
        [Parameter(Mandatory)]
        $InputObject
    )
    $InputObject.GetType()
        | Join-String -f 'enter => type: {0} ' | Write-Verbose

    $return = [ordered]@{
        PSTypeName = 'Mintils.Resolved.Command.OtherInfo'
    }
    switch( $InputObject ) {
        # I used explicit 'break' and 'returns' for clarity, even if not required
        { $_ -is [System.Management.Automation.AliasInfo] } {
            $return.PSTypeName = 'Mintils.Resolved.Command.AliasInfo'
            [Management.Automation.CommandInfo] $ResolvedCmd = $InputObject.ResolvedCommand

            $return  = _Resolve-CommandFileLocation -Inp $ResolvedCmd
            if( -not $return ) {
                throw "nyi $( $InputObject.GetType() ) "
            }
            break
        }
        { $_ -is [System.Management.Automation.ApplicationInfo] } {
            $return.PSTypeName = 'Mintils.Resolved.Command.ApplicationInfo'
            throw "nyi $( $InputObject.GetType() ) "
            break
        }
        { $_ -is [System.Management.Automation.InvocationInfo] } {
            [System.Management.Automation.InvocationInfo] $invo = $_
            $return.PSTypeName = 'Mintils.Resolved.Command.InvocationInfo'

            $maybeFile = Get-Item -ea ignore $invo.ScriptName
            if ( -not $MaybeFile ) { $maybeFile = Get-Item -ea ignore $invo.PSCommandPath }
            if ( -not $MaybeFile ) {
                throw "Unable to resolve script path from type: $( $InputObject.GetType() ) !"
                break
            }
            $return.File                   = Get-Item $maybeFile
            $return.StartLineNumber        = $invo.ScriptLineNumber
            $return.EndLineNumber          = $null
            $return.StartColumnNumber      = $invo.OffsetInLine
            $return.EndColumnNumber        = $null
            $return.FileExists             = Test-Path -ea ignore $return.File
            $return.InvocationInfoInstance = $invo

            break
        }
        { $_ -is [System.Management.Automation.ErrorRecord] } {
            [System.Management.Automation.ErrorRecord] $err = $_

            $return.PSTypeName = 'Mintils.Resolved.Command.ErrorRecord'
            if( $err.InvocationInfo ) {
                $return = _Resolve-CommandFileLocation -InputObject $err.InvocationInfo
                   $return | Add-Member -Force -NotePropertyMembers @{ ErrorRecordInstance = $Err }

                break
            }

            throw "Unable to resolve script path from type: $( $InputObject.GetType() ) "
            break
        }
        { $_ -is [System.Management.Automation.FunctionInfo] } {
            [System.Management.Automation.FunctionInfo] $func = $_

            $return.PSTypeName = 'Mintils.Resolved.Command.FunctionInfo'
            $return.Name       = $func.Name
            $return.ModuleName = $func.ModuleName
            $return.Module     = $func.Module
            $return.Source     = $func.Source
            $return.FileExists = $false                                                   # ensures order before File
            $return.File       = Get-Item -ea 'ignore' $func.ScriptBlock.Ast.Extent.File
            $return.FileExists = $return.File -and (  Test-Path $return.file )
            # if (-not $return.File ) {
            #     'bad?' | Write-Host -fg purple
            #     $null = 0
            # }
            $return.StartLineNumber      = $func.ScriptBlock.Ast.Extent.StartLineNumber
            $return.EndLineNumber        = $func.ScriptBlock.Ast.Extent.EndLineNumber
            $return.StartColumnNumber    = $func.ScriptBlock.Ast.Extent.StartColumnNumber
            $return.EndColumnNumber      = $func.ScriptBlock.Ast.Extent.EndColumnNumber
            $return.FunctionInfoInstance = $func

            $format_splat = @{
                Path              = $return.File
                StartLineNumber   = $return.StartLineNumber
                StartColumnNumber = $return.StartColumnNumber
            }
            $return.FileWithLineNumberString = Mint.Format-FullNameWithLineNumber @format_splat

            $return.HelpFile = $func.HelpFile
            $return.HelpUri  = $func.HelpUri
            # $return = 'func'
            break
        }

        { $_ -is [System.Management.Automation.CmdletInfo] } {
            [System.Management.Automation.CmdletInfo] $Info = $InputObject

            $return.PSTypeName         = 'Mintils.Resolved.Command.CmdletInfo'
            $return.Name               = $Info.Name
            $return.ImplementingType   = $Info.ImplementingType
            $return.Namespace          = $Info.Namespace
            $return.Source             = $Info.Source
            $return.DLL                = $Info.DLL
            $return.FileExists = $true # ensure order
            $return.File               = Get-Item $info.DLL
            $return.FileExists = Test-Path -ea ignore $return.File
            $return.CmdletInfoInstance = $Info
            # throw "nyi $( $InputObject.GetType() ) "
            break
        }
        { $_ -is [System.Management.Automation.ExternalScriptInfo] } {
            # $return = ''
            $return.PSTypeName = 'Mintils.Resolved.Command.ExternalScriptInfo'
            throw "nyi $( $InputObject.GetType() ) "
            break
        }
        { $_ -is [System.Management.Automation.FilterInfo] } {
            # $return = ''
            $return.PSTypeName = 'Mintils.Resolved.Command.FilterInfo'
            throw "nyi $( $InputObject.GetType() ) "
            break
        }
        {
            $_ -is [String] -and ( $nextGcm = Gcm $_ -ea ignore)
        } {
            # $return        = 'StrToGcm => {0} ' -f $nextGcm
            $return  = _Resolve-CommandFileLocation -Inp $nextGcm
            # $return.PSTypeNames -join ', '
            throw "nyi $( $InputObject.GetType() ) "
            # $return += ' , then => {0}' -f (  $nextResolved )
            break
        }
        { $_ -is [System.Management.Automation.PSObject] } { # always tested last to prevent coercion
            [System.Management.Automation.PSObject] $psobj = $_

            # if already parsed ffrom here, emit existing without altering anything. including type name.
            $alreadyParsed = ( @( $psobj.PSTypeNames ) -match 'Mintils\.Resolved\.' ).count -gt 0
            if( $alreadyParsed ) {
                $return = $psobj
                break
            }
            # or if prop types exist
            $names = $psobj.PSobject.Properties.Name
            if( $names -contains 'file' -and $names -contains 'StartLineNumber' ) {
                $return = $psobj
                break
            }
            throw "Unexpected PSCO from another source. PSTypeNames: $( $InputObject.PSTypeNames -join ', ' ) "
            # $return.PSTypeName       = 'Mintils.Resolved.Command.PSObject'
            # $return.File             = $psobj.Name
            # $return.FileExists       = Test-Path -ea ignore $return.File
            # $return.PSObjectInstance = $psobj
            break
        }
        default {
            throw ("Unhandled type: $( $InputObject.GetType() )")
            break
        }
    }
    # Properties to always append, or attempt to
    # should alias Path/PSPath/FullName for cleaner parameter binding
    if( -not $return.Path ) { $return.Path = $return.File }

    if( -not $return.FileWithLineNumberString ) {
        $format_splat = @{
            Path              = $return.File
            StartLineNumber   = $return.StartLineNumber
            StartColumnNumber = $return.StartColumnNumber
        }
        $return.FileWithLineNumberString = Mint.Format-FullNameWithLineNumber @format_splat
    }

    [pscustomobject] $return
}

function _Resolve-DirectoryFromPathlike {
    <#
    .SYNOPSIS
        [private] get filepath if possible from many object types. Prefer filename with path, fallback to directory if needed.
    .DESCRIPTION
        returns $null if all paths failed, and writes a warning.
    .example
        # Externally test using this:
        & ( ipmo Mintils -PassThru ) { _Resolve-DirectoryFromPathLike ( gcm Add-ExcelName ) -Debug }
    #>
    [CmdletBinding()]
    param(
        # File, Directory, PSModuleInfo, String, Etc
        # Supports Types: ApplicationInfo, DirectoryInfo, FileSystemInfo, FunctionInfo, PSModuleInfo, String,
        [object] $InputObject
    )

    $ResolvedItem = Get-Item -ea ignore $InputObject

    [PSCustomObject]@{
        ResolvedType    = ( $ResolvedPath )?.GetType().FullName
        Resolved        = ( $ResolvedPath )?.ToString()
        InputObjectType = ( $InputObject )?.GetType().FullName
        InputObject     = ( $InputObject )?.ToString()
    } | ConvertTo-Json -Depth 0 | Join-String -f 'Mint.Goto parameters: {0}' | Write-Debug

    if( $InputObject -is [IO.FileSystemInfo] ) {
        return $InputObject
    }
    if( $InputObject -is [System.Management.Automation.PSModuleInfo] ) {
        return ( Get-Item $InputObject.Path )
    }
    if( $InputObject -is [IO.DirectoryInfo] ) {
        return $InputObject
    }
    if( $InputObject -is [Management.Automation.FunctionInfo] ) {
        [Management.Automation.FunctionInfo] $maybeFunc = $InputObject
        $Resolved = Get-Item $maybeFunc.ScriptBlock.Ast.Extent.File
        if( $null -eq $Resolved ) {
            throw "Found [FunctionInfo] but Ast.Extent.File was null. ( Verify the module '$( $InputObject.Source  )' is loaded )"
        }
        return $Resolved
    }
    if( $InputObject -is [Management.Automation.ApplicationInfo] ) {
        [Management.Automation.ApplicationInfo] $maybeApp = $InputObject
        $Resolved = ( Get-Item $maybeApp.Source ) ?? ( Get-Item $maybeApp.Path )
        return $Resolved
    }
    if( $InputObject -is [string] -and $Null -ne $ResolvedItem ) {
        return $ResolvedItem
    }
    "Unhandled input type when converting '${InputObject}' of type $( ( $InputObject)?.GetType() ) to path: {0}" | Write-Warning
    # Maybe always attempt PSPath ? Or leave that to the caller?
}

function Convert-MintilsHashtableFromKeyValues {
    <#
    .synopsis
        [internal] Converts arrays of [Collections.DictionaryEntry] to one hashtable
    .description
        Does not sort keys, Does not return [ordered]@{}
    .example
        > Mint.Write-Dict ( Gci Env:\ | Mint.Convert.Dict.FromKeyValues )
    .example
        > $hash = Mint.Convert.Dict.FromKeyValues -InputObject ( Gci Env:\ )
        > Mint.Write-Dict $hash
    .example
        > Mint.Write-Dict ( Mint.Convert.Dict.FromKeyValues -InputObject ( Gci Env:\ ) )
    .example
        > Mint.Write-Dict ( Mint.ConvertTo_Coerce.HashTable.FromDictionaryEntry -InputObject $sample )
    #>
    [Alias(
        'Mint.ConvertTo-Hashtable.FromKeyValues',
        'Mint.Convert-Dict.FromKeyValues',
        # 'Mint.ConvertTo-Dict.FromKeyValues',
        'Mint.Convert.Dict.FromKeyValues'
        # 'Mint.Convert.Dict.FromPairs'
        # Mint.Convert-Hash.FromDictEntry
    )]
    [OutputType( [System.Collections.Hashtable] )]
    [CmdletBinding()]
    param(
        # hashtable or idictionary or what is best to iterate ?
        [Alias('Pairs', 'KeyValues', 'DictionaryEntry')]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]] $InputObject
    )
    begin {
        [Collections.Generic.List[Object]] $List = @()
    }
    process {
        $List.AddRange(@( $InputObject ))
    }
    end {
        _Coerce.HashTable.FromKeyValuePairs -InputObject $List
    }
}

function Convert-MintilsHashtableFromObject {
    <#
    .synopsis
        Converts Objects into a hashtable
    .description
        Does not sort keys, Does not return [ordered]@{}
    .example
        > Mint.Write-Dict ( $Profile | Select All*, Current* | Mint.Convert.Dict.FromObject )
    .example
        > Get-Item . | Mint.Convert.Dict.FromObject
    .example
        > Mint.Write-Dict ( Get-Item '.' | Mint.Convert.Dict.FromObject  )
    .example
        > Get-Item '.' | Select Last*time, PSPath | Mint.Convert.Dict.FromObject | Ft -AutoSize

            Name           Value
            ----           -----
            PSPath         Microsoft.PowerShell.Core\FileSystem::H:\data\2025\pwsh
            LastWriteTime  2025-12-16 5:51:27 PM
            LastAccessTime 2026-01-04 4:08:47 PM
    #>
    [Alias(
        'Mint.ConvertTo-Hashtable.FromObject',
        'Mint.Convert.Dict.FromObject'
    )]
    [OutputType( [System.Collections.Hashtable] )]
    [CmdletBinding()]
    param(
        # hashtable or idictionary or what is best to iterate ?
        [Alias('InObj', 'Obj', 'Target' )]
        [Parameter( Mandatory, ValueFromPipeline )]
        [object[]] $InputObject
    )
    begin {
        [Collections.Generic.List[Object]] $List = @()
    }
    process {
        $List.AddRange(@( $InputObject ))
    }
    end {
        foreach( $CurObj in $List ) {
            $hash = @{}
            foreach( $Prop in $CurObj.PSObject.Properties ) {
                $hash[ $Prop.Name ] = $Prop.Value
            }
            $hash
        }
    }
}

function Enable-MintilsDefaultAlias {
    <#
    .SYNOPSIS
        Load common aliases, only if user opts-in by calling this.
    .NOTES
        Because this is from a module, you might need to use 'Set-alias -Force' and mabye '-Scope Global'
    .example
        # Silently load, ex: for your profile
        > Mint.Enable-Defaultalias -WithoutPSHost
    .example
        # interactively load, and show the summary of new aliases
        Mint.Enable-Defaultalias

        # or as objects
        Mint.Enable-Defaultalias -PassThru
    #>
    [Alias('Mint.Enable-DefaultAlias')]
    [OutputType( [System.Management.Automation.AliasInfo] )]
    [Cmdletbinding()]
    param(
        # required for readonly
        [switch] $Force,

        # Maybe a redundant param
        [ArgumentCompletions('Global', 'Local', 'Script')]
        [string] $Scope = 'Global',

        # Do not write the new names to host
        [Alias('WithoutPSHost')]
        [switch] $Silent,

        # output: [AliasInfo[]]
        [switch] $PassThru
    )

    $splat = @{
        PassThru = $True
    }
    # note: PSBoundParameters does not contain default values
    if( $PSBoundParameters.ContainsKey('Force') ) { $splat.Force = $Force }
    if( $PSBoundParameters.ContainsKey('Scope') -or (-not [string]::IsNullOrWhiteSpace( $Scope ) ) ) {
        $splat.Scope = $Scope
    }
    $items = @(
        # Set-Alias -PassThru -Name 'ls'   -Value Get-ChildItem
        Set-Alias @splat -Name 'Sc'   -Value Set-Content
        Set-Alias @splat -Name 'Cl'   -Value Set-Clipboard # -Force:$true
        Set-Alias @splat -Name 'Gcl'  -Value Get-Clipboard # -Force:$true
        Set-Alias @splat -Name 'impo' -Value Import-Module # -Force:$true
        Set-Alias @splat -Name 'Json' -Value 'Microsoft.PowerShell.Utility\ConvertTo-Json'
        Set-Alias @splat -Name 'Json.From' -Value 'Microsoft.PowerShell.Utility\ConvertFrom-Json'

        # Set-Alias @splat -Name 'Join-String' -Value 'Microsoft.PowerShell.Utility\Join-String' # when you need to prevent clobbering

        # aggressive aliases include aliases that don't have a prefix of 'mint'
        Set-Alias @splat -Name 'RelPath'  -Value 'Mintils\Format-MintilsRelativePath'
        Set-Alias @splat -Name 'Goto'     -Value 'Mintils\Push-MintilsLocation'
        Set-Alias @splat -Name 'Some'     -Value 'Mintils\Select-MintilsObject'
        Set-Alias @splat -Name 'One'      -Value 'Mintils\Select-MintilsObject'
        Set-Alias @splat -Name 'Mint.Fcc' -Value 'Mintils\Format-MintilsShowControlSymbols'
        Set-Alias @splat -Name 'Fcc'      -Value 'Mintils\Format-MintilsShowControlSymbols'
        <#
            # maybe?
            Set-Alias @splat -Name 'Mint.Fcc' -Value 'Mintils\Format-MintilsShow'
            Set-Alias @splat -Name 'fcc'      -Value 'Mintils\Format-MintilsShow'
        #>

    )   | Sort-Object
    if( $PassThru ) {
        $Items
    }
    if( -not $PassThru -and -not $Silent ) {
        $Items
        | Join-String -f "`n - {0}" -op 'Mintils Set-Alias: ' -p {
            $pre, $rest = $_.DisplayName -split ' -> ', 2
            $pre.ToString().padRight(12, ' '), $rest -join ' -> '
        } | Write-Host -fg 'goldenrod'
    }
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

function Find-MintilsFunctionDefinition {
    <#verbo
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
    [Alias('Mint.Find-FunctionDefinition', 'EditFunc', 'Mint.Find-FuncDef' )]
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
        $binCode = Mint.Require-AppInfo -Name 'code'
    }
    process {
        $found = _Resolve-CommandFileLocation -InputObject $InputObject
        if( $PassThru ) { $found ; return ; }

        $binArgs = @(
            '--goto', $Found.FileWithLineNumberString
        )

        if( -not $PassThru ) {
            $binArgs
                | Join-String -sep ' ' -op '    invoke code => '
                | Write-Host -fg 'gray80' -bg 'gray30'
        }

        if( -not (Test-Path $found.File )) {
            throw "Filepath not found for: $( $InputObject.GetType() )"
        }

        & $binCode @( '--goto', $Found.FileWithLineNumberString )
    }
}

function Find-MintilsGitRepository {
    <#
    .synopsis
        Fast find git repository folders. uses 'fd' find for speed'
    .NOTES
    the original command was:
        fd -d8 -td '\.git' -H | Get-Item -Force | % Parent
        fd -d3 -td '\.git' -H --absolute-path --base-directory 'H:\data\2025' | Get-Item -Force

    else, fallback to
        gci .. -Recurse -Directory '.git' -Hidden | split-path | gi

    clean: #: refactor by calling wrapper: 'Invoke-FdFind'
    .EXAMPLE
        # Search current dir
        > Mint.Find-GitRepo
    .EXAMPLE
        # Search other dir
        > Mint.Find-GitRepo -BaseDirectory 'h:\data\2025'
    .link
        Mintils\Find-MintilsWorkspace
    .link
        Mintils\Find-MintilsGitRepository
    #>
    [Alias(
        'Mint.Find-GitRepository',
        'Mint.Find-GitRepo'
    )]
    # [OutputType( [System.IO.DirectoryInfo], # for default set , 'mintils.git.repository.record' # for -PassThru )]
    [CmdletBinding()]
    param(
        # Base directory to search from, else current.
        # for: fd --base-directory
        [Parameter()]
        [Alias('Name', 'RootDir' )]
        [string] $BaseDirectory = '.',

        # for: fd --max-depth <int>
        [Alias('Depth')]
        [int] $MaxDepth = 5,

        # return an object instead of folder
        [switch] $PassThru
    )
    begin {}
    process {}
    end {
        $rootDir = Get-Item -ea stop $baseDirectory
        $pattern = '^\.git$'
        "Depth: ${MaxDepth}, Pattern: ${pattern}, Root: ${RootDi
        r}" | Write-Verbose
        $pathSeparator = '/'

        $found = @( fd --max-depth $MaxDepth --type 'directory' $Pattern --hidden --absolute-path --path-separator $pathSeparator --base-directory $rootDir )

        $found = @( $found | Get-Item -ea 'continue' -force | % Parent )


        if( ! $PassThru ) { return $found }

        $binGit = gcm -CommandType Application 'git' -ea 'stop' -TotalCount 1
        foreach($item in $found) {
            $curRepo = Get-Item $Item
            # pushd $curRepo
            try {

                <#
                might return:
                    error: No such remote 'origin'
                #>
                $urlOrigin = & $binGit -C $curRepo remote get-url origin
                $urlOrigin = $urlOrigin -replace '(\.git)$', ''
                # $urlOrigin = git -C $curRepo remote get-url origin
            } catch {
                $urlOrigin = ''
            }

            $info = [ordered]@{
                PSTypeName = 'mintils.git.repository.record'
                Name       = $curRepo.Name
                RepoUrl    = $urlOrigin
                FullName   = $curRepo
                # | Get-Item -Force -ea Continue
                # | % Parent
            }
            [pscustomobject] $info
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

function Find-MintilsVsCodeWorkspace {
    <#
    .synopsis
        Fast find vscode workspaces using 'fd' find for speed
    .NOTES
    the original command was:
        fd -d8 -td '\.git' -H | Get-Item -Force | % Parent
        fd -d3 -td '\.git' -H --absolute-path --base-directory 'H:\data\2025' | Get-Item -Force

    else, fallback to
        gci .. -Recurse -Directory '.git' -Hidden | split-path | gi

    clean: #29: refactor by calling wrapper: 'Invoke-FdFind'
    .EXAMPLE
        # Search current dir
        > Mint.Find-VsCodeWorkspace
    .EXAMPLE
        # Search other dir
        > Mint.Find-VsCodeWorkspace -BaseDirectory 'h:\data\2025'
    .link
        Mintils\Find-MintilsWorkspace
    .link
        Mintils\Find-MintilsGitRepository
    .link
        Mint.Find-VsCodeWorkspace -IncludeVsCodeFolders
        # outputs: .vscode' and '.code-workspace'
    #>
    [Alias(
        'Mint.Find-VsCodeWorkspace',
        'Mint.Find-CodeWorkspace'
    )]
    [OutputType( [System.IO.FileInfo] )]
    [CmdletBinding()]
    param(
        # Base directory to search from, else current.
        # for: fd --base-directory
        [Parameter()]
        [Alias('Name', 'RootDir' )]
        [string] $BaseDirectory = '.',

        # for: fd --max-depth <int>
        [Alias('Depth')]
        [int] $MaxDepth = 5,


        # Search includes for '.vscode' folders
        [Alias('IncludeFolders')]
        [switch] $IncludeVsCodeFolders
    )
    begin {}
    process {}
    end {
        $rootDir = Get-Item -ea 'stop' $BaseDirectory
        "Depth: ${MaxDepth}, Extension: 'code-workspace', Root: ${RootDir}" | Write-Verbose
        $pathSeparator = '/'
        fd --max-depth $MaxDepth --type 'file' -e 'code-workspace' --absolute-path --path-separator $pathSeparator --base-directory $rootDir
            | Get-Item -ea 'continue'

        if( $IncludeVscodeFolders ) {
            fd --max-depth $MaxDepth --type 'directory' '\.vscode' --absolute-path --path-separator $pathSeparator --base-directory $rootDir --hidden
                | Get-Item -ea 'continue'
        }
    }
}

function Format-MintilsConsoleFileUri {
    <#
    .synopsis
        Converts paths into a console clickable file uris ( Try ctrl+LMB )
    .description
        Writes filepath to terminal using escape sequances for clickable filepath uris

        renders as relativepath, but resolves as full path

        example output:
            ␛]8;;c:\temp\readme.md␛\readme.md␛]8;;␛\

        an OSC Sequence starts with:
            '␛]'
        and ends with
            '␛\'
    .notes
        Check how support varies using the '␇' vs '␛\' syntax
    .example
        # If you have 'c:\pwsh\examples\example.ps1'

        > pushd 'c:\pwsh\examples'
        > Mint.Format-ConsoleFileUri -InObj ( gci . *.ps1 )
            # out: 'example.ps1'

        > Mint.Format-ConsoleFileUri -InObj ( gci . *.ps1 ) -RelativeTo (gi ..)
            # out: 'examples\example.ps1'
    .example
        > Mint.Format-ConsoleHyperlink -Name 'readme' -Uri ([uri] 'c:\temp\readme.md' ) | Mint.Format-ControlSymbols
        # out:

            ␛]8;;file:///c:/temp/readme.md␇readme␛]8;;␇
    .example
        > $relPath = [IO.Path]::GetRelativePath( ( Join-path $file.Directory '..'),  $file.FullName )
        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri $File.FullName

            readme.md

        > Mint.Format-ConsoleHyperlink -name 'readme' -Uri 'c:\foo\readme.md' | Mint.Format-ControlChars

            ␛]8;;c:\foo\readme.md␇readme␛]8;;␇

        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri $File.FullName | Mint.Format-ControlChars
   .link
        Mintils\Format-MintilsConsoleHyperlink
   .link
        Mintils\Format-MintilsConsoleFileUri
    .link
        Pansies\New-Hyperlink
    .link
        https://en.wikipedia.org/wiki/ANSI_escape_code
    #>
    [Alias('Mint.Format-ConsoleFileUri', 'Mint.ConsoleFileUri')]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        [Alias('BasePath')]
        [Parameter(Position = 0)]
        $RelativeTo = '.',

        # Strings / paths to convert
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]] $Path
    )
    begin {
        $relativeRoot = Get-Item -ea 'stop' $RelativeTo
    }
    process {
        foreach( $item in $Path ) {
            $item = Get-Item $item -ea 'stop'
            $relPath = [IO.Path]::GetRelativePath( <# relativeTo #> $relativeRoot, <# path #> $item.FullName )
            [uri] $uri = $item.FullName

            # original gist had used: "`e]8;;${uri}`e\${relPath}`e]8;;`e\"
            Format-MintilsConsoleHyperlink -InputObject $relPath -Uri $Uri
        }
    }
}

function Format-MintilsConsoleHyperlink {
   <#
   .synopsis
        A more generic Format-MintilsConsoleFileUri, without requiring it to be a filepath
    .notes

    .example
        > Mint.Format-ConsoleHyperlink -Name 'offset' -Uri 'https://dax.guide/offset/'
    .example
        > $file = Get-Item 'readme.md'
        > Mint.Format-ConsoleHyperlink -Name $file.Name -Uri ([Uri] $File.FullName )
            # 'readme.md' but LMB opens the full path
    .example
        > $relPath = [IO.Path]::GetRelativePath(
            ( Join-path $file.Directory '..'), $file.FullName )

        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri ([Uri] $File.FullName )
            # 'parentDir\readme.md' that opens full path on click
    .example
        # Open page in your web browser
        > Mint.Format-ConsoleHyperlink -Name 'docs: Offset()' -Uri 'https://dax.guide/offset/'

        # Open windows control panel
        > Mint.Format-ConsoleHyperlink -Name 'control panel: sound' -Uri 'ms-settings:sound'
        > Pansies\New-Hyperlink 'control panel for sound' -Uri 'ms-settings:sound'
    .example
        > Mint.Format-ConsoleHyperlink -Name 'control panel: sound' -Uri 'ms-settings:sound' | Mint.ShowControlChars

            ␛]8;;ms-settings:sound␇control panel: sound␛]8;;␇
    .link
        https://gist.github.com/Jaykul/f46590c0f726dd6a4424ffa614ed1545
    .link
        Pansies\New-Hyperlink
    .link
        Mintils\Format-MintilsConsoleFileUri
    .link
        Mintils\Format-MintilsConsoleHyperlink
    .link
        https://github.com/PoshCode/Pansies/blob/main/Docs/New-Hyperlink.md
   #>
    [Alias( 'Mint.Format-ConsoleHyperlink', 'Mint.ConsoleHyperlink')]
    [CmdletBinding()]
    param(
        # The Uri the hyperlink should point to
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string] $Uri,

        # The text of the hyperlink (if not specified, defaults to the URI)
        [ValidateNotNullOrEmpty()]
        [Alias('Text', 'Name' )]
        [Parameter(ValueFromRemainingArguments)]
        [String] $InputObject = $Uri
    )
    $8 = [char] 27 + "]8;;"
    "${8}{0}`a{1}${8}`a" -f ( $Uri, $InputObject )
}

function Format-MintilsFullNameWithLineNumbers {
    <#
    .SYNOPSIS
        formats optional numbers in the format: path[:lineNumber[:columnNumber]]
    .description
        Future could extend this to use the relative/reverse path syntax too
    .example
        > _Format-FulLNameWithLineNumber -Path 'foo.ps1'
        > _Format-FulLNameWithLineNumber -Path 'foo.ps1' -Line 234
        > _Format-FulLNameWithLineNumber -Path 'foo.ps1' -Line 234 -Col 23

        # outputs:
            foo.ps1
            foo.ps1:234
            foo.ps1:234:23
    #>
    [Alias(
        'Mint.Format-FullNameWithLineNumber',
        '_Format-FullNameWithLineNumbers' # previously used internal name
    )]
    [OutputType( [string] )]
    param(
        [Alias('FullName', 'File', 'PSPath' )]
        [object] $Path,

        [Alias('LineNumber')]
        [int] $StartLineNumber,

        # if LineNumber is not set, ColNumber is ignored.
        [Alias('ColNumber')]
        [int] $StartColumnNumber

        # [ValidateScript({throw 'nyi'})]
            # [switch] $JustToLastLine,

        # [ValidateScript({throw 'nyi'})]
            # [switch] $UseReverseIndex
    )
    if( [string]::IsNullOrEmpty( $Path ) ) { return }

    # allows it to render for not-yet-existing-paths
    $Item     = Get-Item $Path -ea ignore
    $fullName = $Item.FullName ?? $Path    # $Item.FullName ? $Item.FullName : $Path

    [string] $renderText = @(
        $fullName
        if( $StartLineNumber ) { ':{0}' -f $StartLineNumber }
        if( $StartLineNumber -and $StartColumnNumber ) { ':{0}' -f $StartColumnNumber }
    ) -join ''

    if( -not (Test-Path $Path )) { }
    return $renderText
}

function Format-MintilsRelativePath {
    <#
    .synopsis
        Sugar that converts paths relative a base dir
    .example
        # Print paths relative the current Directory
        gci . -Depth 2 | Mint.Format-RelativePath
    .example
        > Get-Item 'H:\github_fork\Pwsh\SeeminglyScience👨\EditorServicesProcess', 'H:\github_fork\Pwsh\Trackd👨'
            | Mint.Format-RelativePath 'H:\github_fork\Pwsh'

        SeeminglyScience👨\EditorServicesProcess
        Trackd👨
    #>
    [Alias('Mint.Format-RelativePath')]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        [Alias('BasePath')]
        [Parameter(Position = 0)]
        $RelativeTo = '.',

        # Strings / paths to convert
        [Alias('PSPath', 'FullName', 'InObj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [string[]] $Path,

        # Emit an object with path properties, including the raw original path
        [Alias('PassThru')]
        [switch] $AsObject
    )
    process {
        $RelativeTo = Get-Item $RelativeTo
        foreach( $item in ( $Path | Convert-Path ) ) {
            $relPath = [System.IO.Path]::GetRelativePath(
                <# string: relativeTo #> $RelativeTo,
                <# string: path #>  $Item )

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


function Format-MintilsShowControlSymbols {
    <#
   .synopsis
        Replace ansi escape sequences with safe-to-print control char symbols
    .notes
        Basically map any c0 value by adding 0x2400 to the codepoint: https://www.compart.com/en/unicode/block/U+2400

    .example
        # Inspect what strings pansies/PSStyle are generating safely, by replacing control sequences

        > Pansies\New-text -fg Magenta4 'hi world' | Mint.Format-ControlChars
        > Pansies\New-text -fg Magenta4 'hi world' -bg (Get-Complement 'magenta4') | Mint.Format-ControlChars

            ␛[38;2;139;0;139mhi world␛[39m
            ␛[48;2;0;139;0m␛[38;2;139;0;139mhi world␛[49m␛[39m
    .example
        # 24/n bit syntax

        > [PoshCode.Pansies.RgbColor]::ColorMode = 'ConsoleColor'
        > New-Text -fg 'blue' -Object 'foo' | Mint.Format-ControlChars

        > [PoshCode.Pansies.RgbColor]::ColorMode = 'Rgb24Bit'
        > New-Text -fg 'blue' -Object 'foo' | Mint.Format-ControlChars

            ␛[94mfoo␛[39m
            ␛[38;2;0;0;255mfoo␛[39m
    .example
        > Mint.Format-ConsoleHyperlink -Name 'offset' -Uri 'https://dax.guide/offset/'
    .example
        > $file = Get-Item 'readme.md'
        > Mint.Format-ConsoleHyperlink -Name $file.Name -Uri ([Uri] $File.FullName )
            # 'readme.md' but LMB opens the full path
    .example
        > $relPath = [IO.Path]::GetRelativePath(
            ( Join-path $file.Directory '..'), $file.FullName )

        > Mint.Format-ConsoleHyperlink -Name $relPath -Uri ([Uri] $File.FullName )
            # 'parentDir\readme.md' that opens full path on click
    .example
        # Open page in your web browser
        > Mint.Format-ConsoleHyperlink -Name 'docs: Offset()' -Uri 'https://dax.guide/offset/'

        # Open windows control panel
        > Mint.Format-ConsoleHyperlink -Name 'control panel: sound' -Uri 'ms-settings:sound'
        > Pansies\New-Hyperlink 'control panel for sound' -Uri 'ms-settings:sound'
    .link
        https://gist.github.com/Jaykul/f46590c0f726dd6a4424ffa614ed1545
    .link
        Pansies\New-Hyperlink
    .link
        Mintils\Format-MintilsConsoleFileUri
    .link
        Mintils\Format-MintilsConsoleHyperlink
    .link
        https://github.com/PoshCode/Pansies/blob/main/Docs/New-Hyperlink.md
   #>
    [Alias(
        'Mint.Format-ControlSymbols',
        'Mint.Format-ControlChars',
        'Mint.ShowControlChars'
    )]
    [CmdletBinding()]
    param(
        [Alias('Content', 'Text')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputText
    )
    process {
        # I'm assuming this isn't super performant, but it's good enough for smallish strings
        foreach ( $line in $InputText) {
            ($line).ToString()?.EnumerateRunes() | ForEach-Object {
                if ( $_.Value -le 0x1f ) {
                    [Text.Rune]::new( $_.Value + 0x2400 )
                }
                else { $_ }
            } | Join-String -sep ''
        }
    }
}

function Format-MintilsTextPredent {
    <#
    .synopsis
        Indent lines using depth, or number of characters
    .example
        # To Visualize the padding added
        Pwsh> 0..2 | Mint.Format-TextPredent -PrefixString ␠ -Depth 2 -TabSize 2

        ␠␠␠␠0
        ␠␠␠␠1
        ␠␠␠␠2

        Pwsh> 0..2 | Mint.Format-TextPredent -PrefixString ␠ -Depth

        ␠␠␠␠␠␠␠␠0
        ␠␠␠␠␠␠␠␠1
        ␠␠␠␠␠␠␠␠2

    .EXAMPLE
    # Summarizing using depth

    'Datetime'

    'Properties' | Mint.Format-TextPredent
    (Get-Date | Fime -MemberType Property).Name
        | Sort-Object -Unique
        | Mint.Format-TextPredent -Depth 2

    'Methods' | Mint.Format-TextPredent
    (Get-Date | Fime -MemberType Method).Name
        | Sort-object -Unique
        | Mint.Format-TextPredent -Depth 2
    #>
    [Alias(
        'Mint.Format-TextPredent',
        'Mint.Text-Predent' )]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        # lines of input
        [Alias('Content', 'Text', 'Lines')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputText,

        # What level to indent as. The Default is 1 = 4 spaces, 2 = 8 spaces, etc.

        [Parameter( Position = 0 )]
        [ArgumentCompletions( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]
        [Alias('Level')]
        [int] $Depth = 1,

        # One $Depth is ( $Str * $TabSize ). ie: 2, 4, etc.
        [ArgumentCompletions( 0, 1, 2, 3, 4, 5, 6, 7, 8, 9)]
        [int] $TabSize = 4,

        # what gets multiplied. The default is a ' '
        [ArgumentCompletions( "' '", "`u{2420}", '"`t"', "' - '")]
        [string] $PrefixString = ' ',

        # When multiple are passed
        [string] $Separator = "`n"

    )
    begin {
        $Prefix = $PrefixString * ($Depth * $TabSize) -join ''
        [Collections.Generic.List[string]] $lines = @()
        # $found_count = 0
        # if( $PSCmdlet.MyInvocation.InvocationName -in ('Mint.RandomOne' ) ) {
        #     $MaxCount = 1
        # }
    }
    process {
        $lines.AddRange( [string[]] $InputText )
    }
    end {
        $lines | Join-String -f "${Prefix}{0}" -Sep $Separator
    }
}

function Get-MintilsExecutionContextCommandName {
    <#
    .SYNOPSIS
        sugar that wraps "$ExecutionContext.InvokeCommand.GetCommandName"
    .notes
        Maybe allow returning (Get-Item) as an option
    .example
        > Mint.ExContext.Get-CommandName -Name py
        # py.exe
    .EXAMPLE
        > 'py', 'fd', 'dsf' | Mint.ExContext.Get-CommandName
    .link
        Mintils\Mint.ExecutionContext-Get-CommandName
    .link
        Mintils\Mint.ExecutionContext.Get-CommandNames
    .link
        System.Management.Automation.CommandInvocationIntrinsics
    #>
    [Alias(
        'Mint.ExecutionContext.Get-CommandName',
        'Mint.ExContext.Get-CommandName'
    )]
    [CmdletBinding()]
    [OutputType( [Management.Automation.CommandInfo], [string] )]
    param(
        [Parameter(mandatory, ValueFromPipeline)]
        [string] $Name,
        [switch] $NameIsPattern,

        # output filepath as name only
        [switch] $AsText
    )
    process {
        $query = $ExecutionContext.InvokeCommand.
            GetCommandName( $Name, $NameIsPattern, $true )
        if( $query.count -eq 0 ) { return }

        if( $asText ) { return $query }

        Get-Command ( $Query | Get-Item )
    }
}

function Get-MintilsExecutionContextCommands {
    <#
    .SYNOPSIS
        sugar that wraps "$ExecutionContext.InvokeCommand.GetCommands"
    .notes
        Maybe allow returning (Get-Item) as an option
    .example
        # default is all types
        > 'git' | Mint.ExContext.Get-Commands

        # limit to applications / not functions
        > 'git' | Mint.ExContext.Get-Commands -CommandTypes Application
    .example
        # wildcard search
        > Mint.ExContext.Get-Commands -Name '*git*' -NameIsPattern |ft
    .link
        Mintils\Mint.ExecutionContext-Get-CommandName
    .link
        Mintils\Mint.ExecutionContext.Get-Commands
    .link
        System.Management.Automation.CommandInvocationIntrinsics
    #>
    [Alias(
        'Mint.ExecutionContext.Get-Commands',
        'Mint.ExContext.Get-Commands'
    )]
    [OutputType( [Management.Automation.CommandInfo] )]
    [CmdletBinding()]
    # [OutputType( [Collections.Generic.List[String]] )]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Name,

        [Management.Automation.CommandTypes] $CommandTypes = 'All', # all

        # name uses wildcard pattern, otherwise exact match
        [switch] $NameIsPattern
    )
    process {
        $ExecutionContext.InvokeCommand.GetCommands(
            <# string #> $Name,
            <# CommandTypes #> $CommandTypes,
            <# bool #> $NameIsPattern )
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

function Get-MintilsTypeFormatData {
    <#
    .synopsis
        Get TypeData and Formatdata with some sugar
    .NOTES
    .EXAMPLE
    #>
    [Alias(
        'Mint.Get-TypeFormatData'
    )]
    # [OutputType( [System.IO.FileInfo] )]
    [CmdletBinding()]
    param(
        # type, or object to get the type of
        [Parameter(Mandatory)]
        [Alias('Name', 'Type', 'InObj' )]
        [object] $InputType
    )
    begin {}
    process {}
    end {
        $name  = $InputType -is [string] ? $InputType : $InputType.GetType()
        $fdata = Get-FormatData -TypeName $name
        $tdata = Get-TypeData -TypeName $name

        "Query: $name" | Write-Verbose
        $data = [ordered]@{
            PSTypeName = 'Mintils.TypeAndFormatData.Info'
            FormatData = $fdata
            TypeData   = $tdata
        }
        [pscustomobject]$data
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

function Get-MintilsUniquePropertyValue {
    <#
    .synopsis
        From a list of objects: Get the Unique list of all values for a property name
    .DESCRIPTION
        Output is case-sensitive
    .EXAMPLE
        Get-Command | Mint.Get-UniquePropValues -Name Source
    .EXAMPLE
        Get-Alias   | Mint.Get-UniquePropValues -Name Source
    #>
    [Alias( 'Mint.Get-UniquePropValue', 'Get-MintilsUniquePropertyValues' )]
    [OutputType( [string[]] )]
    [CmdletBinding()]
    param(
        # Which property to inspect
        [Alias('Name')]
        [Parameter(Mandatory)]
        [string] $PropertyName,

        # objects to inspect
        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]] $InputObject,

        # Keep or ignore a [String]::Empty
        [switch] $KeepEmptyValue = $true,

        # keep or ignore whitespace-only strings
        [switch] $KeepWhitespaceOnlyValue,

        # The default mode will sort. You can choose to preserve the order each was visited
        [Alias('NoSort')]
        [switch] $WithoutSort,

        # uses casesenstive compare by default
        [Alias('UsingCaseInsensitive')]
        [ValidateScript({throw 'nyi'})]
        [switch]$CaseInsensitive
    )
    begin {
        [Collections.Generic.HashSet[string]] $hset = @()

        # [Collections.Generic.List[Object]] $Items = @() # allow sort-object unique on object types ?? or just strings
    }
    process {
        foreach($Obj in $InputObject) {
            $value = $Obj.$Propertyname
            if( $Null -eq $Value ) { continue }
            $isEmptyStr = [string]::Empty -eq $value

            if( $isEmptyStr -and $KeepEmptyValue ) {
                $null = $hset.Add( $value )
                continue
            }
            if(
                -not $isEmptyStr -and
                     $KeepWhitespaceOnlyValue -and
                     [string]::IsNullOrWhiteSpace( $value )
            ) {
                $null = $hset.Add( $value )
                continue
            }
            $null = $hset.Add( $value )
            # if( -not $KeepEmptyValue          -and [string]::IsNullOrEmpty( $value ) )      { continue }
            # if( -not $KeepWhitespaceOnlyValue -and [string]::IsNullOrWhiteSpace( $value ) ) { continue }

            # $null = $hset.Add( $value )
        }
    }
    end {
        if( $WithoutSort ) { return $hset }
        $hset | Sort-Object
    }
}

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

function Get-MintilsVariableSummary {
    <#
    .SYNOPSIS
        summarize and search for variables in scope, without errors when missing
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -HasPrefix 'PS'
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -HasPrefix host -HasSuffix 'preference'
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -PartialNames style
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -BeginsWith '_'  -PartialNames 'editorservices', 'vscode'
    .EXAMPLE
        Pwsh> Mint.Get-VariableSummary -PartialNames 'last' -Scope script # nothing
        Pwsh> Mint.Get-VariableSummary -PartialNames 'last' -Scope global # returns $LASTEXITCODE
    #>
    [CmdletBinding()]
    [Alias('Mint.Get-VariableSummary')]
    [OutputType( 'Mintils.Variable.Summary' )]
    param(
        # exact match
        [ArgumentCompletions(
            'GitLogger', 'Logs', 'CurMetric' )]
        [string[]] $ExactNames, # ( 'curMetric', 'logs', 'GitLogger' ),

        # wildcard match
        [ArgumentCompletions(
            'Git', 'GitLogger', '__', 'PS' )]
        [string[]] $PartialNames,

        # wildcard prefix at the start, ex: 'dunder'
        [Alias('BeginsWith')]
        [ArgumentCompletions(
            '__', 'PS' )]
        [string[]] $HasPrefix,

        # wildcard prefix # dunder?
        [Alias('EndsWith')]
        [ArgumentCompletions(
            'preference', 'culture', 'Parameters' )]
        [string[]] $HasSuffix,

        # By name or depth as [int]. Or implicit default.
        [ArgumentCompletions(
            'script', 'global', 0, 1, 2, 3, 4, 5
        )]
        [string] $Scope,

        # Future: Instead of scope 0, you can say -FromTop 0 to get the top most
        # scope. ( cmdlet handles iterating each until an exception is thrown. silently for you.)
        [ValidateScript({throw 'nyi: Relative offset for scope fromTop'})]
        [ArgumentCompletions( 0, 1, 2, 3)]
        [uint] $DepthFromTop,

        [Alias('DebugQuery')]
        [switch] $ShowQuery
    )

    [System.Collections.Generic.List[Object]] $names = @()
    $getVars = @{
        ErrorAction = 'ignore'
    }

    if( $MyInvocation.BoundParameters.ContainsKey('Scope') ) {
        $getVars['Scope'] = $Scope
    }
    if( $MyInvocation.BoundParameters.ContainsKey('ExactNames') ) {
        $names.addRange( @( $ExactNames ))
    }
    if( $MyInvocation.BoundParameters.ContainsKey('PartialNames') ) {
        $names.addRange( @(
            $PartialNames.forEach({ "*${_}*"  })
        ))
    }
    if( $MyInvocation.BoundParameters.ContainsKey('HasPrefix') ) {
        $names.addRange( @(
            $HasPrefix.forEach({ "${_}*"  })
        ))
    }
    if( $MyInvocation.BoundParameters.ContainsKey('HasSuffix') ) {
        $names.addRange( @(
            $HasSuffix.forEach({ "*${_}"  })
        ))
    }

    if( $Names.count -gt 0 ) {
        $getVars['Name'] = $names
    }

    if( $ShowQuery ) {
        ( $getVars
            | ConvertTo-Json -Depth 4 ) -split '\r?\n'
            | Join-String -f "`n    {0}" -os "`n"
            | Join-String -op "call Get-Variable => "
            | Write-Host -fg $Color.InfoDark -bg 'gray25'
    }

    $found =
        try {
            Get-Variable -ea ignore @getVars # Test whether I must use stop to catch
        } catch {
            if($_.Exception.Message -match 'scope.*exceeds.*number' ) {
                'Scope exceeds max depth: -Scope {0}' -f $getVars['Scope']
                return
            }
            # the rest is unexpected
            throw
        }
    if( $found.count -eq 0 ) {
        '0 matches found!' | Write-Host -fg 'gray60'
        return
    }
    $found <# todo: convert to a type data instead #>
        | %{
            $tinfo      = ( $_.Value)?.GetType()
            $abbrName   = ($tinfo).Name
            $abbrBounds = @(
                if($_.Value -is [Array]) { 'IsArray' }
                'Count: {0}' -f $_.Value.Count
                'Len: {0}'   -f $_.Value.Length
            ) -join ', '

            [pscustomobject]@{
                PSTypeName = 'Get-Variable.SummaryResult'
                Name     = $_.Name
                TypeAbbr = $abbrName   # ( $_.Value)?.GetType().Name
                Bounds   = $abbrBounds
                Instance = $_.Value
            }
        }
        | Sort-Object -Property Name
}


$script:__cache_Get_TextStyle = @{}
function Get-MintilsTextStyle {
    <#
    .SYNOPSIS
        Get text colors by style name
    .example
        # Show all defined styles
        > Mint.Get-TextStyle -ListAll | ft
    .example
        # Get matching <Name> or first match using -like <Name>
        > Mint.Get-TextStyle Gray
    .example
        # Get strict matches only
        > Mint.Get-TextStyle Gray -ExactOnly -Verbose

        VERBOSE: ambigous styles found!: Gray.Bright.BoldContrast, Gray.Dark.LowContrast
        Exception: Strict match Name: 'Gray' failed, found 2 matches!
    #>
    [Alias(
        'Mint.Get-TextStyle'
        # 'Mint.TextStyle'
    )]
    [CmdletBinding()]
    param(
        # Select first matching pattern
        [Parameter(Mandatory, ParameterSetName='ByNameLookup', Position = 0 )]
        [Alias('Name', 'ByName', 'Theme')]
        [string] $StyleName,

        # only select one exact match
        [Parameter(ParameterSetName='ByNameLookup')]
        [Alias('Strict', 'ExactOnly')]
        [switch] $OneOrNone,

        [Parameter(Mandatory, ParameterSetName='ByListAll')]
        [Alias('All', 'List')]
        [switch] $ListAll,

         # output contains only Fg and Bg to make splatting simpler
        [Parameter( ParameterSetName = 'ByNameLookup' )]
        [Alias('OutputAsHash','AsHash' )]
        [switch] $AsSplatableHash
    )
    $CacheLookup = $script:__cache_Get_TextStyle

    switch( $PSCmdlet.ParameterSetName ) {
        'ByNameLookup' {
            $splat = @{
                ByName    = $StyleName
                OneOrNone = $OneOrNone
                AsSplatableHash = [bool] $AsSplatableHash
            }

            if( $AsSplatableHash -and $CacheLookup.Contains( $StyleName ) ) {
                return $CacheLookup[ $StyleName ]
            }
            $found = _Get-TextStyle @splat
            $cacheLookup[ $StyleName ] = $found

            return $found
        }
        'ByListAll' {
            _Get-TextStyle -ListAll
        }
        default {
            throw "Unhandled ParameterSetName: '$( $PSCmdlet.ParameterSetName )' !"
        }
    }
}

function Invoke-MintilsAppVsCode {
    <#
    .synopsis
        Opens VS Code
    .description
    .example
        > $Profile | Get-Item | Mint.Invoke-App.VsCode
        > $Profile | Get-Item | Mint.VsCode
    .link
        https://code.visualstudio.com/docs/configure/command-line
    #>
    [CmdletBinding()]
    [Alias(
        'Mint.Invoke-App.VsCode',
        'Mint.VsCode'
    )]
    [CmdletBinding()]
    param(
        [ValidateNotNull()]
        [Alias('PSPath', 'Path', 'File', 'Goto')]
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName, ParameterSetName = 'FromInput' )]
        [object] $InputObject,

        [Parameter(ValueFromPipelineByPropertyName)]
        [string] $FileWithLineNumberString = '',

        # show dynamic help
        [Parameter(Mandatory, ParameterSetName = 'HelpOnly' )]
        [Alias('Help')]
        [switch] $ShowHelp,

        # Log what would be opened, but does not run 'code'
        [Alias('TestOnly')]
        [switch] $WhatIf,

        # write file names to console
        [switch] $PSHost,

        # Jump to the last line using relative line number instead
        [ValidateScript({throw 'nyi'})]
        [switch] $GotoEnd
    )
    begin {
        if( $ShowHelp ) {
            & ( Mint.Require-App 'code' ) @( '--help' )
            New-HyperLink -Text 'docs: vscode commandline' -Uri 'https://code.visualstudio.com/docs/configure/command-line'
        }
    }
    process {
        if( $ShowHelp -or $PSCmdlet.ParameterSetName -eq 'HelpOnly' ) { return }
        [Collections.Generic.List[Object]] $binArgs = @()

        # Attempt to convert input to filepath
        $file = Get-Item -ea 'ignore' $InputObject.File
        if( -not $File ) {
            $file = Get-Item -ea 'ignore' $InputObject
        }
        # or, grab filepath from a command type
        if( -not $File ) {
            $maybe_funcDef = Mint.Find-FunctionDefinition -PassThru -InputObject $InputObject
            if( Test-Path -ea Ignore $maybe_funcDef.File ) {
                $file = Get-Item -ea ignore $maybe_funcDef.File
             }
        }

        if( -not $File ) {
            'File did not exist for type: ' -f ( ( $InputObject )?.GetType() )
                | Write-Error
            return
        }

        # try to use Mint.Find-FuncDef's output
        $binArgs = @(
            '--goto'
            if( $FileWithLineNumberString ) { $FileWithLineNumberString }
            else { $File.Fullname }
            # if( $File.FileWithLineNumberString ) { $File.FileWithLineNumberString }
            # else { $File.Fullname }
        )

        $render_args = $binArgs | Join-String -sep ' ' -op 'invoke "code" => '
        $render_args | Write-Verbose
        if( $WhatIf -or $PSHost ) {
            $render_args | Write-Host -fg 'gray70' -bg 'gray30'
        }

        if( $WhatIf ) { return }
        if( Test-Path $File ) {
            & ( Mint.Require-App 'code' ) @BinArgs
        } else {
            'File did not exist for type: ' -f ( ( $InputObject )?.GetType() ) | Write-Error
            return
        }
    }
    end { }
}



function Invoke-MintilsAppWithConfirm {
    <#
    .SYNOPSIS
        Invokes command line apps: with [1] user prompt to run it, and [2] log CLI args used
    .DESCRIPTION
        If -UseConfirm is set, it will prompt the user before invoking.
        if false, run without requiring prompt. But logs by default.

        - todo: future will support input pipeline, with confirmation
    .example
        # The main short syntax, without requiring parameter names
        # [1] print the CLI args, then run without confirm
        > Mint.Invoke-App gh 'repo', 'list'

        # [2] Same thing but require confirmation
        > Mint.Invoke-AppWithConfirm gh 'repo', 'list'
    .example
        # main use prompt to run a command
        > Mint.Invoke-AppWithConfirm -Name 'code' -Args @( '--goto', $Profile.CurrentUserAllHosts ) -Confirm
    .EXAMPLE
        # Run the command as normal, capture results
        # show command line args on the host
        > $found = Mint.Invoke-AppWithConfirm -Name 'fd'
            # out: Mint.InvokeApp => fd --color=never
    .example
        # Do not log cli args to host
        $found = Mint.Invoke-AppWithConfirm -Name 'fd' -Silent
    #>
    [Alias(
        'Invoke-MintilsApp',
        'Mint.Invoke-App',
        'Mint.Invoke-AppWithConfirm' )]
    [CmdletBinding()]
    param(
        [Alias('Name')]
        [string] $CommandName,

        [Alias('Args', 'ArgList')]
        [object[]] $CommandLineArgs,

        # never run the final command
        [Alias('TestOnly', 'EchoWithoutRun')]
        [switch] $WhatIf,

        # Default runs the command without prompt, if true then it requires a prompt.
        # Smart aliases change the default if named 'WithConfirm'
        [Alias('Confirm')]
        [switch] $UseConfirm,

        # The default action is to write text to the console or verbos
        [Alias('WithoutPSHost', 'WithoutArgsEcho' )]
        [switch] $Silent,

        # Auto complete frequently used
        [ArgumentCompletions(
            "'--color=always'", "'--color=never'" )]
        [string[]] $TemplateArgs
    )
    begin {
        if( $PSCmdlet.MyInvocation.InvocationName -in @( 'Mint.Invoke-App', 'Invoke-MintilsApp' ) ) {
            $UseConfirm = $false
        }
        if( $PSCmdlet.MyInvocation.InvocationName -match 'WithConfirm' ) {
            $UseConfirm = $True
        }
        'Smart aliases resolved $UseConfirm as {0}' -f $UseConfirm | Write-Debug
        # if( $PSCmdlet.MyInvocation.InvocationName -in @( 'Mint.Invoke-AppConfirm', 'Mint.Invoke-AppWithConfirm' ) ) {
    }
    end {
        $CommandLineArgs = @( $CommandLineArgs; $TemplateArgs; )
        [string] $RenderArgs = $CommandLineArgs | Join-String -sep ' ' -op "${CommandName} "

        if( -Not $Silent ) {
            $RenderArgs
                | Join-String -op 'Mint.InvokeApp => '
                | Mint.Format-TextPredent -Depth 1 -TabSize 2 | Write-Host -fg SteelBlue # -fg SlateGray -bg 'gray20'
        }

        if( $UseConfirm ) {
            $HasConfirmed = $PSCmdlet.ShouldContinue(
                "Execute command?: ${RenderArgs}",
                "Invoke App: ${CommandName}" )
            if( -not $HasConfirmed ) {
                return
            }
        }

        $RenderArgs | Join-String -op "Invoking => " | Write-Verbose
        if( $WhatIf ) { return }
        & ( Mint.Require-App $CommandName ) @CommandLineArgs
    }
}

function New-MintilsHashSetFileSystemInfo {
    <#
    .SYNOPSIS
        return a New hashset for type: [FileSystemInfo] with Case-Insensitive comparisons
    .notes
        Should paths with a trailing '/' or '\' be considered a duplicate? Is there any cases that removing the suffix will break older apps ?
    .example
        > $Collection = @( $Env:Path -split [IO.Path]::PathSeparator  -as [IO.DirectoryInfo[]] )
        > $set = _New-HashSet.FileSystemInfo -Collection $Collection
        > $Collection.count, $set.count
    .example
        $collection  = @( $Env:PATH -split [IO.Path]::PathSeparator  -as [IO.DirectoryInfo[]] )
        $more =  gci 'c:\foo\bar' -directory
        $pathSet = Mint.New-HashSet.FileInfo -Collection $collection
        foreach($item in $More) { $null = $pathSet.Add( $item ) }
        $pathSet -join [IO.Path]::PathSeparator | Write-host -fore salmon
    .example
        # See: <file:///./../../../Tests/Public/New-HashSet.FileSystemInfo.ps1>  ( or: ${workspaceFolder}/Tests/Public/New-HashSet.FileSystemInfo.ps1 )
    #>
    [Alias(
        'New-MintilsHashSet.FileInfo',
        'Mint.New-HashSet.FileInfo'
    )]
    [CmdletBinding()]
    [OutputType( [System.Collections.Generic.HashSet[System.IO.FileSystemInfo]] )]
    param(
        [Alias('InputObject', 'Fullname', 'Path', 'Collection' )]
        # [System.IO.FileSystemInfo[]] $Collection = @(),
        [object[]] $InputCollection = @(),
        # [System.IO.FileSystemInfo[]] $Collection = @(),

        # future, will need the option
        [ValidateScript({throw 'nyi'})]
        [switch] $UsingCaseSensitive
    )

    [IO.FileSystemInfo[]] $Collection = @(
        _Coerce.FileSystemInfo.FromString -InputObject $InputCollection
    )

    $Comparer = [Collections.Generic.EqualityComparer[IO.FileSystemInfo]]::Create(
            <# equals: #>      { param( $x, $y ) $x.FullName -eq $y.FullName },
            <# getHashCode: #> { param( $x ) [StringComparer]::OrdinalIgnoreCase.GetHashCode( $x.FullName ) } )

    if( $Collection.count -gt 0 ) {
        $Set = [Collections.Generic.HashSet[IO.FileSystemInfo]]::new(
            <# collection: #> [IO.FileSystemInfo[]] $Collection,
            <# comparer: #>   $Comparer )
    } else {
        # todo: fix: still not returning empty set as expected.
        # I am manually calling the other ctor, otherwise the above ctor fails with by returning $Null instead of empty set
        # or, maybe is calling the other overload ?
        $Set = [Collections.Generic.HashSet[IO.FileSystemInfo]]::new( <# comparer: #> $Comparer )
    }
    if( $Null -eq $Set ) {
        throw "_New-HashSet.FileSystemInfo: Something failed creating HashSet[FileSystemInfo] !"
    }

    $set.GetType() | Join-String -op 'result typeof: ' | Write-Verbose
    return ,$Set
}

function New-MintilsRegexOrExpression {
   <#
   .synopsis
        Create a regex that combines a list into an OR. As patterns or as literals.
    .example
        > Mint.New-RegexOr -InputObject ('a'..'c' + 3.14 + 0..2 )
            (a|b|c|3.14|0|1|2)

        > Mint.New-RegexOr -InputObject ('a'..'c' + 3.14 + 0..2 ) -EscapeRegex
            (a|b|c|3\.14|0|1|2)
    .example
    > '[3', 'z' | Mint.New-RegexOr
    > '[3', 'z' | Mint.New-RegexOr -AsRegexLiteral
        ([3|z)
        (\[3|z)
    .example
    # Build a pattern for file extensions:
    > gci . -Recurse -File
        | % Extension | Sort-Object -Unique
        | Mint.New-RegexOr -AsRegexLiteral -FullMatch

    # out:
        ^(\.json|\.pbip|\.pbir|\.pbism|\.pbix|\.ps1)$
   #>
    [Alias( 'Mint.New-RegexOr')]
    [CmdletBinding()]
    param(
        [Alias('Pattern', 'Regex')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string[]] $InputObject,

        # Escape all patterns before joining them
        [Alias('AsRegexLiteral', 'AsLiteral')]
        [switch] $EscapeRegex,

        # Only join the distinct list of values
        [Alias('Distinct')]
        [switch] $Unique,

        # Default allows partial matches. This forces the full string to match the or codintion
        [Parameter()]
        [switch] $FullMatch
    )
    begin {
        [Collections.Generic.List[string]] $segments = @()

        $final_fstr = -not $FullMatch ? '({0})' : '^({0})$'
    }
    process {
        $segments.AddRange( $InputObject )
    }
    end {

        $segments
            | Sort-Object -Unique
            | Join-String -sep '|' -Prop {
                $EscapeRegex ? ([Regex]::Escape( $_ )) : $_ }
            | Join-String -f $final_fstr
            # or for a full match

        # foreach( $text in $Segments ) {
        #     [regex]::Escape( $text )
        # }
        # if( $EscapeRegex ) {
        # }
        # if( $InputObject.count -gt 0 ) {
        #     if( )
        # }
        # foreach( $item in $InputObject ) {
        #     $EscapeRegex ? ([Regex]::Escape( $item )) : $Item
        # }
        # if($EscapeRegex) {

        # }

        # @(foreach( $item in $InputObject ) {
        # $false ? ([Regex]::Escape( $item )) : $Item
        # }) | Join-String -sep '|'
        # | Join-String -f '^({0})$'

        # $InputObject
        # | Join-String -p {

        # }

    }
}


function New-MintilsSafeFilename {
    <#
    .SYNOPSIS
        Generate a "safe" filename using a template with the current time. ( Default is to the level of seconds )
    .NOTES
        Uses universal sortable, aka: 'u'
    .example
        > mint.New-SafeFilename
            # 2025-08-25_08-31-57Z

        > mint.New-SafeFilename -TemplateString 'screenshot-{0}.png'
            # screenshot-2025-08-25_08-31-57Z.png

        > mint.New-SafeFilename '{0}-main.log'
            # 2025-08-25_08-31-57Z-main.log

        > mint.New-SafeFilename 'AutoExport-{0}.xlsx'
            # AutoExport-2025-08-25_08-31-57Z.xlsx
    .link
        https://learn.microsoft.com/en-us/dotnet/standard/base-types/standard-date-and-time-format-strings#table-of-format-specifiers
    #>
    [Alias(
        'Mint.New-SafeFilename' )]
    [OutputType('System.String')]
    [CmdletBinding()]
    param(
        # Set format string used by "-f" format
        [Parameter(Position = 0)]
        [ArgumentCompletions(
            "'{0}.log'",
            "'{0}'",
            "'AutoExport-{0}.xlsx'",
            "'main-{0}.log'",
            "'{0}-main.log'",
            "'screenshot-{0}.png'"
        )]
        [string] $TemplateString = '{0}',

        [Alias('AsResolution')]
        [ValidateSet( 'Seconds', 'Milliseconds', 'Nanoseconds', 'Microseconds' )]
        [string] $Resolution = 'Seconds'
    )
    $fStr = switch( $Resolution ) {
        'Seconds' { 'u' }
        default { throw "Missing Template defintion for: ${Resolution}"}
    }
    $render = $TemplateString -f @(
        [datetime]::Now.ToString( $fStr ) -replace '[ ]+', '_' -replace ':', '-' )

    "Generated: '${render}' from template: ${TemplateString}" | Write-Verbose
    $render
}

function Push-MintilsLocation {
    <#
    .synopsis
        go to a path, auto convert-paths, since push/pop doesn't 2025-10-29
    .example
        # test whether types detect the correct properties
        $someFile = $Profile.CurrentUserAllHosts
        $someFile | Mint.Goto -Debug
        $someFile | Get-Item | Mint.Goto -Debug
        $Profile  | Mint.Goto -Debug
        (gmo mintils) | Mint.Goto -Debug -PassThru |% fullname
        (gmo mintils).Path | Mint.Goto -debug -PassThru | % Fullname
    #>
    [CmdletBinding()]
    [Alias( 'Mint.Push-Location', 'Mint.Goto')]
    param(
        # Goto Location of this file. Files and Directories are valid
        [Alias('FullName')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Object] $InputObject,

        # Directory or PSPath
        [Alias('PSPath')]
        [Parameter(ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [object] $Directory,

        # Also output the directory you moved to as an object
        [switch] $PassThru,

        # writes new path to the console as dim text
        [switch] $PSHost
        # [string] $StackName = 'mintils.goto' # might not affect user scope
    )
    begin {}
    end {
        $Resolved = _Resolve-DirectoryFromPathlike $InputObject
        Join-String -f 'Resolved: "{0}"' -InputObject ( $Resolved )?.ToString() | Write-Verbose

        if( $Null -eq $Resolved ){
            $Resolved = _Resolve-DirectoryFromPathlike $Directory
        }
        if( $Null -eq $Resolved ) {
            throw "Unhandled error resolving '${Resolved}' of type: '$( ( $Resolved)?.GetType() )' "
        }

        if( Test-Path -ea 'ignore' $Resolved.Directory ) {
            $null = Microsoft.PowerShell.Management\Push-Location -Path $Resolved.Directory #
        } elseif ( Test-Path -ea 'ignore' $Resolved ) {
            $null = Microsoft.PowerShell.Management\Push-Location -Path $Resolved
        }
        if( $PSHost ) {
            $Resolved | Join-String -f '    Move to => "{0}"'
                | Write-Host -bg 'gray20' -fg 'gray30'
        }

        # $null = Microsoft.PowerShell.Management\Push-Location -Path $Resolved.Directory # -StackName 'mintils.goto'
        if( $PassThru ) { return $Resolved } # emit objects instead of 'Push-Location'. Allowing found filename to be returned.
    }
}

function Quick-MintilsFilterByPropertyValue {
    <#
    .synopsis
        Takes a list of objects, prompts user with Fzf to select distinct values in that column, then filters to require those items
    .description
        Saves
            selected values to:      $LastMintFzfProps
            results after filtering: $LastMintFzf
    .EXAMPLE
        > Get-Alias | Mint.Quick-FilterByProperty -PropertyName Source
    .EXAMPLE
        > Find-Type | Mint.Quick-FilterByProperty Namespace
    #>
    [Alias('Mint.Quick-FilterByProperty')]
    # [OutputType( )]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position = 0 )]
        [Alias('Name')]
        [string] $PropertyName,

        [Parameter(Mandatory, ValueFromPipeline)]
        [object[]] $InputObject,

        [switch] $KeepEmptyValue,
        [switch] $KeepWhitespaceOnlyValue
    )
    begin {
        [Collections.Generic.List[Object]] $items = @()
    }
    process {
        foreach( $Obj in $InputOBject ) {
            $items.Add( $Obj )
        }
    }
    end {
        $lastUniquePropValues = @(
            $Items
            # $GetAlias
                | Mint.Get-UniquePropValue -Name $PropertyName -KeepEmptyValue:$( $KeepEmptyValue ) -KeepWhitespaceOnlyValue:$( $KeepWhitespaceOnlyValue )
        )

        # todo: clean: Should use Invoke-Fzf/Select instead of hard coded
        $lastFzfProps = $lastUniquePropValues
            | fzf -m <# --tac #> --cycle <# --footer foot #> --layout=reverse --header "Property '${PropertyName}' Values to keep: " --header-first --input-border rounded  --gap=1 --gap-line="$(New-Text '-' -fg gray30)"
            # extra params '--no-input' ; and no escap[e for exit]


        $found = $Items | ? $Propertyname -in @( $lastFzfProps )
        $found

        if( $true ) {
            $global:LastMintFzfProps = $LastFzfProps
            $global:LastMintFzf      = $found

            $lastFzfProps
                | Join-String -sep ', ' -op '$LastMintFzf = '
                | Write-Host -fg 'gray60' -bg 'gray30'

            $found.count
                | Join-String "`$Found = {0} items"
                | Write-Host -f 'goldenrod' -bg 'gray20'
        }
    }
}


function Require-MintilsAppExists {
    <#
    .SYNOPSIS
        Require [ApplicationInfo] exists. Returns one match. They can come from many extension types / *.exe, *.cmd, *.py, .sh, etc...
    .notes
        If you want an *.exe or *.cmd from Get-Command,
        [ApplicationInfo] works best, It's cross platform. And isn't hardcoded to a specific extension.
    .example
        > $binPy = Mint.Require-AppInfo py
        > & $binPy '--version'
        # 'If the command is missing, it quits before this line'
    .example
        # Silly, but it works
        > & ( Mint.Require-AppInfo py ) '--version'
        > & ( Mint.Require-AppInfo fd ) @( '-e', 'ps1', '--newer', '2days' )
    .link
        Mintils\Find-MintilsAppCommand
    .link
        Mintils\Require-MintilsFileExists
    .link
        Mintils\Require-MintilsAppExists
    #>
    [CmdletBinding()]
    [OutputType( [Management.Automation.ApplicationInfo] )]
    [Alias(
        'Mint.Require-App',
        'Mint.Require-AppInfo' )]
    param(
        [Parameter(Mandatory)]
        [object] $Name
    )
    [Management.Automation.ApplicationInfo] $App = Mint.ExecutionContext.Get-Commands -Name $Name | Select-Object -First 1
    if ( -not $App ) {
        $msg = "Application '$Name' not found in PATH."
        $err =
            [Management.Automation.ErrorRecord]::new(
                [System.Exception]::new( $msg ),
                'Mintils.Require-AppExists.AppNotFound',
                [Management.Automation.ErrorCategory]::ObjectNotFound,
                $Name
            )
        throw $err # $PSCmdlet.ThrowTerminatingError( $err )
    }
    $App
}


function Require-MintilsDirectoryExists {
    <#
    .SYNOPSIS
        Create a folder if not existing, and return (get-Item) of it. Throw on read/write errors
    .DESCRIPTION
        - If a folder exists, return it using (Get-Item)
        - If missing, attempt to create it.
    .example
        $AppConf = @{
            AppRoot = ( $AppRoot = Get-Item $PSScriptRoot )
            Export  = Mint.Require-Directory -Confirm -Path (Join-Path $AppRoot 'export')
        }
    #>
    [OutputType( [System.IO.DirectoryInfo] )]
    [Alias(
        'Mint.Require-Directory' )]
    param(
        [Alias('PSPath', 'Directory')]
        [Parameter(Mandatory)]
        [object] $Path,

        # prompt for creating new files/folders. calls New-Item with -Confirm
        [switch] $Confirm,

        # By default, create directory if missing
        [switch] $WithoutCreate,

        # By default, New-Item uses -Force
        [switch] $WithoutForce
    )
    $Resolved = Get-Item -ea 'ignore' $Path
    if( $Resolved -is [System.IO.DirectoryInfo] ) {
        return $Resolved
    }
    if( $Resolved.PSIsContainer ) {
        return $Resolved
    }

    if( $WithoutCreate -and -not ( Test-Path $Resolved ) ) {
        throw "Directory does not exist: '${Path}' ! WithoutCreate: ${WithoutCreate}, withoutForce ${WithoutForce}"
    }

    try {
        $newPath = mkdir -Path $Path -Confirm:$( $Confirm ) -ev 'evMkdir' -ea 'stop' -Force:$( -not $WithoutForce )
        if( Test-Path $newPath ) {
            return $newPath
        }
    } catch {
        if( $_.Exception.Message -match 'item with the.*name.*exists' ) {
            "Item already exists: '${Path}'" | Write-Verbose
        } else {
            throw
        }
    }
    throw "Failed resolving directory: '${Path}' !"
}


function Require-MintilsFileExists {
    <#
    .SYNOPSIS
        Create file if not existing, and return (get-Item) of it. Throw on read/write errors
    #>
    [OutputType( [System.IO.FileInfo] )]
    [Alias(
        'Mint.Require-File' )]
    param(
        [Parameter(Mandatory)]
        [object] $Path,

        # New-Item -Force is on by default
        # # By default, New-Item uses -Force
        [switch] $WithoutForce,

        # By default, create file if missing
        [switch] $WithoutCreate,

        # prompt when if creating new files/folders. calls New-Item with -Confirm
        [switch] $Confirm
    )
    $Resolved = Get-Item -ea 'ignore' $Path
    if( $Resolved -is [System.IO.FileInfo] ) {
        return $Resolved
    }
    if( $WithoutCreate -and -not ( Test-Path $Path ) ) {
        throw "Directory does not exist: '${Path}' ! WithoutCreate: ${WithoutCreate}, withoutForce ${WithoutForce}"
    }
    $newItem = New-Item -Path $Path -ItemType File -Confirm:$( $Confirm ) -ea 'stop' -Force:$( -not $WithoutForce ) -ev 'evNewItem'
    if( $newItem -and ( Test-Path $newItem ) ) {
        return $newItem
    }
    throw "File was not created! '${Path}' ! WithoutCreate: ${WithoutCreate}, withoutForce ${WithoutForce}"
}

function Select-MintilsObject {
    <#
    .synopsis
        Select first, last, some, etc...
    .EXAMPLE
        # when you want a few items
        > Get-Module | Mint.One            # first only
        > Get-Module | Mint.Select-Some    # up to 5
        > Get-Module | Mint.Select-Some 20 # up to 20
    .example
        > 'a'..'f' | Mint.Select-Random -Shuffle | Mint.One
    .example
        # optional: enable aggressive aliases
        > Mint.Enable-DefaultAlias

        # like
        > Get-Process | One
        > Get-Process | Some # returns 5

        > Get-Module | One
    .link
        Mintils\Select-MintilsRandomObject
    .link
        Mintils\Mint.Some
    .link
        Mintils\Mint.One
    .link
        Mintils\Mint.Select-Random
    #>
    [Alias('Mint.Select-Some', 'Mint.One', 'Mint.First' )]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline for speed
        [Alias('InObj', 'Obj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object[]] $InputObject,

        [Parameter( Position = 0)]
        [int] $MaxCount = 5
    )
    begin {
        $found_count = 0
        if( $PSCmdlet.MyInvocation.InvocationName -in ('One', 'First', 'Mint.One', 'Mint.First' ) ) {
            $MaxCount = 1
        }
    }
    process {
        foreach( $Item in $InputObject ) {
            if( $found_count -ge $MaxCount ) { continue }
            $found_count += 1
            $InputObject
        }
    }
}

function Select-MintilsRandomObject {
    <#
    .synopsis
        Select first, last, some, etc...
    .example
        > $ps ??= Get-Process
        > $ps | Mint.Select-Random # 5
        > $ps | Mint.Select-Random 2 # 2
        > $ps | Mint.Select-Random -SetSeed 3 # set seed for a fixed-random value

    .example
        > 'a'..'f' | Mint.Select-Random -Shuffle
        > 'a'..'f' | Mint.Select-Random -Shuffle -SetSeed 4
    .link
        Microsoft.PowerShell.Utility\Get-Random
    #>
    [Alias('Mint.Select-Random')]
    # [OutputType( [string], 'Mintils.RelativePath' )]
    [CmdletBinding()]
    param(
        # future: steppable pipeline
        [Alias('InObj', 'Obj')]
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ValueFromPipeline)]
        [object[]] $InputObject,

        [Parameter( Position = 0)]
        [int] $MaxCount = 5,

        # for: Get-Random -Shuffle
        [switch] $Shuffle,

        # for: Get-Random -SetSeed
        [int] $SetSeed
    )
    begin {
        [Collections.Generic.List[Object]] $items = @()
        # $found_count = 0
        # if( $PSCmdlet.MyInvocation.InvocationName -in ('Mint.RandomOne' ) ) {
        #     $MaxCount = 1
        # }
    }
    process {
        $items.AddRange( [object[]] $InputObject )
    }
    end {
        $splat = @{
            InputObject = $Items
            Count = $MaxCount
        }
        if( $Shuffle ) { # can't use -Shuffle and -Count at the same time
            $splat.Shuffle = $Shuffle
            $splat.Remove( 'Count' )
        }

        if( $setSeed ) { $splat.SetSeed = $setSeed }
        Get-Random @splat # -InputObject $items -Count $MaxCount # -SetSeed
    }
}

function Write-MintilsConsoleDict {
    <#
    .synopsis
        Write dictionaries to the console as key -> value pairs with color
    .EXAMPLE
        # The basic invoke works positionally
        > Mint.Write-Dict @{ id = 123; color = 'blue' ; }
        # output with colors:

            color: blue
            id: 123
    .link
        Mintils\Write-MintilsConsoleDict
    .link
        Mintils\Write-MintilsConsoleLabel
    #>
    [Alias('Mint.Write-ConsoleDict', 'Mint.Write-ConsoleHashtable', 'Mint.Write-Dict')]
    # OutputType: always [Void], except when using -PassThru: output is [PoshCode.Pansies.Text]
    [CmdletBinding()]
    param(
        # hashtable or idictionary or what is best to iterate ?
        [Alias('Dict', 'Hashtable')]
        [Collections.IDictionary]
        $InputObject,

        # for: "Mint.Write-Label -Delim"
        # string (or none) between: <key><delim><value>
        [Alias('TemplateDelim')]
        [string] $Delim, # was ':',

        # for: "Mint.Write-Label -ValuePrefix"
        # space/value (or none) between: <delim> and <value>
        [Alias('TemplateValuePrefix')]
        [string] $ValuePrefix, # was ' ',


        # for: "Mint.Write-Label -PassThru"
        # Returns the (New-Text) result instead of writing to the console/Host
        [Alias( 'WithoutWriteHost')]
        [switch] $PassThru
    )
    begin {}
    process {
        # foreach( $Key in $InputObject.Keys)
        [string[]] $AllKeys = $InputObject.Keys.Clone() | Sort-Object -Unique

        $out = foreach( $KeyName in $AllKeys ) {
            $label_splat = @{
                LabelName   = $KeyName
                InputObject = $InputObject[ $KeyName ] | Join-String -sep ', '
            }
            # Emit keys only when declared to preserve inner default fallback values
            if ( $PSBoundParameters.ContainsKey( 'Delim' ) ) { $label_splat.Delim = $Delim }
            if ( $PSBoundParameters.ContainsKey( 'ValuePrefix' ) ) { $label_splat.ValuePrefix = $ValuePrefix }
            if ( $PSBoundParameters.ContainsKey( 'PassThru' ) ) { $label_splat.PassThru = $PassThru }

            Mint.Write-Label @label_splat
        }

        if( $PassThru ) { return $out }
        $out | Pansies\Write-Host
    }
}

function Write-MintilsConsoleHeader {
    <#
    .synopsis
        Write a markdown header, or a <h1> with color
    .description
        Writes a console header like markdown. Or returns so that you can pipe it elsewhere.
    .EXAMPLE
        > 'hi world' | Mint.Write-H1 # Default writes to Host
        > 'hi world' | Mint.Write-H1 -fg 'gray40' -bg 'gray30'
    .example
        # Write Colors to another stream: Verbose/ Write-Information, etc.
        # without Write-Host
        > $msg = 'Log Start: {0}' -f (Get-Date) | Mint.Write-H1 -PassThru
        > $msg | Write-Verbose -Verbose
        > $msg | Write-Information -infa Continue
    #>
    [Alias('Mint.Write-ConsoleHeader', 'Mint.Write-H1')]
    # OutputType: always [Void], except when using -PassThru: output is [PoshCode.Pansies.Text]
    [CmdletBinding()]
    param(
        [Alias('Name', 'Label')]
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Text,

        # Text before your header text, or ' ## '
        [string] $PrefixText = ' ## ',

        # Text after your header text, or ' ## '
        [string] $SuffixText = ' ## ',

        # Returns the (New-Text) result instead of writing to the console/Host
        [switch] $PassThru,

        # accepts [RgbColor] or Null, otherwise the default color
        [Alias('Fg')]
        [RgbColor] $ForegroundColor = 'PaleVioletRed2',

        # accepts [RgbColor] or Null, otherwise the default color
        [Alias('Bg')]
        [RgbColor] $BackgroundColor = 'SlateBlue4',

        # number of newlines to prefix, and suffix the header with. otherwise none. ( when -not $PassThru ). Default is 0.
        [int] $PadBothLines = 0
    )
    process {

        $render = "${PrefixText}${Text}${SuffixText}"
        $obj = $render | Pansies\New-Text -fg $ForegroundColor -bg $BackgroundColor
        if( $PassThru ) { return $obj }

        if( -not $PadBothLines ) {
            $obj | Pansies\Write-Host
        } else {
            $Pad = "`n" * $PadBothLines -join ''
            $Obj| Join-String -f "${Pad}{0}${Pad}"
                | Pansies\Write-Host
        }
    }
}

function Write-MintilsConsoleLabel {
    <#
    .synopsis
        Write output with a label
    .description
        For collections the Key names are the same for each item.
        When key names should change, see:
            Mint.Write-ConsoleDict
    .EXAMPLE
        # The basic invoke works positionally
        > Mint.Write-Label 'user' 'bob'
        > Mint.Write-Label 'PSVersion' $PSVersionTable.PSVersion
        # out: PSVersion: 7.5.4

    .link
        Mintils\Write-MintilsConsoleDict
    .link
        Mintils\Write-MintilsConsoleLabel
    #>
    [Alias('Mint.Write-ConsoleLabel', 'Mint.Write-Label')]
    # OutputType: always [Void], except when using -PassThru: output is [PoshCode.Pansies.Text]
    [CmdletBinding()]
    param(
        # Key Name
        [Parameter( Mandatory, Position = 0 )]
        [Alias('Key', 'Name')]
        [string] $LabelName,

        # Values
        [Alias('Object', 'InObj', 'Value')]
        [AllowEmptyCollection()]
        [Parameter( Mandatory, ValueFromPipeline, Position = 1 )]
        [object[]] $InputObject,

        # string (or none) between: <key><delim><value>
        [Alias('TemplateDelim')]
        [string] $Delim = ':',

        # space/value (or none) between: <delim> and <value>
        [Alias('TemplateValuePrefix')]
        [string] $ValuePrefix = ' ',

        # Returns the (New-Text) result instead of writing to the console/Host
        [Alias( 'WithoutWriteHost')]
        [switch] $PassThru
    )
    begin {
        $KeyColor    = Mint.Get-TextStyle -Style Dict.Key -AsSplatableHash
        $ValueColor  = Mint.Get-TextStyle -Style Dict.Value -AsSplatableHash
        $ResetColor = $PSStyle.Reset
        $Prefix     = "${ResetColor}" # or '  ', "${ResetColor}  "
    }
    process {
        $out = foreach( $Obj in $InputObject ) {
            "${Prefix}{0}${Delim}${ResetColor}${ValuePrefix}{1}" -f @(
                New-Text @KeyColor -Obj $LabelName
                New-Text @valueColor -Obj $Obj
            )
        }
        if( $PassThru ) { return $out } # is the preferred default to return as an array, or enumerate it?
        $out | Pansies\Write-Host
    }
}

function Write-MintilsLineEnding {
    <#
    .SYNOPSIS
        emits n-number of newlines as one string. Sugar for scripts to write n-number of line endings. ( Without explicit write-host )
    .example
        > "foo"; Mint.Write-NL; "Foo";
        > Mint.Write-NL 2
        > Mint.Write-H1 'foo'; Mint.Write-NL 4; Mint.Write-H1 'bar';
    #>
    [Alias( 'Mint.Write-ConsoleLineEnding', 'Mint.Write-NL' )]
    [OutputType( [string] )]
    [CmdletBinding()]
    param(
        # Number of lines. Default: 1
        [Parameter(Position = 0)]
        [uint] $NumberOfLines = 1,

        # Override the default line endings: '\n'
        [Parameter(Position = 1)]
        [ArgumentCompletions( '"`n"', '"`r`n"', "'␊'" )]
        [string] $LineEndingString = "`n"
    )

    if( $NumberOfLines -eq 0 ) { return }
    $render = $LineEndingString * $NumberOfLines -join ''
    $render
}

