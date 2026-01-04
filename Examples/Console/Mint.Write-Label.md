

# `Mint.Write-Label`

Example: Using RelativePath, Predent, and Labels to show folder contents

```ps1
$root = Get-Item 'c:\2025\pwsh'
$BaseFolders = gci $Root -Directory  | Sort-object FullName

foreach( $Fold in $BaseFolders ) { 
   $Fold | Mint.Write-Label 'Base Dir' -Delim ''

   $Dirs = gci -path $fold -Directory
   $Dirs | Mint.Format-RelativePath -RelativeTo ( $fold )
       | Mint.Write-Label -Key '📁' -Delim '' -PassThru
       | Mint.Text-Predent -Depth 1 -TabSize 2

   $Files = gci -path $fold -File
   $Files | Mint.Format-RelativePath -RelativeTo ( $fold )
       | Mint.Write-Label -Key 'File' -Delim '' -PassThru
       | Mint.Text-Predent -Depth 1 -TabSize 2
}
```
```ps1
Base Dir H:\data\2025\pwsh\fork.🍴
  📁 Indented.Automation👨
  📁 vscode-adapter

Base Dir H:\data\2025\pwsh\Gists.Others📁
  📁 Jaykul👨
  📁 Jborean93👨
  📁 MattCargile👨
  📁 Santi👨
  📁 StartAutomating👨
  📁 Trackd👨

Base Dir H:\data\2025\pwsh\MicrotopiaData
  📁 export
  📁 src
  File .gitignore
  File log.log
  File MicrotopiaData.code-workspace
  File readme.md
```