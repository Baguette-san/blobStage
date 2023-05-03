$csvFile = Import-Csv -Delimiter ';' -Path "D:\Stage_Hermes\Analyse\DATA\1_base\fichiers.csv"
foreach ($row in $csvFile) {
	$oldName = "D:\Stage_Hermes\Analyse\DATA\1_base\group\$($row.Old)"
	$newName = "D:\Stage_Hermes\Analyse\DATA\1_base\group\$($row.New)"
	Rename-Item -Path $oldName -NewName $newName -ErrorAction SilentlyContinue
}