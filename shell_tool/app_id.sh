
# if no argument provided, prompt user
if [ "$1" = "" ]; then
  echo "please input the name of application you want darkmode off"
  read app_name
else 
  app_name="$1"
fi

app_id=$(osascript -e "id of app \"$app_name\"")
echo "$app_id"
