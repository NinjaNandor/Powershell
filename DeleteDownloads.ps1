# Path to the Downloads folder
$downloadsFolder = "$env:USERPROFILE\Downloads"

# Check if the folder exists
if (Test-Path $downloadsFolder) {
    # Get all files in the Downloads folder
    $files = Get-ChildItem -Path $downloadsFolder

    # Delete each file
    foreach ($file in $files) {
        Remove-Item -Path $file.FullName -Force -ErrorAction SilentlyContinue
    }

    Write-Output "All files in the Downloads folder have been deleted."
} else {
    Write-Output "The Downloads folder does not exist."
}
