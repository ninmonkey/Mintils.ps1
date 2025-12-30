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

            if( -not $return.FileExists ) {
                $return.FileWithLineNumberString = '' # fix: convert to calculated property
            } else {
                $return.FileWithLineNumberString = '{0}:{1}:{2}' -f @(
                    $return.File.FullName,
                    $return.StartLineNumber
                    $return.StartColumnNumber
                )
            }
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
        $return.FileWithLineNumberString = Mint.Format-FullNameWithLineNumber -Path $return.File -StartLineNumber $return.StartLineNumber -StartColumnNumber $return.StartColumnNumber
    }

    [pscustomobject] $return
}
