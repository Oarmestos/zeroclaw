# dev-backend.ps1
# Script de servidor de desarrollo del backend ZeroClaw con auto-recarga.
# Usa cargo-watch para recompilar y reiniciar automáticamente al guardar archivos.
#
# Uso:
#   .\dev\dev-backend.ps1           # Modo normal (gateway server)
#   .\dev\dev-backend.ps1 -Check   # Solo compila, no ejecuta (para verificar errores)
#   .\dev\dev-backend.ps1 -Command "agent run" # Comando personalizado

param(
    [switch]$Check,
    [string]$Command = "gateway"
)

$ErrorActionPreference = "Stop"

# Colores
function Write-Color($Text, $Color = "Cyan") {
    Write-Host $Text -ForegroundColor $Color
}

Write-Color "🦀 ZeroClaw — Servidor de Desarrollo Backend" "Cyan"
Write-Color "=============================================" "DarkCyan"

# Verificar que cargo-watch este instalado
if (-not (Get-Command "cargo-watch" -ErrorAction SilentlyContinue)) {
    Write-Color "⚠️  cargo-watch no encontrado. Instalando..." "Yellow"
    cargo install cargo-watch
}

# Cargar .env si existe
if (Test-Path ".env") {
    Write-Color "📋 Cargando variables de entorno desde .env..." "DarkGray"
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]+)=(.*)$") {
            $key = $matches[1].Trim()
            $val = $matches[2].Trim()
            [System.Environment]::SetEnvironmentVariable($key, $val, "Process")
        }
    }
}

if ($Check) {
    Write-Color "🔍 Modo CHECK: Recompila al guardar sin ejecutar..." "Yellow"
    Write-Color "   Observando cambios en src/ — Ctrl+C para detener`n" "DarkGray"
    cargo watch --why --clear -x "check"
} else {
    Write-Color "🚀 Iniciando servidor '$Command' con auto-recarga..." "Green"
    Write-Color "   Observando cambios en src/ — Ctrl+C para detener" "DarkGray"
    Write-Color "   Gateway estará disponible en: http://127.0.0.1:42617`n" "DarkGray"

    # cargo watch:
    #   --why       → muestra qué archivo cambió
    #   --clear     → limpia consola antes de cada recompilación
    #   -x          → comando a ejecutar
    #   -w src      → solo observa src/ (ignora docs/, web/, etc.)
    cargo watch --why --clear -w src -x "run -- $Command"
}
