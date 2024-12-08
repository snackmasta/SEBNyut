Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Function to enable double buffering and optimize control styles
function Enable-DoubleBuffering {
    param (
        [System.Windows.Forms.Control]$control
    )
    
    # Enable DoubleBuffering
    $controlType = $control.GetType()
    $property = $controlType.GetProperty("DoubleBuffered", "NonPublic, Instance")
    if ($property) {
        $property.SetValue($control, $true, $null)
    }

    # Set additional ControlStyles to reduce flicker
    $method = $controlType.GetMethod("SetStyle", [System.Reflection.BindingFlags]::NonPublic -bor [System.Reflection.BindingFlags]::Instance)
    $control.SetStyle([System.Windows.Forms.ControlStyles]::DoubleBuffer, $true)
    $control.SetStyle([System.Windows.Forms.ControlStyles]::UserPaint, $true)
    $control.SetStyle([System.Windows.Forms.ControlStyles]::AllPaintingInWmPaint, $true)
    $control.SetStyle([System.Windows.Forms.ControlStyles]::Opaque, $true)
}

# Example usage: Create a form with a button
$form = New-Object System.Windows.Forms.Form
$form.Text = "Double Buffering Example"
$form.Width = 400
$form.Height = 300

$button = New-Object System.Windows.Forms.Button
$button.Text = "Click Me!"
$button.Width = 100
$button.Height = 50
$button.Location = New-Object System.Drawing.Point(150, 100)

# Enable double buffering on the button
Enable-DoubleBuffering -control $button

$form.Controls.Add($button)
$form.ShowDialog()
