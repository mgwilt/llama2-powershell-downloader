# LLaMA 2 Download Script

This PowerShell script is used to download the LLaMA 2 (Large Language Models Association) model files. The script will download the model files based on the model sizes provided.

The script uses PoshRSJob for running jobs in parallel to download files.

## Prerequisites

- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)
- PoshRSJob module installed.

  ```
  Install-Module PoshRSJob -Scope CurrentUser -Force
  ```

## How to use

1. **Clone the repository or download the script to your local system.**

2. **Run the script in PowerShell.**

   You can run the script with a DryRun flag which will simulate the process without actually downloading the files. The default value of this flag is `$true`.

   ```
   ./download.ps1 -DryRun $true
   ```

3. **Enter the Presigned URL.**

   The script will prompt you to enter the URL that you received in the email.

4. **Enter the list of models to download.**

   You will be prompted to enter the model sizes to download. You can enter `7B,13B,70B,7B-chat,13B-chat,70B-chat` separated by commas without spaces, or press Enter to download all models.

5. **Wait for the script to finish downloading.**

   The script will download the LICENSE, Acceptable Usage Policy, tokenizer, and the selected model files. The progress of each download will be displayed.

6. **Check the output.**

   If the DryRun flag is set to `$false`, then the output will be "All downloads complete." If it is set to `$true`, then the output will be "DryRun complete."

## Target Folder

By default, all files will be downloaded to the current directory. You can modify the `$TARGET_FOLDER` variable in the script to change the download location.

## Issues

If you face any issues while using this script, please create an issue in the GitHub repository.
