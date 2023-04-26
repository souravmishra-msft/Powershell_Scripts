# Set up authentication for the GitHub API using a personal access token
$accessToken = "<git_personal_access_token>"
$headers = @{ Authorization = "Bearer $accessToken" }
$baseUrl = "https://api.github.com"

# Set the owner and name of the repository you want to scan
$repoOwner = "<repo-owner>"
$repoName = "<repo-name>"

# Set the path to the directory within the repository you want to scan
$repoPath = "<repo-directory>"

# Set the regular expression patterns to match the ADAL namespace and class names, and ADAL method calls and class instantiations
$adalNamespaceRegex = "(Microsoft\.Identity\.Model\.Clients\.ActiveDirectory|Microsoft\.IdentityModel\.Clients\.ActiveDirectory|adal|adal-angular|@azure\/adal-angular|@azure\/adal-node)"
$adalMethodRegex = "(\bnew\s+AuthenticationContext\b|\bAcquireTokenAsync\b|\bAcquireTokenSilentAsync\b)"

function Scan-Directory {
    param (
        [string]$path
    )

    # Get the contents of the directory from GitHub
    $url = "$baseUrl/repos/$repoOwner/$repoName/contents/$path"
    $contents = Invoke-RestMethod -Uri $url -Headers $headers

    # Create an empty list to store the names of files that use ADAL
    $adalFiles = @()

    # Loop through each file and folder in the directory and all subdirectories and check if it uses the ADAL library
    foreach ($content in $contents) {
        if ($content.type -eq "dir") {
            # Recursively call this function for each subdirectory
            $subPath = $path + "/" + $content.name
            Scan-Directory $subPath
        }
        elseif ($content.type -eq "file") {
            # Get the contents of the file from GitHub
            $url = $content.download_url
            $fileContents = Invoke-RestMethod -Uri $url -Headers $headers

            # Check if the file uses the ADAL library
            if ($fileContents -match $adalNamespaceRegex -or $fileContents -match $adalMethodRegex) {
                # Check if the ADAL code is commented out
                $commentsRegex = "(\/\/.*)|(\#.*$)"
                $commentsMatch = $fileContents | Select-String -Pattern $commentsRegex -AllMatches | ForEach-Object { $_.Matches } | ForEach-Object { $_.Value }

                $uncommentedFileContents = $fileContents -replace $commentsRegex

                if ($uncommentedFileContents -match $adalNamespaceRegex -or $uncommentedFileContents -match $adalMethodRegex) {
                    Write-Host "Scanning file $($content.name)..." -ForegroundColor Cyan
                    $adalFiles += $content.name
                }
                else {
                    Write-Host "The file $($content.name) in $path contains ADAL code that is commented out." -ForegroundColor Yellow
                }
            }
            else {
                Write-Host "The file $($content.name) in $path does not use the ADAL library." -ForegroundColor Green
            }
        }
    }

    # Display a list of all the files that use ADAL
    if ($adalFiles.Count -gt 0) {
        Write-Host "`nThe following files in $path use the ADAL library:" -ForegroundColor Red
        foreach ($file in $adalFiles) {
            Write-Host $file -ForegroundColor Red
        }
    }
}

# Call the function with the repository path
Write-Host "`nScanning files in $repoPath..." -ForegroundColor Cyan
Scan-Directory $repoPath
