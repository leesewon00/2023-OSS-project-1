#!/bin/bash

# start up code
item_file="$1"
data_file="$2"
user_file="$3"

echo "------------------------------"
echo "User Name : 이세원"
echo "Student Number : 12223771"
echo "[ MENU ]"
echo "1. Get the data of the movie identified by a specific 'movie id' from 'u.item'"
echo "2. Get teh data of action genre movies from 'u.item'"
echo "3. Get the average 'rating' of the movie identified by specific 'movie id' from 'u.data"
echo "4. Delete the 'IMDb URL' from 'u.item'"
echo "5. Get the data about users from 'u.user'"
echo "6. Modify the format of 'release date' in 'u.item'"
echo "7. Get the data of movies rated by a specific 'user id' from 'u.data'"
echo "8. Get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'"
echo "9. Exit"
echo "------------------------------"

fun1(){
  #Get the data of the movie identified by a specific 'movie id' from 'u.item'
  echo ""
	read -p "Please enter 'movie id' (1~1682) :" movieId
  echo ""
	awk -v id="$movieId" -F '|' '$1 == id {print}' $item_file
  echo ""
}

fun2() {
  # Get the data of ‘action’ genre movies from 'u.item’
  echo ""
  read -p "Do you want to get the data of 'action' genre movies from 'u.item'? (y/n): " yN
  echo ""
  if [ "$yN" = "y" ]; then
	  (awk -F '|' '{if ($7 ~ /1/) print $1, $2}' $item_file | head -n 10)
  fi
  echo ""
}

fun3() {
  # Get the average 'rating’ of the movie identified by specific 'movie id' from 'u.data’
  echo ""
  read -p "Please enter the 'movie id' (1~1682): " movieId
  echo ""

  total=0
  count=0
  result=$(awk -F'\t' -v id="$movieId" '$2 == id { total += $3; count++ } 
  END { if (count > 0) printf "%.5f", total / count }' $data_file)

  echo "average rating of $movieId: $result"
  echo ""
}

fun4(){
  # Delete the ‘IMDb URL’ from ‘u.item’
  echo ""
  read -p "Do you want to delete the 'IMDb URL' from 'u.item'?(y/n) :" yN
  echo ""
  if [ "$yN" = "y" ]; then
    awk -F '|' 'NR <= 10 {OFS=FS; $5=""; print}' $item_file
  fi
  echo ""
}

fun5() {
  # Get the data about users from 'u.user’
  echo ""
  read -p "Do you want to get the data about users from 'u.user'? (y/n): " yN
  echo ""
  if [ "$yN" = "y" ]; then
    awk -F '|' '{gender = ($3 == "M" ? "male" : "female"); 
    printf "user %d is %d years old %s %s\n", $1, $2, gender, $4}' $user_file | head -n 10
  fi
  echo ""
}

fun6() {
  # Modify the format of 'release date' in 'u.item’
  echo ""
  read -p "Do you want to Modify the format of 'release data' in 'u.item'? (y/n): " yN
  echo ""
  if [ "$yN" = "y" ]; then
    awk -F '|' '
      BEGIN {
        months["Jan"] = "01"
        months["Feb"] = "02"
        months["Mar"] = "03"
        months["Apr"] = "04"
        months["May"] = "05"
        months["Jun"] = "06"
        months["Jul"] = "07"
        months["Aug"] = "08"
        months["Sep"] = "09"
        months["Oct"] = "10"
        months["Nov"] = "11"
        months["Dec"] = "12"
      }
      {
        split($3, date, "-")
        month = months[date[2]]
        rest = substr($0, index($0, "|http://us.imdb.com"))
        printf "%d|%s|%s%s%s|%s\n", $1, $2, date[3], month, date[1], rest
      }' $item_file | tail -n 10
  fi
  echo ""
}

fun7() {
  #Get the data of movies rated by a specific 'user id' from 'u.data'
  echo ""
  read -p "Please enter the 'user id' (1~943): " userId
  echo ""

  user_movies=$(awk -v id="$userId" '$1 == id {print $2}' $data_file) #추출
  sorted_user_movies=$(echo "$user_movies" | sort -n) #sort
  echo $sorted_user_movies | tr ' ' '|' #4|15|28|,,,
	echo ""

	IFS="|" # 구분자
  count=0
  while read -ra movie_ids; do
    for movie_id in "${movie_ids[@]}"; do
      awk -v id="$movie_id" -F '|' '$1 == id {print $1"|"$2}' $item_file # 4|Get Shorty (1995)
      ((count++))
      if [ "$count" -eq 10 ]; then # 상위 10줄
        break 2
      fi
    done
  done <<< "$sorted_user_movies"
  echo ""
}

fun8() {
  echo ""
  read -p "Do you want to get the average 'rating' of movies rated by users with 'age' between 20 and 29 and 'occupation' as 'programmer'?(y/n): " yN
  echo ""
  if [ "$yN" = "y" ]; then
    selectedIds=$(awk -F '|' ' $2 >= 20 && $2 <= 29 && $4 == "programmer" {printf "%s,", $1}' $user_file)

    awk -v ids="$selectedIds" -F $'\t' '
      BEGIN {
        split(ids, idArr, ",")
      }
      {
        for (idx in idArr) {
          if ($1 == idArr[idx]) {
            ratingSum[$2] += $3; ratingCount[$2]++ 
          }
        }
      }
      END {
        for (movieId in ratingSum) {
          avg = ratingSum[movieId] / ratingCount[movieId]
          printf "%d ", movieId
          
          if (avg == int(avg)) {
            printf "%.0f\n", avg
          } else {
            result = sprintf("%.5f", avg)
            sub(/0+$/, "", result)
            print result
          }
        }
      }' $data_file | sort -n
  fi
  echo ""
}


while true; do
  read -p "Enter your choice [1-9]: " inputNum
  case $inputNum in
    1)
      fun1
      ;;
    2)
      fun2
      ;;
    3)
      fun3
      ;;
    4)
      fun4
      ;;
    5)
      fun5
      ;;
    6)
      fun6
      ;;
    7)
      fun7
      ;;
    8)
      fun8
      ;;
    9)
      echo "Bye!"
      break
      ;;
    *)
      echo "Please enter a number between 1 and 9."
      ;;
  esac
done