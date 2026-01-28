# Test vitamin endpoint enrichment
Write-Host "Testing vitamin endpoint..."
try {
    $response = Invoke-RestMethod -Uri "http://localhost:60491/vitamins/1" -Method Get -ErrorAction Stop
    
    Write-Host "`n=== Vitamin Data ===" -ForegroundColor Green
    $response | ConvertTo-Json -Depth 10 | Write-Host
    
    Write-Host "`n=== Enrichment Check ===" -ForegroundColor Cyan
    Write-Host "image_url: $(if ($response.image_url) { '✅ ' + $response.image_url } else { '❌ Missing' })"
    Write-Host "benefits: $(if ($response.benefits) { '✅ ' + $response.benefits } else { '❌ Missing' })"
    $contraCount = if ($response.contraindications) { $response.contraindications.Count } else { 0 }
    Write-Host "contraindications: $(if ($contraCount -gt 0) { "✅ $contraCount found" } else { '❌ None' })"
    
} catch {
    Write-Host "Error testing endpoint: $_" -ForegroundColor Red
    Exit 1
}
