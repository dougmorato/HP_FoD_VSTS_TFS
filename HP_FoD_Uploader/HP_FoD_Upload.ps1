# parameters passed from task.json
param (
    [string]$hp_fod_url,
    [string]$hp_fod_uploader_cli_path,
    [string]$codebase,
    [string]$hp_fod_api_token,
    [string]$hp_fod_api_secret
)

# write some output to logs to indicate we are starting the HP FoD uploader task
Write-Host "Starting the HP FoD uploader task"

# Code below is only used for debug
# TODO: Write a debug flag condition
#Write-Host "HP FoD URL Upload URL = $hp_fod_url"
#Write-Host "HP FoD CLI Path = $hp_fod_uploader_cli_path"
#Write-Host "Codebase = $codebase"

# Import the Task.Common dll that has all the cmdlets we need for Build
Write-Host "Importing Task modules and cmdlets for build"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Internal"
import-module "Microsoft.TeamFoundation.DistributedTask.Task.Common"

# get hp fod uploader tool cli path and configure it. If it doesn't exist, download from the internet
if((!$hp_fod_uploader_cli_path) -or ((Get-Item $hp_fod_uploader_cli_path) -is [System.IO.DirectoryInfo]))
{
    #Write-Host "Inside IF condition to download the HP FoD .NET Uploader from HP FoD"
	$source = "https://www.hpfod.com/Tools/FoDUploader.exe"
    #Write-Host "Source URL = $source"
    #Write-Host "Before = hp_fod_uploader_cli_path = $hp_fod_uploader_cli_path"
	$hp_fod_uploader_cli_path = $hp_fod_uploader_cli_path + "\FoDUploader.exe"
    #Write-Host "After = hp_fod_uploader_cli_path = $hp_fod_uploader_cli_path"

    Write-Host "Downloading the HP FoD .NET Uploader from HP FoD"
	Invoke-WebRequest $source -OutFile $hp_fod_uploader_cli_path -Verbose
}

# transform contents as running on windows machine to respect appended format
$codebase = $codebase -replace "\\+", "\" -replace "\\", "\\"
#Write-Host "New codebase after transformation = $codebase"

$argumentList = @()
$argumentList += ("--uploadURL", "`"$hp_fod_url`"")
$argumentList += ("--apiToken", "`"$hp_fod_api_token`"")
$argumentList += ("--apiTokenSecret", "`"$hp_fod_api_secret`"")
$argumentList += ("--opensourceReport")
$argumentList += ("--debug")
$argumentList += ("--source", "`"$codebase`"")

#Write-Host "CLI Arguments = $argumentList"

# Call the HP FOD Uploader
Write-Host "Starting the upload to HP FoD"
#`"$hp_fod_uploader_cli_path`" $argumentList
Invoke-Expression "& '$hp_fod_uploader_cli_path' $argumentList" 

# Write message if Failed
if($LASTEXITCODE -ne 0)
{
	Write-Error "HP FoD Upload Failed"
	Exit 1
}