#!/bin/bash
# script that actuall runs the alignment

# run from pipeline.sh
# $1 is the command to run
# $2 is the species that you are aligning to
# $3 is the number of cores you are using


if [ ! -d "fastqc" ]; then
	mkdir fastqc
fi

if [ ! -d "tmpdir" ]; then
	mkdir tmpdir
fi

if [ ! -d "tophat_alignment" ]; then
	mkdir tophat_alignment
fi

if [ ! -d "cuffquant_out" ]; then
	mkdir cuffquant_out
fi



function runpipeline {
	echo -e "Starting\tQuality Control with FastQC..."

	# dont do fastqc if run stopped for some reason 
	for file in *.fastq
	do
		if [ ! "$ls fastqc" ]; then
			fastqc -q --noextract -o fastqc $file
			echo -e "Finished\tQuality Control...\t$file"
		else
			echo -e "Skipping\tQuality Control...\t$file"
		fi
	done

	


	echo -e "\nStarting\tTrimming with Cutadapt..."
	for file in *.fastq
	do
		# if this hasn't already been done yet
		if [ ! -f trimmed_$file ]; then
			cutadapt -m 20 -q 20 -a AGATCGGAAGAGCAC --match-read-wildcards $file > trimmed_$file
			# put away old file because you really don't need it anymore
			mv $file tmpdir/
			echo -e "Finished\tTrimming...\t$file"
		else
			echo -e "Skipping\tTrimming...\t$file"
		fi
	done



	echo -e "\nStarting\tQuality Control with FastQC again just to be sure..."
	for file in trimmed_*.fastq
	do
		fastqc -q --noextract -o fastqc $file
		echo -e "Finished\tQuality Control...\t$file"
	done



	echo -e "\nStarting\tAlignment with Tophat..."
	if [ "$2" == "d" ]; then
		echo -e "Using\t\tDog genome."
	fi
	if [ "$2" == "m" ]; then
		echo -e "Using\t\tMouse genome."
	fi

	for file in trimmed_*.fastq
	do
		if [ "$2" == "d" ]; then
			tophat -p $3 -o tophat_alignment \
				--transcriptome-index=latest_dog_genes \
				latest_dog_genes $file
		fi
		if [ "$2" == "m" ]; then
			tophat -p $3 -o tophat_alignment \
				--transcriptome-index=latest_mouse_genes \
				latest_mouse_genes $file
		fi
		echo -e "Finished\tAlignment...\t$file"
	done



	echo -e "\nStarting\tCuffquant..."
	for file in tophat_alignment/*
	do
		cuffquant -p $nump -o cuffquant_out latest_genes.gff $file
	done




	echo -e "\nMoving back genomes..."
	if [ -f latest_dog_genes* ]; then
		mv latest_dog_genes* dog/
	fi
	if [ -f latest_mouse_genes* ]; then
		mv latest_mouse_genes* mouse/
	fi

	echo -e "Moving FastQC Output Here..."
	mv fastqc/* .

}






# run pipeline
if [ "$1" == "start" ]; then
	
	# check if there aare files leftover
	# if there are ask to delete them
	DIR='fastqc'
	if [ "$(ls -A $DIR)" ]; then
		
		echo -e "There are files leftover from last run."
		ls fastqc
		ls cuffquant_out
		ls tmpdir
		ls tophat_alignment
		echo -e"\n\n"
		echo -e "Do you want to delete all of them? This will delete all progress. y / n"
		read goon

		if [ "$goon" == "y" ]; then
			rm fastqc/*
			rm tmpdir/*
			rm trimmed_*
			rm tophat_alignment/*
			rm cuffquant_out/*
			runpipeline
		fi

		if [ "$goon" == "n" ]; then
			echo -e "Nevermind then."
		fi

	else
		echo -e "Running pipeline."
		runpipeline
	fi
fi


# retry pipeline and skip already made files
if [ "$1" == "retry" ]; then
	echo -e $1
fi

if [ "$1" == "" ]; then
	cat README.md
fi
# everything above but delete everything first
# restart entire pipeline completely
# if [ "$1" == "restart" ]; then	
# fi

























# for file in *.fastq
# do
# 	fastqc --noextract -o fastqc_out $file
# done





# printf "\n\n\n"
# echo -e "Chcek the fastqc_report.html file to see if everything passed."
# read -p "Press [Enter] to start trimming..."



# for file in fastqc_out/*.fastq
# do
# 	bn = b=$(basename $file)
# 	cutadapt -m 20 -q 20 -a AGATCGGAAGAGCAC --match-read-wildcards -o trimmed/trimmed_$bn $file cutadapt_output.out
# done






# printf "\n\n\n"
# echo -e "Running FastQC again just to be sure."
# for file in trimmed/*
# do
# 	fastqc -q --noextract -o fastqc_out $file
# done


# printf "\n\n\n"
# echo -e "Chceking to see if GFF file exists."
# if [!-f gff_out/latest_genes.gff ]; then
# 	echo -e "Please give directory of latest_genes.gtf: "
# 	read gtfloc
	
# 	mkdir gff_files
	
# 	# genome files in .bt2 format must in the directory that you are currently in
# 	tophat -G $gtfloc --transcriptome-index=gff_files genome
# fi





# printf "\n\n\n"
# echo -e "Found gff_output_dir/latest_genes."
# read -p "Press [Enter] to start alignment."



# for file in trimmed/*
# do
# 	tophat -p $nump -o tophat_alignment \
# 			--transcriptome-index=gff_files/latest_genes \
# 			--no-novel-juncs $genomeloc $file
# done





# echo -e "Alignment Complete."
# read -p "Press [Enter] to quantify gene expression with cuffquant."

# for file in tophat_alignment/*
# do
# 	cuffquant -p $nump -o cuffquant_out gff_out/latest_genes.gff $file
# done

