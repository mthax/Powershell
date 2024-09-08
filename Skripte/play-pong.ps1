﻿<#
.SYNOPSIS
	Play the Pong game
.DESCRIPTION
	This PowerShell script lets 2 players play the famous Pong game.
	NOTE: Player 1: <W> moves up, <S> moves down | Player 2: <UP> or <DOWN> | <ESC> to quit
.EXAMPLE
	PS> ./play-pong.ps1
.LINK
	https://github.com/fleschutz/PowerShell
.NOTES
	Author: Markus Fleschutz | License: CC0
#>

function DrawScores {
    $x = [System.Console]::WindowWidth / 2 - 4
    [System.Console]::SetCursorPosition($x, 1)
    [System.Console]::Write("$($script:scorePlayer1) - $($script:scorePlayer2)")
}

function DrawFooter {
    $text = "| Player 1: <W> moves up, <S> moves down | Player 2: <UP> or <DOWN> | <ESC> to quit |"
    $x = ([System.Console]::WindowWidth - $text.Length) / 2
    $y = [System.Console]::WindowHeight - 1
    [System.Console]::SetCursorPosition($x, $y)
    [System.Console]::Write($text)
}

function DrawPaddle($y, $isLeft) {
	if ($isLeft) {
		$x = 0
	} else {
		$x = [System.Console]::WindowWidth - 1
	}
	for ($i = 0; $i -lt 5; $i++) {
		[System.Console]::SetCursorPosition($x, $y + $i)
		[System.Console]::Write("▌")
	}
}

function ClearPaddle($y, $isLeft) {
    if ($isLeft) {
        $x = 0
    } else {
        $x = [System.Console]::WindowWidth - 1
    }
    for ($i = 0; $i -lt 5; $i++) {
        [System.Console]::SetCursorPosition($x, $y + $i)
        [System.Console]::Write(" ")
    }
}

function DrawBall($x, $y) {
    if ($x -lt 0 -or $x -ge [System.Console]::WindowWidth - 1 -or $y -lt 0 -or $y -ge [System.Console]::WindowHeight) {
        return
    }
    [System.Console]::SetCursorPosition($x, $y)
    Write-Host "🔴" -noNewline
}

function ClearBall($x, $y) {
    if ($x -lt 0 -or $x -ge [System.Console]::WindowWidth - 1 -or $y -lt 0 -or $y -ge [System.Console]::WindowHeight) {
        return
    }
    [System.Console]::SetCursorPosition($x, $y)
    [System.Console]::Write(" ")
}

function UpdateBall {
    $nextX = $script:ball.X + $script:ball.Dx
    $nextY = $script:ball.Y + $script:ball.Dy

    if ($nextY -lt 0 -or $nextY -ge [System.Console]::WindowHeight) {
        $script:ball.Dy = -$script:ball.Dy
        $nextY = $script:ball.Y
    }

    if ($nextX -eq 1 -and ($nextY -ge $player1 -and $nextY -le ($player1 + 4))) {
        $script:ball.Dx = -$script:ball.Dx
        $nextX = $script:ball.X
    } elseif ($nextX -eq ([System.Console]::WindowWidth - 2) -and ($nextY -ge $player2 -and $nextY -le ($player2 + 4))) {
        $script:ball.Dx = -$script:ball.Dx
        $nextX = $script:ball.X
    }

    if ($nextX -lt 0) {
        $script:scorePlayer2++
        DrawScores
        $nextX = [System.Console]::WindowWidth / 2
    } elseif ($nextX -ge [System.Console]::WindowWidth) {
        $script:scorePlayer1++
        DrawScores
        $nextX = [System.Console]::WindowWidth / 2
    }

    $script:ball.X = $nextX
    $script:ball.Y = $nextY
}

$ui = (Get-Host).ui
$rui = $ui.rawui
$console = [System.Console]::BufferWidth = [System.Console]::WindowWidth = $rui.MaxWindowSize.Width
[System.Console]::BufferHeight = [System.Console]::WindowHeight = $rui.MaxWindowSize.Height

$player1 = 5
$player2 = 5
$ball = @{
    X = 25
    Y = 10
    Dx = 1
    Dy = 1
}
$scorePlayer1 = 0
$scorePlayer2 = 0
[System.Console]::Clear()
DrawPaddle $player1 $true
DrawPaddle $player2 $false
DrawScores
DrawFooter
[System.Console]::TreatControlCAsInput = $true

while ($true) {
    if ([System.Console]::KeyAvailable) {
        $key = [System.Console]::ReadKey($true).Key

        if ($key -eq "W" -and $player1 -gt 0) {
            ClearPaddle $player1 $true
            $player1--
            DrawPaddle $player1 $true
        } elseif ($key -eq "S" -and $player1 -lt [System.Console]::WindowHeight - 5) {
            ClearPaddle $player1 $true
            $player1++
            DrawPaddle $player1 $true
        } elseif ($key -eq "UpArrow" -and $player2 -gt 0) {
            ClearPaddle $player2 $false
            $player2--
            DrawPaddle $player2 $false
        } elseif ($key -eq "DownArrow" -and $player2 -lt [System.Console]::WindowHeight - 5) {
            ClearPaddle $player2 $false
            $player2++
            DrawPaddle $player2 $false
        } elseif ($key -eq "Escape") {
            break
        }
    }

    ClearBall $ball.X $ball.Y
    UpdateBall
    DrawBall $ball.X $ball.Y

    DrawPaddle $player1 $true
    DrawPaddle $player2 $false

    Start-Sleep -Milliseconds 100
}
[System.Console]::Clear()
exit 0 # success