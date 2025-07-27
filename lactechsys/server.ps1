# Simple HTTP Server in PowerShell
$port = 8000
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
$listener.Start()

Write-Host "Server running at http://localhost:$port/" -ForegroundColor Green
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow

try {
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        $url = $request.Url.LocalPath
        if ($url -eq "/") { $url = "/gerente.html" }
        
        $filePath = Join-Path $PSScriptRoot $url.TrimStart('/')
        
        if (Test-Path $filePath) {
            $content = Get-Content $filePath -Raw -Encoding UTF8
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            
            $extension = [System.IO.Path]::GetExtension($filePath)
            switch ($extension) {
                ".html" { $response.ContentType = "text/html; charset=utf-8" }
                ".js" { $response.ContentType = "text/javascript; charset=utf-8" }
                ".css" { $response.ContentType = "text/css; charset=utf-8" }
                default { $response.ContentType = "text/plain; charset=utf-8" }
            }
            
            $response.ContentLength64 = $bytes.Length
            $response.OutputStream.Write($bytes, 0, $bytes.Length)
        } else {
            $response.StatusCode = 404
            $errorBytes = [System.Text.Encoding]::UTF8.GetBytes("File not found")
            $response.ContentLength64 = $errorBytes.Length
            $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
        }
        
        $response.Close()
    }
} finally {
    $listener.Stop()
}