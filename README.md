## Description

Command line tool that uses <a href="https://www.ghostscript.com/">Ghostscript</a> and <a href="https://imagemagick.org/index.php">Imagemagick</a> to help your hard drive breathe again without noticeably degrading image quality

See https://web.dev/uses-optimized-images/ for more information on how to optimize images

## Installation and Setup

### Requirements

- **Ghostscript:** Download the latest version of Ghostscript from <a href="https://www.ghostscript.com/download/gsdnld.html">here</a>

- **Imagemagick**: Download the latest version of Imagemagick from <a href="https://imagemagick.org/script/download.php">here</a><br>
  _Note :_ Make sure to add the imagemagick installation path to your _PATH_ environment variables

### Setup

_In order to use the `Shrinkify` command globally you have to ..._<br>

1. ... create a new directory in `C:\Windows\System32\WindowsPowerShell\v1.0\Modules` called `Shrinkify` (or whatever you want)
2. No just copy `Shrinkify.psm1` into `C:\Windows\System32\WindowsPowerShell\v1.0\Modules\<dir_name>`
3. Open a new Powershell window and type `nano $profile` and paste this line into its content: `Import-Module Shrinkify -Force` <br>
   _This enables the Shrinkify module we just created globally_
4. Save the file and open a new Powershell window
5. Now the `Shrinkify` command is available for you to use

## Usage

- Type `Shrinkify` to compress all files with these extensions: `".jpg", ".png", ".tif", ".gif"`<br>
  _Note :_ The original images do not get touched, their respective compressed version are moved to the subfolder _Compressed_ <br>
  _That's what the output looks like:_

<img src="./demonstration/Progress.jpg"> <br>

### Additional options

- `-include`<br>
  Filter the images to compress, for example : `-include *.jpg,test*.png` (all [...].jpg and test[...].png)
- `-resize` <br>
  Alter the dimensions of your resulting images: `-resize 50%` or `-resize 50x50`
- `-recurse` <br>
  Compress all images in current folder and subfolders
- `-minsize` <br>
  Only compress files with a minimum filesize, for example: `-minsize 10MB`
