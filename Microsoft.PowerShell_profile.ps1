# Checking if the powershell version is greater than or equal to 7
if (($host.Name -eq 'ConsoleHost') -and ($PSVersionTable.PSVersion.Major -ge 7))
{
    if(-not(Get-Module -ListAvailable -Name PSReadLine))
    {
        Install-Module -Name PSReadLine -Scope CurrentUser -Force -SkipPublisherCheck -Verbose
    }
    Import-Module -Name PSReadLine
    Set-PSReadLineOption -HistoryNoDuplicates -PredictionSource HistoryAndPlugin -PredictionViewStyle ListView

    if(-not(Get-Module -ListAvailable -Name Terminal-Icons))
    {
        Install-Module -Name Terminal-Icons -Scope CurrentUser -Force -SkipPublisherCheck
    }
    Import-Module -Name Terminal-Icons
}

function Test-CmdLets
{
    param( $cmd )
    $cmdStat=$null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
    return $cmdStat
}

# try open an text editor
$editor=if (Test-CmdLets nvim)
{ 'nvim'
} elseif (Test-CmdLets vim)
{'vim'
} elseif (Test-CmdLets code)
{'code'
} elseif (Test-CmdLets notepad)
{'notepad'
} elseif (Test-CmdLets notepad++)
{'notepad++'
} 
Set-Alias -Name vim -Value $editor


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

# implementation of sudo in windows
function sudo
{
    param (
        [Parameter(Mandatory)]
        $run
    )
    Start-Process  $run -Verb runas -WorkingDirectory $PWD
}


# experimental function
function code
{param(
        [Parameter()]
        [switch] $chloc
    )
    try
    {if(!(Test-CmdLets -cmd fd) )
        {
            write-output "fd...."
            try
            {winget install --id sharkdp.fd --force --scope user --silent
                write-output "fd installed"
            } catch
            {
                Write-Error $_
            }
        }
        if(!(Test-CmdLets -cmd fzf))
        {
            write-output "fzf"
            try
            {  winget install --id junegunn.fzf --force --scope user --silent
                write-output "installed fzf"
            } catch
            { Write-Error $_
            }
        }
        $location=(  fd --path-separator \ --full-path Code -t d --exclude node_modules --exclude build --exclude pkg --max-depth 5| fzf )
        if(($null -ne $location) -and (!$chloc))
        {
            nvim.exe $location
        } elseif($location -and $chloc)
        {
            Set-Location $location
        }
        Write-Output "Do Something productive"

        # Start-Process $editor -WorkingDirectory "~\$location"
    } catch
    {
        Write-Error $_
    }
}

# reload the powershell profile
function Test-Config
{ . $PROFILE
}
Set-Alias -Name rc -Value Test-Config

Set-Alias -Name g -Value "git"
Set-Alias -Name touch -Value "New-Item"
Set-Alias -Name obsi -Value "C:\Program Files\Obsidian\Obsidian.exe"
Set-Alias -Name l -Value Get-ChildItem

Clear-Host

write-output 'Done importing profile.....'
