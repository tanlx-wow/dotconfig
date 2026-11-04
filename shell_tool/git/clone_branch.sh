#/usr/bin/bash
branch_list=("NMR" "NeutronBeamtime" "PostdocMeeting" "RNote" "home" "BioSAXS" "MD")
for branch in "${branch_list[@]}"; do
  git clone -b "$branch" https://github.com/tanlx-wow/nb_notebook.git "$branch"/
done
