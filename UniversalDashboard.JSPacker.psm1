function Export-UDFramework {
    param(
        [Parameter(Mandatory)]
        [string[]]$NpmPackage,
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter()]
        [string[]]$AdditionalImports
    )

    $StagingPath = Join-Path ([IO.Path]::GetTempPath()) $Name
    if (Test-Path $StagingPath)
    {
        Remove-Item $StagingPath -Force -Recurse
    }

    New-Item $StagingPath -ItemType 'Directory' | Out-Null

    Copy-Item (Join-Path $PSScriptRoot 'template\*') -Destination $StagingPath

    Push-Location $StagingPath

    npm install

    $Imports = ''
    foreach($package in $NpmPackage)
    {
        $Imports += "import * as componentList from '$package';`r`n"
        npm install $package --save
    }

    foreach($import in $AdditionalImports)
    {
        $Imports += "import '$import';`r`n"
    }

    $Content = Get-Content (Join-Path $StagingPath 'universal-dashboard-service.jsx')
    $Content = $Content.Replace("// Imports", $Imports)

    $Content | Out-File -Force -FilePath (Join-Path $StagingPath 'universal-dashboard-service.jsx')

    npm run build
}