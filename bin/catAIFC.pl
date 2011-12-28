#!/usr/bin/perl
#
# catAIFC.pl concatenates AIFC and RIFF WAVE files in a single output stream.
# All files MUST have identical audio formats and structures (channels, sample rates etc.). 
# ALL sound chunks are combined. Compressed files might not be concattenated
# correctly. Mixing AIFC and WAVE files will result in useless files.
# Note that ALL non-essential chunks are dropped.
# catAIFC.pl is fairly inefficient. It will pass over all files twice. Once to
# determine their length, once to actually output data.
#
# version 1.0
# 14 September 1999
#
# use:
# catAIFC.pl file file ... > concatenatedFile.aifc
#
# or
#
# require 'catAIFC.pl'; catAIFC(list of file names); # prints to $FileOutput
#
###############################################################################
#
# Author and Copyright:
# Rob van Son, � 1999
# Institute of Phonetic Sciences & IFOTT
# University of Amsterdam
# Herengracht 338
# NL-1016CG Amsterdam, The Netherlands 
# Email: Rob.van.Son@hum.uva.nl
#rob.van.son@workmail.com
# WWW : http://www.fon.hum.uva.nl/rob
#
# License for use and disclaimers
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
#
#
#########################################################################
#
# File pointer to write to (can be changed to a file)
my $FileOutput = STDOUT;
#
my $SoundFileType = 'AIFC';# Current file type 
# Current Byte order (un)pack parameter (Big-Endian vs Little Endian)
my $EndianOrder = "N"; # (Normal Internet Byte-Order: Big-Endian)
# Get the header of the chunk
sub GetChunkInfo# (FILE) -> ($ckID, $ckDataSize [, $formType])
{
my $AudioFile = shift;
#
my @result = ();
my $ckID;
sysread($AudioFile, $ckID, 4) || return ();
push (@result, $ckID);
#
my $ckDataSize;
sysread($AudioFile, $ckDataSize, 4) || die "$AudioFile datasize read error: $!\n";
$EndianOrder = "V" if $ckID eq 'RIFF';# Non-Internet Byte Order
$ckDataSize = unpack("$EndianOrder", $ckDataSize);
# The stored $ckDataSize is a SIGNED 32 bits long integer. Check for negative sizes
die "Datasize < 0 error: $ckDataSize\n" if $ckDataSize > 2147483648;
push (@result, $ckDataSize);
#
if($ckID eq 'FORM' || $ckID eq 'RIFF')
{
my $formType;
sysread($AudioFile, $formType, 4) || die "$AudioFile formtype read error: $!\n";
push (@result, $formType);
$SoundFileType = $formType;
};
return @result;
};
# Get the header and the data in a chunk. Sound data are skipped unless an output
# file pointer is given
sub GetChunk # (FILE [, OUTPUT]) -> ($ckID, $ckDataSize [, $formType], SSNDsize)[+ syswrite($Data)]
{
my $AudioFile = shift;
my $OutFile = shift || "";
#
my @result = GetChunkInfo($AudioFile);
return () unless @result && $result[1] > 0;
# DON'T read all sound samples
my $ckData = "";
if($result[0] eq 'SSND')
{ 
my $DataSize = $result[1];# Total number of bytes
sysread($AudioFile, $ckData, 8) # read first two LL
|| die "@result $AudioFile data read error: $!\n";
$DataSize -= 8; # Remove first two LL
# Read through rest of block, write it to the output if necessary
while($DataSize)
{
my $DataBlock = "";
my $BlockSize = $DataSize > 1024 ? 1024 : $DataSize;
my $ReadBlockSize = 0; 
$ReadBlockSize = sysread($AudioFile, $DataBlock, $BlockSize);# Read block of data
die "@result $AudioFile Sampled data read error: $!\n" unless $ReadBlockSize;
$DataSize -= $ReadBlockSize;
syswrite($OutFile, $DataBlock, $ReadBlockSize) if $OutFile && $ReadBlockSize;
};
}
elsif($result[0] eq 'data' && $SoundFileType eq 'WAVE')
{ 
my $DataSize = $result[1];# Total number of bytes
# Read through rest of block, write it to the output if necessary
while($DataSize)
{
my $DataBlock = "";
my $BlockSize = $DataSize > 1024 ? 1024 : $DataSize;
my $ReadBlockSize = 0; 
$ReadBlockSize = sysread($AudioFile, $DataBlock, $BlockSize);# Read block of data
die "@result $AudioFile Sampled data read error: $!\n" unless $ReadBlockSize;
$DataSize -= $ReadBlockSize;
syswrite($OutFile, $DataBlock, $ReadBlockSize) if $OutFile && $ReadBlockSize;
};
}
else# Other blocks are read in total
{
sysread($AudioFile, $ckData, $result[1]) 
|| die "@result $AudioFile data read error: $!\n";
};
push(@result, $ckData);
return @result;
}
sub catAIFC# (file names) -> single AIFC file to $FileOutput
{
my @Files = @_;
# Start autoflush
select($FileOutput) || die "$!\n";;
$| = 1;
# First, determine the total size of the sound files 
my @formInfo;
my @verInfo;
my @RIFFfmt;
my $TotalNumberOfSampleFrames = 0;
my $TotalSoundDataSize = 0;
my ($numChannels, $numSampleFrames, $sampleSize, $rest);
foreach $AudioFile (@Files)
{
open(INPUT, "<$AudioFile") || die "<$AudioFile not opened $!\n";
@formInfo = GetChunkInfo(INPUT);
@verInfo = GetChunk(INPUT) unless $SoundFileType eq 'WAVE'; # AIFC version
my @DataChunk = ();
while(@DataChunk = GetChunk(INPUT))
{
if($DataChunk[0] eq 'COMM')
	{
($numChannels, $numSampleFrames, $sampleSize, $rest) =
		unpack("s${EndianOrder}sa*", $DataChunk[2]);
	$TotalNumberOfSampleFrames += $numSampleFrames;
}
elsif($DataChunk[0] eq 'SSND')
	{
	$TotalSoundDataSize += $DataChunk[1] - 8;
}
elsif($DataChunk[0] eq 'data' && $SoundFileType eq 'WAVE')
	{
	$TotalSoundDataSize += $DataChunk[1];
}
elsif($DataChunk[0] eq 'fmt ' && $SoundFileType eq 'WAVE')
{
@RIFFfmt = @DataChunk;
};
};
# Close
close(INPUT);
};
# Construct the COMMON block
my $CommonBlock = "";
unless($SoundFileType eq 'WAVE')
{
$CommonBlock = 
 pack("s${EndianOrder}sa*", $numChannels, $TotalNumberOfSampleFrames, $sampleSize, $rest);
};
# Write FORM, VER, and COMM and SSND blocks
if($SoundFileType eq 'WAVE') # Non-Internet
{
$formInfo[1] = 0 + 8+$RIFFfmt[1]+8+$TotalSoundDataSize;
syswrite($FileOutput, pack("a4Va4", @formInfo), 12);# RIFF chunk
syswrite($FileOutput, pack("a4Va*", @RIFFfmt), length($RIFFfmt[2])+8); # fmt Block
syswrite($FileOutput, pack("a4V", 'data', $TotalSoundDataSize), 8);# sound data
}
else # Internet
{
$formInfo[1] = 0 + 12+26 + 8+16+$TotalSoundDataSize;
syswrite($FileOutput, pack("a4${EndianOrder}a4", @formInfo), 12);# Form chunk
syswrite($FileOutput, pack("a4${EndianOrder}${EndianOrder}", @verInfo), 12);# version chunk
syswrite($FileOutput, pack("a4${EndianOrder}a*", 'COMM', length($CommonBlock), $CommonBlock), 
 length($CommonBlock)+8); # Common Block
syswrite($FileOutput, pack("a4${EndianOrder}${EndianOrder}${EndianOrder}", 'SSND', $TotalSoundDataSize+8, 0, 0), 16);
};
# 
# Write all samples to output
foreach $AudioFile (@Files)
{
open(INPUT, "<$AudioFile") || die "<$AudioFile not opened $!\n";
@formInfo = GetChunkInfo(INPUT);
my @DataChunk = ();
while(@DataChunk = GetChunk(INPUT, $FileOutput)){};
# Close
close(INPUT)
};
}
unless(caller())
{
catAIFC(@ARGV);
};
1; # Make require happy
=head1 NAME
catAIFC.pl - concatenates AIFC and RIFF (wav) files 
=head1 DESCRIPTION
catAIFC.pl concatenates AIFC and RIFF WAVE files in a single output stream.
 
=head1 README
catAIFC.pl concatenates AIFC and RIFF WAVE files in a single output stream.
All files MUST have identical audio formats and structures (channels, sample 
rates etc.). ALL sound chunks are combined. Compressed files might not be 
concattenated correctly. Mixing AIFC and WAVE files will result in useless 
files. Note that ALL non-essential chunks are dropped.
catAIFC.pl is fairly inefficient. It will pass over all files twice. Once to
determine their length, once to actually output data.
=head1 PREREQUISITES
=head1 COREQUISITES
=pod OSNAMES
Unix
=pod SCRIPT CATEGORIES
Audio: AIFC
Audio: RIFF
Web
=cut

