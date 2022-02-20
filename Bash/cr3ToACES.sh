export OCIO=/home/davidabbott/.nuke/OCIOConfigs/configs/aces_custom/config.ocio

for cr3  in $(find -name '*.cr3'); do
	mkdir ./EXRs
	oiiotool -iconfig "raw:ColorSpace" ACES $cr3 -colorconvert ACES ACEScg --compression dwab -o ./EXRs/${cr3%.*}.exr;
done


