﻿<#
.SYNOPSIS
	Remembers a text 
.DESCRIPTION
	This PowerShell script saves the given text to 'Remember.csv' in your home folder.
.PARAMETER text1
	Specifies the text to memorize
.EXAMPLE
	PS> ./remember.ps1 "Buy apples"
	✔️ Saved to /home/Markus/Remember.csv in 0s.
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

param([string]$text1 = "", [string]$text2 = "", [string]$text3 = "")

try {
	if ($text1 -eq "") { $text1 = Read-Host "Enter what needs to be remembered" }

	$stopWatch = [system.diagnostics.stopwatch]::startNew()

	[string]$timestampString = Get-Date -UFormat %s
	$timestampString = $timestampString -replace ',','.'
	[int64]$unixTimestamp = $timestampString

	$path = "~/Remember.csv"

	if (-not(Test-Path "$path" -pathType leaf)) {
		Write-Output "TIMESTAMP,TEXT" > $path
	}
	Write-Output "$($unixTimestamp),$text1 $text2 $text3" >> $path
	$path = Resolve-Path $path

	[int]$elapsed = $stopWatch.Elapsed.TotalSeconds
	"✔️ Saved to $path in $($elapsed)s."
	exit 0 # success
} catch {
	"⚠️ Error in line $($_.InvocationInfo.ScriptLineNumber): $($Error[0])"
	exit 1
}
