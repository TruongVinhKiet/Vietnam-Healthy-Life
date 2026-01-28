# Fix Flutter analyzer warnings
# Run this from Project directory

Write-Host "Fixing Flutter warnings..." -ForegroundColor Cyan

# Get all Dart files
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    Write-Host "Processing: $($file.FullName)" -ForegroundColor Yellow
    
    $content = Get-Content -Path $file.FullName -Raw
    $originalContent = $content
    
    # Fix 1: Replace .withOpacity() with .withValues()
    # Pattern: .withOpacity(0.3) -> .withValues(alpha: 0.3)
    $content = $content -replace '\.withOpacity\(([0-9.]+)\)', '.withValues(alpha: $1)'
    
    # Fix 2: Replace Color.red, Color.green, Color.blue with (color.r * 255.0).round() & 0xff
    # This is more complex and needs careful handling
    $content = $content -replace '(\w+)\.red([,\s\)])', '(($1.r * 255.0).round() & 0xff)$2'
    $content = $content -replace '(\w+)\.green([,\s\)])', '(($1.g * 255.0).round() & 0xff)$2'
    $content = $content -replace '(\w+)\.blue([,\s\)])', '(($1.b * 255.0).round() & 0xff)$2'
    
    # Fix 3: Remove print statements (replace with debugPrint or comment out)
    $content = $content -replace "print\(", "debugPrint("
    
    # Fix 4: Add mounted check for BuildContext async warnings
    # This is complex and needs manual review, so we'll skip automated fixes
    
    # Only write if content changed
    if ($content -ne $originalContent) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "  Fixed: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`nRunning flutter analyze..." -ForegroundColor Cyan
flutter analyze

Write-Host "`nDone!" -ForegroundColor Green
