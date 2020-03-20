#############################################
#                  HASHDUP                  #
#                                           #
# Recursively check for duplicate files and #
#        print colliding full paths.        #
#                                           #
#            /robex/ - (C) 2018             #
#############################################

# USAGE: hashdup [path] [-ri]
# optional arguments:
#   -r: recursive
#   -i: interactive mode: prompt for delete for each file

param (
	[Parameter(Mandatory=$true)][string]$path,
	# recursive
	[switch]$r = $false,
	# prompt delete
	[switch]$i = $false
)

# remove '-Recurse' if dont want deep searching
if ($r) {
	$files = Get-ChildItem -Path $path -Recurse -File
} else {
	$files = Get-ChildItem -Path $path -File
}

$fileHashes = @()
$toDelete = @()
$ndup = 0

foreach($file in $files) {
	$thisFileHash = Get-FileHash -Algorithm md5 -Path $file.FullName

	if ($fileHashes.Count -eq 0) {
		$fileHashes += @($thisFileHash)
	} else {
		$isDuplicate = $false
		foreach ($fileHash in $fileHashes) {
			if ($fileHash.Hash -eq $thisFileHash.Hash) {
				$ndup++
				$isDuplicate = $true
				$thisPath = $file.FullName
				$thisPathStr = $thisPath + " | created " + $file.CreationTime + " | size " + $file.Length + " bytes"
				echo "duplicate file: $thisPathStr"
				$collideFile = Get-Item $fileHash.Path
				$collidePath = $fileHash.Path
				$collidePathStr = $collideFile.FullName + " | created " + $collideFile.CreationTime + " | size " + $collideFile.Length + " bytes"
				echo "duplicate with: $collidePathStr"
				if ($i) {
					$confirmation = Read-Host "Delete file`r`n1: ${thisPathStr} `r`n2: ${collidePathStr}`r`n[1/2/n]"
					if ($confirmation -eq '1') {
						$toDelete += $thisPath
					} elseif ($confirmation -eq '2') {
						$toDelete += $collidePath
					}
				}
				echo ""
			}
		}

		# if not duplicate, add to the hash list
		if(!$isDuplicate) {
			$fileHashes += @($thisFileHash)
		}
	}
}

if ($i) {
	$toDelete = $toDelete | select -uniq
	$arrayLen = @($toDelete).Length

	foreach ($file in $toDelete) {
		Remove-Item -Path $file
	}
	echo "number of deleted files: $arrayLen"
}
echo "number of duplicate files: $ndup"
