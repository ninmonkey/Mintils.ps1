function New-MintilsHashSetFileSystemInfo {
    <#
    .SYNOPSIS
        return a New hashset for type: [FileSystemInfo] with Case-Insensitive comparisons
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
