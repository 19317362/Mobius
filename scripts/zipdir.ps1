#
# This script takes in "dir" and "target" parameters, zips all files under dir to the target file
#
Param([string]$dir, [string]$target)

function Get-ScriptDirectory
{
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value;
    if($Invocation.PSScriptRoot)
    {
        $Invocation.PSScriptRoot;
    }
    Elseif($Invocation.MyCommand.Path)
    {
        Split-Path $Invocation.MyCommand.Path
    }
    else
    {
        $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
    }
}

function Zip-Directory($sourceDir, $targetFile)
{
    if (!(test-path $sourceDir))
    {
        Write-Output "[Zip-Directory] WARNING!!! $sourceDir does not exist. Please provide a valid directory name !"
        return
    }

    if ((test-path $targetFile))
    {
        Write-Output "[Zip-Directory] Delete existing $targetFile"
        Remove-Item $targetFile
    }

    $start_time = Get-Date
    Write-Output "[Zip-Directory] Zip $sourceDir to $targetFile ..."

    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    [System.IO.Compression.ZipFile]::CreateFromDirectory(
       $sourceDir, 
       $targetFile, 
       $compressionLevel, 
       $false # not include base directory name
    )
    
    $duration = $(Get-Date).Subtract($start_time)
    if ($duration.Seconds -lt 2)
    {
        $mills = $duration.MilliSeconds
        $howlong = "$mills milliseconds"
    }
    else
    {
        $seconds = $duration.Seconds
        $howlong = "$seconds seconds"
    }

    Write-Output "[Zip-Directory] $targetFile completed. Time taken: $howlong"
}

function Print-Usage
{
    Write-Output '====================================================================================================='
    Write-Output ''
    Write-Output '    This script takes in "dir" and "target" parameters, zips all files under dir to the target file'
    Write-Output ''
    Write-Output '====================================================================================================='
}

#
# main body of the script
#
if (!($PSBoundParameters.ContainsKey('dir')) -or !($PSBoundParameters.ContainsKey('target')))
{
    Print-Usage
    return
}

# Load IO.Compression.FileSystem for unzip capabilities
Add-Type -assembly "system.io.compression.filesystem"

Zip-Directory $dir $target

