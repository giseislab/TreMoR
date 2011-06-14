RUN=~/run/TreMoR
INTERNALWEBPRODUCTS=${INTERNALWEBPRODUCTS}
CWD=${PWD}
 
html:
	rsync -r html/* ${INTERNALWEBPRODUCTS}/html

rtexec:
	cp rtexec.pf ${RUN}/

startup:
	cp startup_tremor.m ${RUN}/

mkdir:
	cd ${RUN}
	mkdir 1mindata logs rtsys state waveforms_raw waveforms_sam waveforms_sgram
	ln -s ${CWD}/bin bin
	ln -s ${CWD}/data/pf pf
	echo "create symlinks for db and dbmaster." 

