# Builds bg.jpg for the new tab page: the wallpaper exactly as the desktop shows it
# (Fill mode, full screen), lightly darkened. Pass -BlurFrom <row> to blur it from that row down.
# newtab.js shifts it by the window position so it lines up with the desktop.
param(
    [string]$Wallpaper = "$PSScriptRoot\..\wallpaper\red-balloon.jpg",
    [string]$Out = "$PSScriptRoot\bg.jpg",
    [int]$Width = 1920, [int]$Height = 1080,
    [int]$BlurFrom = 100000   # screen row where the blur starts; the default keeps it fully sharp
)
Add-Type -AssemblyName System.Drawing
Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition @'
using System; using System.Drawing; using System.Drawing.Imaging; using System.Runtime.InteropServices;
public static class RBBake2 {
  static float[] Read(Bitmap b) {
    var d = b.LockBits(new Rectangle(0,0,b.Width,b.Height), ImageLockMode.ReadOnly, PixelFormat.Format24bppRgb);
    var raw = new byte[d.Stride*b.Height]; Marshal.Copy(d.Scan0, raw, 0, raw.Length);
    var f = new float[b.Width*b.Height*3];
    for (int y = 0; y < b.Height; y++) for (int x = 0; x < b.Width*3; x++) f[(y*b.Width*3)+x] = raw[y*d.Stride+x];
    b.UnlockBits(d); return f;
  }
  // one horizontal + one vertical box pass with clamped edges
  static void Box(float[] s, float[] t, int w, int h, int r) {
    float n = 2*r+1;
    for (int y = 0; y < h; y++) for (int c = 0; c < 3; c++) {
      float acc = 0;
      for (int k = -r; k <= r; k++) acc += s[(y*w + Math.Min(w-1, Math.Max(0, k)))*3+c];
      for (int x = 0; x < w; x++) {
        t[(y*w+x)*3+c] = acc/n;
        acc += s[(y*w + Math.Min(w-1, x+r+1))*3+c] - s[(y*w + Math.Max(0, x-r))*3+c];
      }
    }
    for (int x = 0; x < w; x++) for (int c = 0; c < 3; c++) {
      float acc = 0;
      for (int k = -r; k <= r; k++) acc += t[(Math.Min(h-1, Math.Max(0, k))*w + x)*3+c];
      for (int y = 0; y < h; y++) {
        s[(y*w+x)*3+c] = acc/n;
        acc += t[(Math.Min(h-1, y+r+1)*w + x)*3+c] - t[(Math.Max(0, y-r)*w + x)*3+c];
      }
    }
  }
  public static Bitmap Make(Bitmap screen, int radius, int blurFrom) {
    int w = screen.Width, h = screen.Height;
    var sharp = Read(screen);
    var blur = (float[])sharp.Clone(); var tmp = new float[blur.Length];
    for (int i = 0; i < 3; i++) Box(blur, tmp, w, h, radius);   // 3 box passes ~ Gaussian
    float[] tint = { 0x24, 0x1A, 0x06 };                          // BGR of #061A24
    var o = new Bitmap(w, h, PixelFormat.Format24bppRgb);
    var d = o.LockBits(new Rectangle(0,0,w,h), ImageLockMode.WriteOnly, PixelFormat.Format24bppRgb);
    var raw = new byte[d.Stride*h];
    for (int y = 0; y < h; y++) {
      double t = Math.Min(1, Math.Max(0, (y - (double)blurFrom) / 420.0)); t = t*t*(3-2*t);
      double dark = 0.22 + 0.18 * ((double)y / h);   // light, so the wallpaper stays vivid
      for (int x = 0; x < w; x++) for (int c = 0; c < 3; c++) {
        int i = (y*w+x)*3+c;
        double v = sharp[i]*(1-t) + blur[i]*t;
        raw[y*d.Stride + x*3 + c] = (byte)Math.Max(0, Math.Min(255, Math.Round(v*(1-dark) + tint[c]*dark)));
      }
    }
    Marshal.Copy(raw, 0, d.Scan0, raw.Length); o.UnlockBits(d); return o;
  }
}
'@
$src = [Drawing.Image]::FromFile((Resolve-Path $Wallpaper))
$s = [Math]::Max($Width / $src.Width, $Height / $src.Height)
$w = [int]($src.Width * $s); $h = [int]($src.Height * $s)
$screen = New-Object Drawing.Bitmap $Width, $Height, ([Drawing.Imaging.PixelFormat]::Format24bppRgb)
$g = [Drawing.Graphics]::FromImage($screen); $g.InterpolationMode = 'HighQualityBicubic'
$g.DrawImage($src, -[int](($w - $Width) / 2), -[int](($h - $Height) / 2), $w, $h); $g.Dispose(); $src.Dispose()
$result = [RBBake2]::Make($screen, 14, $BlurFrom)
$enc = [Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object MimeType -eq 'image/jpeg'
$p = New-Object Drawing.Imaging.EncoderParameters 1
$p.Param[0] = New-Object Drawing.Imaging.EncoderParameter ([Drawing.Imaging.Encoder]::Quality), 92L
$result.Save($Out, $enc, $p)
Get-Item $Out | Select-Object FullName, Length
