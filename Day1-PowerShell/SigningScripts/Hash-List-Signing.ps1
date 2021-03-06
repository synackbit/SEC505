<# ##############################################################

A PS1 file does not have to contain any PowerShell script code.
The file could contain other data, such as lines of XML text. 
Almost any file ending with ".ps1" can be digitally signed in
order to detect changes to that file and confirm origin.
  
For example, thousands of files might be hashed with Get-FileHash,
then these hash objects saved to an XML file with Export-CliXml.
This XML file, however, can have the .ps1 file name extension when
it is saved; the saved file does not have to end with .xml, which
means that this file can be digitally signed.  This signed file
is now similar to a Microsoft catalog file, i.e., a signed list
of file hashes, except that you have signed the list, not Microsoft.

################################################################ #>


# Hash some files and save the output to an XML file:
Get-FileHash -Path sig*.ps1 | Export-Clixml -Path hashes.xml.ps1


# Sign the hashes.xml.ps1 file with your code-signing cert:
.\Sign-Script.ps1 -Path .\hashes.xml.ps1


# Check the signature on the hashes.xml.ps1 file:
.\Check-Signature.ps1 -Path .\hashes.xml.ps1


# No valid line of an XML file begins with a hashmark, but
# every line in the hashes.xml.ps1 file that contains
# signature data begins with a hashmark. This makes it easy
# to extract just the XML from the file using a regular
# expression pattern for lines that begin with a hashmark.
# These lines can then be saved to a new XML file which is
# compatible with Import-CliXml to recreate the original objects:

Get-Content -Path .\hashes.xml.ps1 |
Select-String -NotMatch '^#' |
Out-File -FilePath tempfile.xml

$xmldata = Import-Clixml -Path .\tempfile.xml

del -Path .\tempfile.xml




# If desired, the XML string data can be cast to an XML object in
# memory, bypassing the need for a temp file, but this is not as
# convenient for recreating the original objects again:

$xmlnodes = [XML] (Get-Content -Path .\hashes.xml.ps1 | Select-String -NotMatch '^#') 


