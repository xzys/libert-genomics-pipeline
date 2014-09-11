#!/bin/bash
# script that wraps pipeline

if [ "$1" == "start" ]; then
	# startup
	echo "Hello stranger. Ready to start the pipeline?"
	read -p "Press [Enter]"

	echo "These are files you want to analyze?"
	for file in *.fastq
	do
		echo $file
	done
	read -p "Press [Enter]"

	echo "How many processors would you like to use in alignment: "
	read nump




	echo "Dog or Mouse? d / m"
	read species


	if [ "$species" == "d" ]; then
	do
		# move all genome files into this dir because top hat needs them here
		mv dog/latest_dog_genes* .
	done
		
	if [ "$species" == "m" ]; then
	do
		# move all genome files into this dir because top hat needs them here
		mv mouse/latest_mouse_genes* .
	done






	# do everything inside a tmux session
	tmux new-session -d -s session -n home


	# run commands inside it like this WHEN ATTACHED
	read -p "Press [Enter] to start pipeline...."
	
	echo "You can quit out of this window after the pipeline starts."
	echo "To reattach the session run: ./pipeline.sh attach"
	echo "Starting in 5 seconds..."

	tmux attach -t session
	tmux select-pane -t 0
	tmux send-keys -t home 'sleep 5;./align.sh start $species $nump' Enter

fi

if [ "$1" == "attach" ]; then
	echo $1
	tmux attach -t session
fi










