param($DryRun = $true)

# Ensure PoshRSJob module is installed
if (-not(Get-Module PoshRSJob)) {
    Install-Module PoshRSJob -Scope CurrentUser -Force
}

$PRESIGNED_URL = Read-Host -Prompt 'Enter the URL from email'
Write-Host ""
$MODEL_SIZE = Read-Host -Prompt 'Enter the list of models to download without spaces (7B,13B,70B,7B-chat,13B-chat,70B-chat), or press Enter for all'
$TARGET_FOLDER="."             # where all files should end up
New-Item -ItemType Directory -Force -Path $TARGET_FOLDER

if($MODEL_SIZE -eq "") {
    $MODEL_SIZE="7B,13B,70B,7B-chat,13B-chat,70B-chat"
}

Write-Host "Downloading LICENSE and Acceptable Usage Policy"

$jobs = @()

foreach($file in "LICENSE", "USE_POLICY.md", "tokenizer.model", "tokenizer_checklist.chk"){
    $url = $PRESIGNED_URL.Replace("*",$file)
    $filePath = "$TARGET_FOLDER/$file"
    
    $jobs += Start-RSJob -Name "Downloading $file" -ScriptBlock {
        param($url, $filePath, $dryRun)
        if($dryRun) {
            Start-Sleep -Seconds 2
        } else {
            Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing -UserAgent "wget"
        }
    } -ArgumentList $url, $filePath, $DryRun
}

$MODEL_SIZE = $MODEL_SIZE.Split(",")
foreach ($m in $MODEL_SIZE) {
    switch($m) {
        "7B" {
            $SHARD=0
            $MODEL_PATH="llama-2-7b"
        }
        "7B-chat" {
            $SHARD=0
            $MODEL_PATH="llama-2-7b-chat"
        }
        "13B" {
            $SHARD=1
            $MODEL_PATH="llama-2-13b"
        }
        "13B-chat" {
            $SHARD=1
            $MODEL_PATH="llama-2-13b-chat"
        }
        "70B" {
            $SHARD=7
            $MODEL_PATH="llama-2-70b"
        }
        "70B-chat" {
            $SHARD=7
            $MODEL_PATH="llama-2-70b-chat"
        }
    }

    Write-Host "Downloading $MODEL_PATH"
    New-Item -ItemType Directory -Force -Path "$TARGET_FOLDER/$MODEL_PATH"

    for($s = 0; $s -le $SHARD; $s++) {
        $fileName = "{0:D2}" -f $s
        $url = $PRESIGNED_URL.Replace("*","$MODEL_PATH/consolidated.$fileName.pth")
        $filePath = "$TARGET_FOLDER/$MODEL_PATH/consolidated.$fileName.pth"
        $jobs += Start-RSJob -Name "Downloading $MODEL_PATH consolidated.$fileName.pth" -ScriptBlock {
            param($url, $filePath, $dryRun)
            if($dryRun) {
                Start-Sleep -Seconds 2
            } else {
                Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing -UserAgent "wget"
            }
        } -ArgumentList $url, $filePath, $DryRun
    }

    foreach($file in "params.json", "checklist.chk") {
        $url = $PRESIGNED_URL.Replace("*","$MODEL_PATH/$file")
        $filePath = "$TARGET_FOLDER/$MODEL_PATH/$file"
        $jobs += Start-RSJob -Name "Downloading $MODEL_PATH $file" -ScriptBlock {
            param($url, $filePath, $dryRun)
            if($dryRun) {
                Start-Sleep -Seconds 2
            } else {
                Invoke-WebRequest -Uri $url -OutFile $filePath -UseBasicParsing -UserAgent "wget"
            }
        } -ArgumentList $url, $filePath, $DryRun
    }
}

# Wait for all jobs to finish and display a progress bar
Get-RSJob | Wait-RSJob -ShowProgress

# Print the output of each job
Get-RSJob | Receive-RSJob

# Remove completed jobs
Get-RSJob | Remove-RSJob

if(!$DryRun) {
    Write-Host "All downloads complete."
} else {
    Write-Host "Dry run complete."
}
