function AutomaticShutdown {
	
	Add-Type -AssemblyName System.Windows.Forms

	[System.Windows.Forms.Application]::EnableVisualStyles()
	$form1 = New-Object System.Windows.Forms.Form
	$label000000 = New-Object System.Windows.Forms.Label
	$timer1 = New-Object System.Windows.Forms.Timer
    $button = New-Object System.Windows.Forms.Button
	$InitialFormWindowState = New-Object System.Windows.Forms.FormWindowState

$time = Get-Content $env:appdata\ParsecLoader\ShutdownTimer.txt -First 1

	$form1_Load = {
		$script:countdown = [timespan]$time # 10 minutes
		$label000000.Text = "$countdown"
		$timer1.Start()

	}
	
    $button_logic = {
    Stop-ScheduledTask -TaskName 'Automatic Shutdown On Idle'
    $form1.Close()
    }

	$timer1_Tick = {
        if ($countdown -lt [timespan]'00:00:02') {$timer1.Stop()
        #shutdown /s -t 0
        }
        Else{}
		$script:countdown -= [timespan]'00:00:01'
		$label000000.Text = "$countdown"

	}
	
	$Form_StateCorrection_Load =
	{
		#Correct the initial state of the form to prevent the .Net maximized form issue
		$form1.WindowState = $InitialFormWindowState
	}


	$form1.SuspendLayout()
    $form1.BringToFront()
    $Form1.ControlBox = $False
	$form1.Controls.Add($label000000)
	$form1.AutoScaleDimensions = '8, 17'
	$form1.AutoScaleMode = 'Font'
	$form1.BackColor = 'ActiveCaption'
	$form1.ClientSize = '400, 200'
	$form1.FormBorderStyle = 'Fixed3D'
	$form1.Name = 'form1'
	$form1.StartPosition = 'CenterScreen'
	$form1.Text = 'Automatic Shutdown On Idle'
	$form1.add_Load($form1_Load)

    $Button.Location = New-Object System.Drawing.Size(75,75)
    $Button.Size = New-Object System.Drawing.Size(150,23)
    $Button.Text = "Cancel Shutdown"
    $button.Add_click($button_logic)


	$label000000.AutoSize = $True
	$label000000.Font = 'Lucida Fax, 24pt, style=Bold'
	$label000000.Location = '90, 25'
	$label000000.Margin = '4, 0, 4, 0'
	$label000000.Name = 'label000000'
	$label000000.Size = '200, 46'
	$label000000.TabIndex = 0
	$label000000.Text = '00:00:00'

	$timer1.Interval = 1000
	$timer1.add_Tick($timer1_Tick)
	$form1.ResumeLayout()

	$InitialFormWindowState = $form1.WindowState
	$form1.add_Load($Form_StateCorrection_Load)
    $Form1.Controls.Add($Button)
	return $form1.ShowDialog()
}
AutomaticShutdown