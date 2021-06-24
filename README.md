
This is the Antelope real-time environment for running IceWeb 2.0 (aka TreMoR) interface used to generate spectrograms for http://www.aeic.alaska.edu/spectrograms, last updated in 2013 when I left UAFGI. It does not appear that anyone at UAFGI has modified the code since.
The corresponding Web interface is https://github.com/giseislab/TreMoR-spectrograms-web-interface.

See https://github.com/geoscience-community-codes/IceWeb for a more recent combined version of both and background.

<pre>
Listing of project run directory afer it was recreated on 20130123:

lrwxrwxr-x   1 iceweb  analyst    33 Jan 23 12:38 GISMO@ -> /Users/iceweb/src/GISMO/git/GISMO
lrwxrwxr-x   1 iceweb  analyst     7 Jan 23 12:32 bin@ -> src/bin
lrwxrwxr-x   1 iceweb  analyst     7 Jan 23 14:44 lib@ -> src/lib
drwxrwxr-x   8 iceweb  analyst   272 Jan 22 12:10 lockfiles/
drwxrwxr-x  25 iceweb  analyst   850 Jan 23 14:45 logs/
lrwxrwxr-x   1 iceweb  analyst    15 Jan 23 12:31 matlab@ -> src/data/matlab
drwxrwxr-x   2 iceweb  analyst    68 Jan 22 11:12 orb/
lrwxrwxr-x   1 iceweb  analyst    10 Jan 23 14:44 params@ -> src/params
lrwxrwxr-x   1 iceweb  analyst    11 Jan 23 12:31 pf@ -> src/data/pf
-rw-rw-r--   1 iceweb  analyst  7170 Jan 23 14:44 rtexec.pf
drwxrwxr-x   8 iceweb  analyst   272 Jan 23 13:59 rtsys/
lrwxrwxr-x   1 iceweb  analyst    11 Jan 23 14:45 schemas@ -> src/schemas
drwxrwxr-x  29 iceweb  analyst   986 Jan 23 14:23 spectrograms/
lrwxrwxr-x   1 iceweb  analyst    28 Jan 22 11:55 src@ -> /Users/iceweb/src/TreMoR_new
-rw-rw-r--   1 iceweb  analyst    15 Jan 23 12:37 startup.m
-rwxrwxr-x   1 iceweb  analyst   415 Jan 23 12:44 startup_tremor.m*
drwxrwxr-x   3 iceweb  analyst   102 Jan 22 12:08 state/
drwxrwxr-x   8 iceweb  analyst   272 Jan 22 11:57 waveform_files/
lrwxrwxr-x   1 iceweb  analyst    36 Jan 22 11:58 www@ -> /usr/local/mosaic/AVO/avoseis/TreMoR

Most directories are linked through src@.

GISMO is linked through GISMO@.

rtexec.pf, startup.m, and startup_tremor.m are autoarchived to src/autobackups hourly. These do not
overwrite those in src/, just in case need to rollback.  
</pre>

