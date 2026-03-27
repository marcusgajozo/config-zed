$folder = "$env:LOCALAPPDATA\Zed"
Set-Location $folder

# Puxa as atualizações ao iniciar o script no Windows
git pull origin main --rebase

# Configura o observador de arquivos do Windows
$watcher = New-Object IO.FileSystemWatcher $folder, "*.*" -Property @{
    IncludeSubdirectories = $true
    NotifyFilter = [IO.NotifyFilters]::LastWrite
}

# Ação que acontece quando você salva algo no Zed
Register-ObjectEvent $watcher Changed -SourceIdentifier ZedSync -Action {
    Set-Location $folder

    $status = git status --porcelain
    if ($status) {
        git add .
        $date = Get-Date -Format "yyyy-MM-dd HH:mm:sc"
        git commit -m "Auto-sync Windows: $date"

        # Previne conflitos antes de subir
        git pull origin main --rebase
        git push origin main
    }
}
