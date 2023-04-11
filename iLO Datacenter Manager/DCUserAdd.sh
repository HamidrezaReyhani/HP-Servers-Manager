#!/bin/bash 
AdminPass="$1"
NewUser="$2"
Privileges="$3"
date=$(date "+%Y-%m-%d")
display_usage() {
echo -e "\nUsage: ./$(basename $0) AdminPassFile  NewUser Privilege"
echo -e "AdminPassFile must be a list file with this format : IP    FullControlUserName    Password\n"
echo ----------------------------
echo PRIVILEGES:     
echo 1: Login
echo 2: Remote Console                                        
echo 3: User Config                                           
echo 4: iLO Config                                            
echo 5: Virtual Media                                         
echo 6: Virtual Power and Reset
echo ----------------------------
}


AddAccount() {
cat "$AdminPass" |awk '{print $1}'| while read IloIp
do
echo '##################################################'
echo Opration for $(echo $IloIp|awk '{print $1}' )  AddAccount ...
string=$(cat "$AdminPass" |grep $IloIp )
Url=$(echo $string|awk '{print $1}')
FullControlUserName=$(echo $string|awk '{print $2}')
Password=$(echo $string |awk '{print $3}')
echo Checking User Validation ...
ilorest select ManagerAccount. --url="$Url" --user "$FullControlUserName" --password "$Password"  > /dev/null 2>&1
ExistUser=$(ilorest list Oem/Hp 2>&-  | grep  "LoginName="|grep "$NewUser")
if [  -z  "$ExistUser" ];
then
echo Genarating Password ...
NewPassword=$(cat /dev/urandom | tr -dc '1234567689!@#$%}{][ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' | head -c16; echo "" )
echo Creating User: $NewUser  ...
ilorest iloaccounts add "$NewUser" "$NewUser" "$NewPassword" --url="$Url" --user "$FullControlUserName"  --password "$Password" > /dev/null 2>&1
if [  "$?" -eq 0 ]
then
echo In $Url The User: "$NewUser" created Successfully!
echo "$IloIp    $NewUser        $NewPassword">> "$NewUser"-"$date"
else
echo In $Url Can not create user:"$NewUser" Please check Input or Network Connection!
exit 1
fi

ilorest iloaccounts modify "$NewUser" --addprivs "$Privileges" > /dev/null 2>&1
if [  "$?" -eq 0 ]
then
echo User:"$NewUser" Assign Privileges was successfully!
else
echo Can not assign Privileges user:"$NewUser" Please check Input or Network Connection!
exit 1
fi
ilorest logout > /dev/null 2>&1
else
echo In $Url The User:"$NewUser" existing!!
        echo Genarating Password ...
        NewPassword=$(cat /dev/urandom | tr -dc '1234567689!@#$%}{][ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz' | head -c16; echo "" )
         echo Changing $User  Password ...
ilorest iloaccounts changepass "$NewUser" "$NewPassword" --url="$Url" --user "$FullControlUserName" --password "$Password" > /dev/null 2>&1
        if [  "$?" -eq 0 ]
  then
  echo $Url  "$NewUser" Password  Updated  Successfully!
  ilorest iloaccounts modify "$NewUser" --addprivs "$Privileges" > /dev/null 2>&1
  echo "$Url    $NewUser        $NewPassword " >> "$NewUser"-"$date"
  else
  echo $Url Can not Change user:"$NewUser"  Password Please check Input or Network Connection!!
  ilorest logout
  exit 1
  fi



 fi
done
}



########################
########MAIN###########
########################


        if [  $# -ne 3 ]
        then
                display_usage
                exit 1
        fi

        if [[ ( $# == "--help") ||  $# == "-h" ]]
        then
                display_usage
            exit 0
        fi


        AddAccount
