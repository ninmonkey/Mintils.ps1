@{
    # Use custom rules path if needed
    # CustomRulePath = @()

    # Specify which rules to include
    IncludeRules = @(
        'PSAvoidAlias',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidGlobalAliases',
        'PSAvoidGlobalVars',
        'PSAvoidInvokeForPowerShellExe',
        'PSAvoidLongLines',
        'PSAvoidNullReferenceException',
        'PSAvoidPositionalParameters',
        'PSAvoidSemicolonsAsLineTerminators',
        'PSAvoidTrailingWhitespace',
        'PSAvoidUsingBrokenHashProperties',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSAvoidUsingDoubleQuotedStrings',
        'PSAvoidUsingEmptyCatchBlock',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingPositionalParameters',
        'PSAvoidUsingWildcardCharactersInFunctionName',
        'PSAvoidUsingWriteHost',
        'PSMissingModuleManifestField',
        'PSPlaceCloseBrace',
        'PSPlaceOpenBrace',
        'PSPossibleIncorrectComparisonWithNull',
        'PSProvideCommentHelp',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSUseApprovedVerbs',
        'PSUseBOMForUnicodeEncodedFile',
        'PSUseCmdletCorrectly',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseCorrectCasing',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseLiteralInitializerForHashtable',
        'PSUsePSCredentialType',
        'PSUseSingularNouns',
        'PSUseToExportFieldsInManifest',
        'PSUseUTF8EncodingForHelpFile'
    )

    # Rule configuration
    Rules = @{
        PSAvoidAlias = @{
            Whitelist = @()
        }
        PSAvoidLongLines = @{
            MaximumLineLength = 160
        }
        PSUseConsistentIndentation = @{
            IndentationSize = 4
            PipelineIndentation = 'IncreaseIndentationForFirstPipeline'
            Kind = 'space'
        }
    }
}
