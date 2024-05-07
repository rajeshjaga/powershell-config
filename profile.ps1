$githubup = Test-Connection -Count 1 github.com -Quiet -TimeoutSeconds 1 -ErrorAction SilentlyContinue 
if (($host.Name -eq 'ConsoleHost') -and ($PSVersionTable.PSVersion.Major -ge 7))
{
    if(!(Get-Module -Name PSReadLine))
    {
        Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck
    } else
    {
        Import-Module -Name PSReadLine
        Set-PSReadLineOption -HistoryNoDuplicates -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView
    }

    if(!(Get-Module -Name Terminal-Icons))
    {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
    } else
    {
        Import-Module -Name Terminal-Icons
    }
}

function sudo
{
    param (
        [Parameter(Mandatory)]
        $run
    )
    Start-Process  $run -Verb runas -WorkingDirectory $PWD
}

function Update-Profile
{
    if($githubup)
    {
        try
        {
            $newData= Invoke-RestMethod "https://raw.githubusercontent.com/rajeshjaga/powershell-config/master/Microsoft.PowerShell_profile.ps1"
        } catch
        { Write-Error $_
        } finally
        { Test-Config
        }
    } elseif ($githubup -eq $false)
    { Write-Host "Check your internet connection, this device might not have internet or github's down" -ForegroundColor Yellow
    } else
    { Write-Output 'Something went wrong while connecting to internet'
    }
}

# experimental function
function chcode
{ if((Test-CmdLets -cmd fd) -and (Test-CmdLets -cmd fzf))
    {
        Set-Location (  fd --path-separator \ --full-path Code -t d --exclude node_modules --exclude build --exclude pkg | fzf ); nvim
    } else
    {
        winget install --id sharkdp.fd --force --scope user --silent
    }
}

# reload the powershell profile
function Test-Config
{ & $PROFILE
}

# Test the passed commands
function Test-CmdLets
{
    param(
        [Parameter()]
        [String] $cmd
    )
    if( Get-Command $cmd -ErrorAction SilentlyContinue)
    { return $true
    } else
    { return $false
    }
}

# try open an text editor
function editor
{
    if (Test-CmdLets -cmd nvim)
    { nvim.exe 
    } elseif (Test-CmdLets -cmd vim)
    {vim.exe
    } elseif (Test-CmdLets -cmd code)
    {code.exe
    } elseif (Test-CmdLets -cmd notepad)
    {notepad.exe
    } else
    {Write-Output 'Could not find a text editor'
    }
}

# poweroff system immediately
function reboot
{
    shutdown -r -t 0
}

# Reboot system immediately
function poweroff
{
    shutdown -s -t 0
}

function ll
{
    Get-ChildItem -Path $PWD -Directory -Force -Hidden
}
Set-Alias -Name vim -Value editor
Set-Alias -Name g -Value "git"
Set-Alias -Name touch -Value "New-Item"
Set-Alias -Name obsi -Value "C:\Program Files\Obsidian\Obsidian.exe"
Set-Alias -Name code -Value chcode
Set-Alias -Name l -Value Get-ChildItem
Set-Alias -Name rc -Value Test-Config

#endregion


# nvim (  fd --path-separator \ --full-path Code  -t f  --exclude node_modules --exclude build --exclude pkg | fzf )
