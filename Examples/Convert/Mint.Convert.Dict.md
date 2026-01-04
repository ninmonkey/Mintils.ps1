# About 

Converting to Hashtable or Dictionary

# Examples

## `Mint.Convert.Dict.FromKeyValues`

`Gci Env:\` returns an array of `Collections.DictionaryEntry[]` as `object[]`

```ps1
# getting hash
> Get-ChildItem Env:\ |  Mint.Convert.Dict.FromKeyValues

# it works with Write-Dict
> Mint.Write-Dict ( Get-ChildItem Env:\ | ? Key -Match 'User|Program' |  Mint.Convert.Dict.FromKeyValues )
```


## `Mint.Convert.Dict.FromObject`

**Ex: 1**

```ps1
> Get-Item '.' | Select Last*time, PSPath | Mint.Convert.Dict.FromObject | Ft -AutoSize
```
```ps1
Name           Value
----           -----
PSPath         Microsoft.PowerShell.Core\FileSystem::H:\data\2025\pwsh
LastWriteTime  2025-12-16 5:51:27 PM
LastAccessTime 2026-01-04 4:08:47 PM
```

**Ex: 2**
```ps1
> Mint.Write-Dict ( $Profile | Select All*, Current* | Mint.Convert.Dict.FromObject )
```