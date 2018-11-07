<#
.Synopsis
   Fixes perfmon CSV file.
.DESCRIPTION
   Converts headers of CSV file (generated by *relog* from *perfmon* binary log) to original english names using list from Windows Registry. 
   Also fixes corrupted 1st column.
   NOTE: original file will be replaced after fixing.
.EXAMPLE
   ./perfconv.ps1 -Path app.csv
.EXAMPLE
   ./perfconv.ps1 -Path sql.csv
#>

param (
	[Parameter(Mandatory=$true)]
	[string]$Path
)

$scriptPath = split-path -parent $MyInvocation.MyCommand.Definition

$rus_counters = Join-Path -Path "$scriptPath" -ChildPath "rus_counters.txt"
$eng_counters = Join-Path -Path "$scriptPath" -ChildPath "eng_counters.txt"
$default_first = "(PDH-CSV 4.0) (E. Africa Standard Time)(-180)"

$rus_content = Get-content -Path "$rus_counters"
$eng_content = Get-content -Path "$eng_counters"

$rus = @{}
$eng = @{}

for ($i = 0; $i -lt $rus_content.Length-1; $i += 2) {
	Try { $rus.Add($rus_content[$i+1].Trim(), $rus_content[$i].Trim()) }
	Catch {}
}

for ($i = 0; $i -lt $eng_content.Length-1; $i += 2) {
	Try { $eng.Add($eng_content[$i].Trim(), $eng_content[$i+1].Trim()) }
	Catch {}
}

$file_content = Get-content -Path "$Path"
$header = $file_content[0]

Write-Host "Before: "
Write-Host "$header"


# "(PDH-CSV 4.0) (" and others corrupted first field processing
$firstField = Select-String '\"(.+\s\()\",.+' -input $header
if ($firstField.Matches.Length -gt 0) {
	$pat = [System.Text.RegularExpressions.Regex]::Escape($firstField.Matches[0].Groups[1].Value)
	$header = $header -replace $pat, $default_first
} else {
	$allclear = $true
	$header.ToCharArray() | % {
		if ([int][char]$_ -ge 128) { 
			$allclear = $false
			break
		}
	}
	if ($allclear) {
		Write-host "Here is nothing to change..."
		Exit
	}
}

$result = Select-String '\\\\[^\\]+\\([^\\\(]+)(\([^\\]+\))?\\([^\"]+)\"' -input $header -AllMatches
$result.Matches | % {
	$g0 = $_.Groups[1].Value
	$g2 = $_.Groups[3].Value
	
	if ($rus.ContainsKey($g2)) {
		$pat = '\\' + [System.Text.RegularExpressions.Regex]::Escape($g2) + '([\\\)\(\s\"])'
		$repl = '\\' + $eng[$rus[$g2]] + '$1'
		$header = $header -replace $pat, $repl
	} else {
		Write-Host "warning: '$g2' not found in dictionary!"
	}
	
	if ($rus.ContainsKey($g0)) {
		$pat = '\\' + [System.Text.RegularExpressions.Regex]::Escape($g0) + '([\\\)\(\s\"])'
		$repl = '\\' + $eng[$rus[$g0]] + '$1'
		$header = $header -replace $pat, $repl
	} else {
		Write-Host "warning: '$g0' not found in dictionary!"
	}
	
}

Write-Host "After: "
Write-Host "$header"

$file_content[0] = $header
$file_content | Out-File "$Path"
