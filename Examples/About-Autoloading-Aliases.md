When will commands and aliases auto import the module?

### [0] Using `Mint.Enable-DefaultAlias` 

You can **opt-in** to having aggressive aliases. 

See [Enable-DefaultAlias](../Tests/Public/Enable-DefaultAlias.tests.ps1)


### [1] Full command Names will auto-import the module

```ps1
Remove-Module mintils -ea ignore
Get-Item . | Format-MintilsRelativePath -RelativeTo (Get-Item .)
    # ... paths
```
### [2] Mint.* prefixes do not

```ps1
Remove-Module mintils -ea ignore
Get-Item . | Mint.Format-RelativePath (Get-Item '.')

     Error: The term 'Mint.Format-RelativePath' is not recognized as a name of ...
```

### [3] auto load **if** 'RelPath' is defined as an attribute

This happens when:

- `AliasesToExport` is set to `@( '*' )`
- And the Cmdlet has an Alias attribute defined like `RelPath`

```ps1
function Format-MintilsRelativePath { 
    [Alias('Mint.Format-RelativePath', 'RelPath')]
    [CmdletBinding()]
    param()
}
```

<!--
### [4] aliases not defined as an attribute or exported

To prevent this, you could

- `AliasesToExport` is set to `@( 'Mint.*' )`
- Or OptIn to extra aliases


```ps1
Remove-Module mintils -ea ignore
Import-Module mintils -Force
Get-Item .    | RelPath (Get-Item '.')

    # Error:  The term 'RelPath' is not recognized as a name of a ...
```

```ps1
Remove-Module mintils -ea ignore
Import-Module mintils -Force
Get-Item .    | RelPath (Get-Item '.')
```

```ps1
Remove-Module mintils -Verbose -ea ignore
Import-Module mintils
Get-Item .    | RelPath  -RelativeTo (Get-Item .)
```
-->