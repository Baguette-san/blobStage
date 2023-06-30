$csvFile = Import-Csv -Delimiter ';' -Path "D:\Stage_Hermes\Analyse\DATA\1_base\fichiers2.csv"
foreach ($row in $csvFile) {
	$oldName = "D:\Stage_Hermes\Analyse\DATA\4_3_cropFullby10\$($row.New3)"
	$newName = "D:\Stage_Hermes\Analyse\DATA\4_3_cropFullby10\$($row.New4)"
	Rename-Item -Path $oldName -NewName $newName -ErrorAction SilentlyContinue
}