#! /bin/bash

# Get the day of the month from the current date
day=$(date +%d)

# Bail out if the directory already exists
if [ -d "priv/days/$day" ]; then
  echo "Day $day already started; aborting"
  exit 1
fi

# Create priv/days/{day}/input.txt and priv/days/{day}/example.txt
mkdir -p priv/days/$day

printf "0\n0\n---\ninput here" > priv/days/$day/input.txt
printf "0\n0\n---\nexample here" > priv/days/$day/example.txt

 # Copy the DayTemplate module
cp lib/advent_of_code/day_template.ex lib/advent_of_code/day_$day.ex

# Replace "DayTemplate" with "Day{day}"
sed -i '' "s/DayTemplate/Day$day/g" lib/advent_of_code/day_$day.ex

# Open the files
code priv/days/$day/example.txt
code priv/days/$day/input.txt
code lib/advent_of_code/day_$day.ex

echo "Created files for day $day"