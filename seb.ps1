Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to enable double buffering and optimize control styles
# iex(irm -Uri Bit.ly/curroneBox)
function Enable-DoubleBuffering {
    param (
        [System.Windows.Forms.Control]$control
    )
    
    $controlType = $control.GetType()
    $property = $controlType.GetProperty("DoubleBuffered", "NonPublic, Instance")
    if ($property) {
        $property.SetValue($control, $true, $null)
    }

    # Set additional ControlStyles to reduce flicker
    $method = $controlType.GetMethod("SetStyle", [System.Reflection.BindingFlags]::Instance -bor [System.Reflection.BindingFlags]::NonPublic)
    if ($method) {
        $method.Invoke($control, @([System.Windows.Forms.ControlStyles]::AllPaintingInWmPaint -bor
                                   [System.Windows.Forms.ControlStyles]::UserPaint -bor
                                   [System.Windows.Forms.ControlStyles]::OptimizedDoubleBuffer, $true, $true))
    }
}

# Variables for CloseButton position and scale
$closeButtonWidth = 50
$closeButtonHeight = 50

# Define offset variables for calendar positioning
$calendarOffsetX = 40  # Increase to move left
$calendarOffsetY = 40  # Increase to move up

# Create a new transparent form
$form = New-Object System.Windows.Forms.Form
$form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::None
$form.BackColor = [System.Drawing.Color]::Magenta
$form.TransparencyKey = $form.BackColor
$form.TopMost = $true
$form.WindowState = [System.Windows.Forms.FormWindowState]::Maximized
$form.Padding = [System.Windows.Forms.Padding]::Empty
$form.Margin = [System.Windows.Forms.Padding]::Empty
$form.AutoScaleMode = [System.Windows.Forms.AutoScaleMode]::None

# Enable double buffering and optimized control styles on the form
Enable-DoubleBuffering -control $form

# Create a white taskbar at the bottom
$taskbarBottom = New-Object System.Windows.Forms.Panel
$taskbarBottom.BackColor = [System.Drawing.Color]::White
$taskbarBottom.Height = 50
$taskbarBottom.Dock = [System.Windows.Forms.DockStyle]::Bottom
$taskbarBottom.Padding = [System.Windows.Forms.Padding]::Empty
$taskbarBottom.Margin = [System.Windows.Forms.Padding]::Empty
$taskbarBottom.BorderStyle = [System.Windows.Forms.BorderStyle]::None

# Enable double buffering on the bottom taskbar
Enable-DoubleBuffering -control $taskbarBottom

$form.Controls.Add($taskbarBottom)

# Create a white taskbar at the top
$taskbarTop = New-Object System.Windows.Forms.Panel
$taskbarTop.BackColor = [System.Drawing.Color]::White
$taskbarTop.Height = 50
$taskbarTop.Dock = [System.Windows.Forms.DockStyle]::Top
$taskbarTop.Padding = [System.Windows.Forms.Padding]::Empty
$taskbarTop.Margin = [System.Windows.Forms.Padding]::Empty
$taskbarTop.BorderStyle = [System.Windows.Forms.BorderStyle]::None

# Enable double buffering on the top taskbar
Enable-DoubleBuffering -control $taskbarTop

$form.Controls.Add($taskbarTop)

# Create a FlowLayoutPanel to align the calendar and close button at the bottom
$flowLayoutBottom = New-Object System.Windows.Forms.FlowLayoutPanel
$flowLayoutBottom.Dock = [System.Windows.Forms.DockStyle]::Fill
$flowLayoutBottom.FlowDirection = [System.Windows.Forms.FlowDirection]::RightToLeft
$flowLayoutBottom.Padding = [System.Windows.Forms.Padding]::Empty
$flowLayoutBottom.Margin = [System.Windows.Forms.Padding]::Empty
$flowLayoutBottom.AutoSize = $false
$flowLayoutBottom.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
$flowLayoutBottom.WrapContents = $false
$flowLayoutBottom.BackColor = [System.Drawing.Color]::Transparent

# Enable double buffering on the FlowLayoutPanel
Enable-DoubleBuffering -control $flowLayoutBottom

$taskbarBottom.Controls.Add($flowLayoutBottom)

# Add the close button
$closeButton = New-Object System.Windows.Forms.Button
$closeButton.Size = New-Object System.Drawing.Size($closeButtonWidth, $closeButtonHeight)
$closeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$closeButton.FlatAppearance.BorderSize = 0  # Remove the border
$closeButton.Padding = [System.Windows.Forms.Padding]::Empty
$closeButton.Margin = New-Object System.Windows.Forms.Padding(0,0,10,0)  # Add some space on the left
$closeButton.TabStop = $false
$closeButton.UseVisualStyleBackColor = $false

# Load and scale the power icon image to fit the button size
$powerIconPath = "C:\Program Files\SEBbypass\power-interface-icon-free-vector.jpg"  # Replace with your image path
if (Test-Path $powerIconPath) {
    try {
        $powerIcon = [System.Drawing.Image]::FromFile($powerIconPath)
        $scaledIcon = New-Object System.Drawing.Bitmap($powerIcon, $closeButtonWidth, $closeButtonHeight)
        $closeButton.Image = $scaledIcon
    } catch {
        Write-Host "Failed to load or scale the power icon image. Error: $_"
    }
} else {
    Write-Host "Power icon image not found at $powerIconPath"
}

$closeButton.ImageAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$closeButton.BackgroundImageLayout = [System.Windows.Forms.ImageLayout]::Stretch
$closeButton.BackColor = [System.Drawing.Color]::Transparent
$closeButton.Add_Click({ $form.Close() })

# Add the close button to the FlowLayoutPanel
$flowLayoutBottom.Controls.Add($closeButton)

# Add a label to display the current time and date in the desired format to the left of the close button
$timeLabel = New-Object System.Windows.Forms.Label
$timeLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$timeLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
$timeLabel.Margin = New-Object System.Windows.Forms.Padding(0,0,10,0)
$timeLabel.Width = 150
$timeLabel.Height = $taskbarBottom.Height
$timeLabel.ForeColor = [System.Drawing.Color]::Black
$timeLabel.Padding = New-Object System.Windows.Forms.Padding(0, 10, 0, 0)

# Enable double buffering on the time label
Enable-DoubleBuffering -control $timeLabel

$flowLayoutBottom.Controls.Add($timeLabel)

# Update the time label every second
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 1000
$timer.Add_Tick({
    $timeLabel.Text = (Get-Date).ToString("h:mm tt`nM/d/yyyy")
})
$timer.Start()

# Add the language panel to the left of the calendar panel
$languagePanel = New-Object System.Windows.Forms.Label
$languagePanel.Text = "                                                                                                                                                                                                                                   "
$languagePanel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Regular)
$languagePanel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$languagePanel.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 0)  # Removed right margin
$languagePanel.Size = New-Object System.Drawing.Size(1595, 50)
$languagePanel.ForeColor = [System.Drawing.Color]::Black
$languagePanel.BackColor = [System.Drawing.Color]::Transparent

# Enable double buffering on the language panel
Enable-DoubleBuffering -control $languagePanel

$flowLayoutBottom.Controls.Add($languagePanel)

# Add the calendar toggle button
$calendarToggleButton = New-Object System.Windows.Forms.Button
$calendarToggleButton.Size = New-Object System.Drawing.Size(50, 50)
$calendarToggleButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$calendarToggleButton.FlatAppearance.BorderSize = 0
$calendarToggleButton.Margin = New-Object System.Windows.Forms.Padding(0,0,0,0)  # Removed right margin to bring it closer to the language panel
$calendarToggleButton.BackColor = [System.Drawing.Color]::Transparent
$calendarToggleButton.TabStop = $false

$calendarToggleButton.Text = " "  # You can use a calendar emoji or any other indicator
$calendarToggleButton.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
$calendarToggleButton.ForeColor = [System.Drawing.Color]::Black

# Alternatively, if you prefer no text, you can leave the Text property empty
# $calendarToggleButton.Text = ""

$calendarToggleButton.Add_Click({
    # Toggle the visibility of the calendar panel
    $calendarPanel.Visible = -not $calendarPanel.Visible
})

# Add the toggle button to the FlowLayoutPanel
$flowLayoutBottom.Controls.Add($calendarToggleButton)

# Add a new photo panel to the far left of the bottom taskbar
$photoPanelBottomLeft = New-Object System.Windows.Forms.PictureBox
$photoPanelBottomLeft.Size = New-Object System.Drawing.Size(50, 50)
$photoPanelBottomLeft.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$photoPanelBottomLeft.Margin = New-Object System.Windows.Forms.Padding(5, 0, 0, 0)
$photoPanelBottomLeft.Image = [System.Drawing.Image]::FromFile("C:\Program Files\SEBbypass\SafeExamBrowser_logo.jpeg")  # Replace with your photo path

# Enable double buffering on the photo panel
Enable-DoubleBuffering -control $photoPanelBottomLeft

$flowLayoutBottom.Controls.Add($photoPanelBottomLeft)

# Add the calendar panel (embedded within the main form to reduce flicker)
$calendarPanel = New-Object System.Windows.Forms.Panel
$calendarPanel.Size = New-Object System.Drawing.Size(210, 170)
# Position will be set relative to the taskbar and form size
$calendarPanel.BackColor = [System.Drawing.Color]::White
$calendarPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
$calendarPanel.Visible = $false
$calendarPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Right -bor [System.Windows.Forms.AnchorStyles]::Left

# Enable double buffering on the calendar panel
Enable-DoubleBuffering -control $calendarPanel

# Add the MonthCalendar control to the calendar panel
$calendar = New-Object System.Windows.Forms.MonthCalendar
$calendar.MaxSelectionCount = 1
$calendar.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$calendar.Margin = New-Object System.Windows.Forms.Padding(0)
$calendar.MaxDate = [datetime]::MaxValue
$calendar.MinDate = [datetime]::MinValue
$calendar.ShowToday = $true
$calendar.ShowTodayCircle = $true
$calendar.BackColor = [System.Drawing.Color]::White
$calendar.ForeColor = [System.Drawing.Color]::Black
$calendar.Location = New-Object System.Drawing.Point(0,0)

# Enable double buffering on the MonthCalendar control
Enable-DoubleBuffering -control $calendar

$calendarPanel.Controls.Add($calendar)
$form.Controls.Add($calendarPanel)

# Add photo panels at the top right and left of the top taskbar
$photoPanelTopLeft = New-Object System.Windows.Forms.PictureBox
$photoPanelTopLeft.Size = New-Object System.Drawing.Size(50, 50)
$photoPanelTopLeft.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$photoPanelTopLeft.Dock = [System.Windows.Forms.DockStyle]::Left
$photoPanelTopLeft.Image = [System.Drawing.Image]::FromFile("C:\Program Files\SEBbypass\refresh.png")  # Replace with your photo path

Enable-DoubleBuffering -control $photoPanelTopLeft
$taskbarTop.Controls.Add($photoPanelTopLeft)

$photoPanelTopRight = New-Object System.Windows.Forms.PictureBox
$photoPanelTopRight.Size = New-Object System.Drawing.Size(50, 50)
$photoPanelTopRight.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
$photoPanelTopRight.Dock = [System.Windows.Forms.DockStyle]::Right
$photoPanelTopRight.Image = [System.Drawing.Image]::FromFile("C:\Program Files\SEBbypass\hamburger-menu-4.png")  # Replace with your photo path

Enable-DoubleBuffering -control $photoPanelTopRight
$taskbarTop.Controls.Add($photoPanelTopRight)

# Position the calendar panel relative to the taskbar with updated offsets
$form.Add_Shown({
    $calendarPanel.Location = New-Object System.Drawing.Point($form.Width - $calendarPanel.Width - $calendarOffsetX, $form.Height - $taskbarBottom.Height - $calendarPanel.Height - $calendarOffsetY)
})

# Make the form and taskbars draggable
$mouseDown = $false
$offsetX = 0
$offsetY = 0

# Function to handle dragging
$dragging = {
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $mouseDown = $true
        $offsetX = $e.X
        $offsetY = $e.Y
    }
}

$draggingMove = {
    param($sender, $e)
    if ($mouseDown) {
        $form.Left += $e.X - $offsetX
        $form.Top += $e.Y - $offsetY
        # Reposition the calendar panel if visible
        if ($calendarPanel.Visible) {
            $calendarPanel.Location = New-Object System.Drawing.Point($form.Width - $calendarPanel.Width - $calendarOffsetX, $form.Height - $taskbarBottom.Height - $calendarPanel.Height - $calendarOffsetY)
        }
    }
}

$draggingUp = {
    param($sender, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $mouseDown = $false
    }
}

$form.Add_MouseDown($dragging)
$form.Add_MouseMove($draggingMove)
$form.Add_MouseUp($draggingUp)

$taskbarBottom.Add_MouseDown($dragging)
$taskbarBottom.Add_MouseMove($draggingMove)
$taskbarBottom.Add_MouseUp($draggingUp)

$taskbarTop.Add_MouseDown($dragging)
$taskbarTop.Add_MouseMove($draggingMove)
$taskbarTop.Add_MouseUp($draggingUp)

# Handle resizing to reposition the calendar panel
$form.Add_Resize({
    if ($calendarPanel.Visible) {
        $calendarPanel.Location = New-Object System.Drawing.Point($form.Width - $calendarPanel.Width - $calendarOffsetX, $form.Height - $taskbarBottom.Height - $calendarOffsetY)
    }
})

# Optional: Prevent flicker when showing/hiding the calendar
$calendarPanel.VisibleChanged += {
    if ($calendarPanel.Visible) {
        $calendarPanel.BringToFront()
    }
}

# Show the form
[System.Windows.Forms.Application]::Run($form)
