# Proper Flutter warning fixer
Write-Host "Fixing Flutter warnings properly..." -ForegroundColor Cyan

$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $content = Get-Content -Path $file.FullName -Raw
    $original = $content
    
    # Fix 1: Replace .withOpacity(number) with .withValues(alpha: number)
    # Only replace when it's clearly a method call
    $content = $content -replace '\.withOpacity\((\d+(?:\.\d+)?)\)', '.withValues(alpha: $1)'
    
    # Fix 2: Replace print( with debugPrint( (not debugdebugPrint!)
    # But only if it's not already debugPrint
    $content = $content -replace '(?<!debug)print\(', 'debugPrint('
    
    # Fix 3: Fix the debugdebugPrint error from previous run
    $content = $content -replace 'debugdebugPrint\(', 'debugPrint('
    
    # Fix 4: Revert wrong color property replacements
    # Color.red/green/blue should not be replaced when used with Colors class
    $content = $content -replace '\(\(Colors\.r \* 255\.0\)\.round\(\) & 0xff\)', 'Colors.red'
    $content = $content -replace '\(\(Colors\.g \* 255\.0\)\.round\(\) & 0xff\)', 'Colors.green'  
    $content = $content -replace '\(\(Colors\.b \* 255\.0\)\.round\(\) & 0xff\)', 'Colors.blue'
    
    # For actual Color instances (not Colors class), the fix needs context
    # We'll skip automated fixes for those - they need manual review
    
    if ($content -ne $original) {
        Set-Content -Path $file.FullName -Value $content -NoNewline
        Write-Host "Fixed: $($file.Name)" -ForegroundColor Green
    }
}

Write-Host "`nRunning flutter analyze..." -ForegroundColor Cyan
flutter analyze
