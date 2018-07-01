#############################################
#                  HASHDUP                  #
#                                           #
# Recursively check for duplicate files and #
#        print colliding full paths.        #
#                                           #
#            /robex/ - (C) 2018             #
#############################################

# USAGE: hashdup [path]

$path = $args[0]

# remove '-Recurse' if dont want deep searching
$files = Get-ChildItem -Path $path -Recurse -File

$fileHashes = @()
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
				echo "duplicate file: $thisPath"
				$collidePath = $fileHash.Path
				echo "duplicate with: $collidePath"
				echo ""
			}
		}

		# if not duplicate, add to the hash list
		if(!$isDuplicate) {
			$fileHashes += @($thisFileHash)
		}
	}
}

echo "number of duplicate files: $ndup"
