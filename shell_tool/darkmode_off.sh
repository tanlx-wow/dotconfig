echo "please input the name of application you want darkmode off"
read app_name

app_id=$(osascript -e "id of app \"$app_name\"")
echo $app_id

defaults write $app_id NSRequiresAquaSystemAppearance -bool Yes

